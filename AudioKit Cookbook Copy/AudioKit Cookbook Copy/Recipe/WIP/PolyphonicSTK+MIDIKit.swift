//
//  PolyphonicSTK+MIDIKit.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import STKAudioKit
import SwiftUI
import Tonic
import MIDIKit // https://github.com/orchetect/MIDIKit
import DunneAudioKit

class PolyphonicSTKConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let mixer: Mixer
  var notes = Array(repeating: 0, count: 11)
  var oscs: [RhodesPianoKey] = []
  var envs: [AmplitudeEnvelope] = []
  var numberOfPlaying = 0
 
  // MIDI Manager (MIDI methods are in SoundFont+MIDI)
  // CoreMIDI 클라이언트 생성, 포트 연결 및 관리
  // iOS/macOS 미디 시스템과 연동
  let midiManager = MIDIManager(
    clientName: "CookbookAppMIDIManager",
    model: "CookbookApp",
    manufacturer: "BGSMM"
  )
  
  init() {
    for _ in notes.indices {
      let osc = RhodesPianoKey()
      let env = AmplitudeEnvelope(osc)
      
      env.attackDuration = 0
      env.releaseDuration = 0.2
      
      oscs.append(osc)
      envs.append(env)
    }
    
    mixer = Mixer(envs)
    engine.output = mixer
    
    MIDIConnect()
  }
  
  func noteOn(pitch: Pitch, velocity: Int = 127) {
    numberOfPlaying += 1
    if numberOfPlaying > 10 {
      numberOfPlaying = 0
    }
    
    oscs[numberOfPlaying].trigger(note: MIDINoteNumber(pitch.intValue), velocity: MIDIVelocity(velocity))
    notes[numberOfPlaying] = pitch.intValue
    envs[numberOfPlaying].openGate()
  }
  
  func noteOn(pitch: Pitch, point _: CGPoint) {
    noteOn(pitch: pitch, velocity: 110)
  }
  
  func noteOff(pitch: Pitch) {
    for i in notes.indices where notes[i] == pitch.intValue {
      envs[i].closeGate()
      notes[i] = 0
    }
  }
  
  /// Connect MIDI on init
  func MIDIConnect() {
    do {
      print("Starting MIDI services.")
      // MIDI 시스템 접근을 시작하며, 장치 탐색 및 연결 가능 상태로 전환
      try midiManager.start()
    } catch {
      print("Error starting MIDI services:", error.localizedDescription)
    }
    
    do {
      // 입력 연결 설정
      try midiManager.addInputConnection(
        // no need to specify if we're using AllOutputs
        // 연결 가능한 모든 외부 출력 포트를 수신 대상으로 설정
        to: .allOutputs,
        tag: "Listener",
        // owned: 본 앱이 만든 가상 포트는 수신 대상에서 제외
        filter: .owned(), // don't allow self-created virtual endpoints
        receiver: .events { [weak self] events, timeStamp, source in
          // 참고: 이 핸들러는 백그라운드 스레드에서 호출됩니다.
          // UI 업데이트가 발생할 수 있는 경우 메인 스레드에서 다음 줄을 호출하세요.
          Task { @MainActor in
            for event in events {
              self?.received(midiEvent: event)
            }
          }
          
          /*
           🧠 왜 DispatchQueue.main.async {}는 안 되냐?
           
           기능은 되지만, DispatchQueue는 Swift Concurrency 시스템과 통합되어 있지 않기 때문에:
           •  타입 안전 검사를 우회함 (컴파일러가 에러 감지 못함)
           •  Swift의 @Sendable 체크와 연동되지 않음
           •  Swift 6에서는 더 엄격하게 문제될 수 있음
           
           따라서 Swift Concurrency와 호환되는 Task { @MainActor in } 방식이 권장됩니다.
           */
          // DispatchQueue.main.async {
          //   events.forEach {
          //     self?.received(midiEvent: $0) // self?.received(midiEvent: $0) Capture of 'self' with non-sendable type 'PolyphonicSTKConductor?' in a '@Sendable' closure
          //   }
          // }
        }
      )
    } catch {
      print(
        "Error setting up managed MIDI all-listener connection:",
        error.localizedDescription
      )
    }
  }
  
  /// MIDI Events
  private func received(midiEvent: MIDIKit.MIDIEvent) {
    switch midiEvent {
    case .noteOn(let payload): // payload: NoteOn 타입
      print("Note On:", payload.note, payload.velocity, payload.channel)
      let noteNumber: UInt8 = payload.note.number.uInt8Value
      let noteNumberPitch = Pitch(Int8(noteNumber))
      let velocity = Int(payload.velocity.midi1Value.uInt8Value)
      noteOn(pitch: noteNumberPitch, velocity: velocity)
      
      NotificationCenter.default.post(
        name: .MIDIKey,
        object: nil,
        userInfo: ["info": noteNumber, "bool": true]
      )
    case .noteOff(let payload):  // payload: NoteOff 타입
      print("Note Off:", payload.note, payload.velocity, payload.channel)
      let noteNumber: UInt8 = payload.note.number.uInt8Value
      let noteNumberPitch = Pitch(Int8(noteNumber))
      noteOff(pitch: noteNumberPitch)
      
      NotificationCenter.default.post(
        name: .MIDIKey,
        object: nil,
        userInfo: ["info": noteNumber, "bool": false]
      )
    case .cc(let payload):
      print("Control Change:", payload.controller, payload.value, payload.channel)
    case .programChange(let payload):
      print("Program Change:", payload.program, payload.channel)
    default:
      break
    }
  }
}

struct PolyphonicSTKView: View {
  @StateObject var conductor = PolyphonicSTKConductor()
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    VStack {
      if let output = conductor.engine.output {
        NodeOutputView(output)
      }
      
      MIDIKitKeyboard(
        noteOn: conductor.noteOn,
        noteOff: conductor.noteOff
      )
    }
    .navigationTitle("Polyphonic STK + MIDIKit")
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
    .background(colorScheme == .dark ?
                Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
  }
}

#Preview {
  PolyphonicSTKView()
}
