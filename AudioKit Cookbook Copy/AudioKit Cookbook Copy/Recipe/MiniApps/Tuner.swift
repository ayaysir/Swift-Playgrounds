//
//  Tuner.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/13/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI

struct TunerData {
  var pitch: Float = 0.0
  var amplitude: Float = 0.0
  var noteNameWithSharps = "-"
  var noteNameWithFlats = "-"
}

fileprivate struct NoteInfo {
  var frequency: Double
  var noteNamesWithSharps: String
  var noteNamesWithFlats: String
}

class TunerConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  
  @Published var data = TunerData()
  let initialDevice: Device
  
  let mic: AudioEngine.InputNode
  /**
   `Tappable Node`란, 일반적으로 사용자의 터치(또는 탭) 입력에 반응하는 오디오 노드를 뜻합니다. 즉, 사용자가 UI 상에서 특정 노드를 ‘탭’했을 때, 소리를 재생하거나 처리하는 노드입니다.
   - Node: 오디오 신호 처리 체인 내에서의 구성 요소 (예: Oscillator, Reverb, Mixer 등).
   - Tappable: 손가락 터치(탭)로 동작을 트리거(trigger)할 수 있는 상태.
   - 예: 드럼 머신 앱에서 Pad를 탭하면 해당 소리를 재생하는 노드, 피아노 건반 눌렀을 때 음 발생하는 노드
   - 즉, UI 이벤트와 연결된 오디오 처리 단위
   */
  let tappableNode: (A: Fader, B: Fader, C: Fader)
  let silence: Fader
  
  var tracker: PitchTap!
  
  fileprivate let noteInfos: [NoteInfo] = [
    .init(frequency: 16.35, noteNamesWithSharps: "C",   noteNamesWithFlats: "C"),
    .init(frequency: 17.32, noteNamesWithSharps: "C♯", noteNamesWithFlats: "D♭"),
    .init(frequency: 18.35, noteNamesWithSharps: "D",   noteNamesWithFlats: "D"),
    .init(frequency: 19.45, noteNamesWithSharps: "D♯", noteNamesWithFlats: "E♭"),
    .init(frequency: 20.60, noteNamesWithSharps: "E",   noteNamesWithFlats: "E"),
    .init(frequency: 21.83, noteNamesWithSharps: "F",   noteNamesWithFlats: "F"),
    .init(frequency: 23.12, noteNamesWithSharps: "F♯", noteNamesWithFlats: "G♭"),
    .init(frequency: 24.50, noteNamesWithSharps: "G",   noteNamesWithFlats: "G"),
    .init(frequency: 25.96, noteNamesWithSharps: "G♯", noteNamesWithFlats: "A♭"),
    .init(frequency: 27.50, noteNamesWithSharps: "A",   noteNamesWithFlats: "A"),
    .init(frequency: 29.14, noteNamesWithSharps: "A♯", noteNamesWithFlats: "B♭"),
    .init(frequency: 30.87, noteNamesWithSharps: "B",   noteNamesWithFlats: "B"),
  ]
  
  init() {
#if DEBUG
    let input = engine.input
    Log("input is \(input == nil ? "nil" : "not nil")")
    let device = engine.inputDevice
    Log("device is \(device == nil ? "nil" : "not nil")")
    
    initialDevice = device ?? .init(name: "Void 1", deviceID: UUID().uuidString)
    
    mic = input ?? .init()
#else
    guard let input = engine.input else { fatalError() }
    guard let device = engine.inputDevice else { fatalError() }
    
    initialDevice = device
    mic = input
#endif
    tappableNode.A = Fader(mic)
    tappableNode.B = Fader(tappableNode.A)
    tappableNode.C = Fader(tappableNode.B)
    silence = Fader(tappableNode.C, gain: 0)
    engine.output = silence
    
    tracker = PitchTap(mic) { pitch, amp in
      DispatchQueue.main.async {
        self.update(pitch[0], amp[0])
      }
    }
    tracker.start()
  }
  
  func update(_ pitch: AUValue, _ amp: AUValue) {
    // Reduces sensitivity to background noise to prevent random / fluctuating data.
    guard amp > 0.1 else {
      return
    }
    
    data.pitch = pitch
    data.amplitude = amp
    
    var frequency = pitch
    while frequency > Float(noteInfos[noteInfos.count - 1].frequency) {
      frequency /= 2.0
    }
    while frequency < Float(noteInfos[0].frequency) {
      frequency *= 2.0
    }
    
    var minDistance: Float = 10000.0
    var index = 0
    
    for possibleIndex in noteInfos.indices {
      // fabsf는 부동소수점 실수(float)의 절댓값을 계산하는 C 표준 라이브러리 함수
      let distance = fabsf(Float(noteInfos[possibleIndex].frequency) - frequency)
      if distance < minDistance {
        index = possibleIndex
        minDistance = distance
      }
    }
    
    // log2f: x의 밑이 2인 로그를 Float 타입으로 반환합니다. 즉, log2f(x)는 2^y = x인 y 값을 반환합니다.
    let octave = Int(log2f(pitch / frequency))
    data.noteNameWithSharps = "\(noteInfos[index].noteNamesWithSharps)\(octave)"
    data.noteNameWithFlats = "\(noteInfos[index].noteNamesWithFlats)\(octave)"
  }
}

struct InputDevicePicker: View {
  @State var device: Device
  
  var body: some View {
    Picker("Input: \(device.deviceID)", selection: $device) {
      ForEach(getDevices(), id: \.self) {
        Text($0.deviceID)
      }
    }
    .pickerStyle(.menu)
    .onChange(of: device) {
      setInputDevice(to: device)
    }
  }
  
  func getDevices() -> [Device] {
    AudioEngine.inputDevices.compactMap { $0 }
  }

  func setInputDevice(to device: Device) {
    do {
      try AudioEngine.setInputDevice(device)
    } catch {
      print(#function, error)
    }
  }
}

struct TunerView: View {
  @StateObject var conductor = TunerConductor()
  
  var body: some View {
    VStack {
      HStack {
        Text("Frequency")
        Spacer()
        Text("\(conductor.data.pitch, specifier: "%0.1f")")
      }
      .padding()
      
      HStack {
        Text("Amplitude")
        Spacer()
        Text("\(conductor.data.amplitude, specifier: "%0.1f")")
      }
      .padding()
      
      HStack {
        Text("Note Name")
        Spacer()
        Text("\(conductor.data.noteNameWithSharps) / \(conductor.data.noteNameWithFlats)")
      }
      .padding()
      
      InputDevicePicker(device: conductor.initialDevice)
      
      NodeRollingView(conductor.tappableNode.A)
        .clipped()
      NodeOutputView(conductor.tappableNode.B)
        .clipped()
      NodeFFTView(conductor.tappableNode.C)
        .clipped()
    }
    .navigationTitle("Tuner")
    .onAppear {
      requestMicrophonePermission { granted in
        
      }
      if !isPreview {
        conductor.start()
      }
    }
    .onDisappear {
      if !isPreview {
        conductor.stop()
      }
    }
  }
}

#Preview {
  TunerView()
}
