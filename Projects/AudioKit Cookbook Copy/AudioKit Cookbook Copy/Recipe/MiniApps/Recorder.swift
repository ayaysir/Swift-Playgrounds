//
//  Recorder.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/10/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

struct RecorderData {
  var isRecording = false
  var isPlaying = false
}

class RecorderConductor: ObservableObject, HasAudioEngine {
  var engine = AudioEngine()
  // Simple audio recorder class, requires a minimum buffer length of 128 samples (.short)
  var recorder: NodeRecorder?
  let player = AudioPlayer()
  var silencer: Fader?
  let mixer = Mixer()
  
  @Published var data = RecorderData() {
    didSet {
      if data.isRecording {
        do {
          try recorder?.record()
        } catch {
          print(error)
        }
      } else {
        recorder?.stop()
      }
      
      if data.isPlaying {
        if let file = recorder?.audioFile { // AVAudioFile
          try? player.load(file: file)
          player.play()
        }
      } else {
        player.stop()
      }
    }
  }
  
  init() {
    guard let input = engine.input else {
      fatalError("Engine input node is nil")
    }
    
    do {
      recorder = try NodeRecorder(node: input)
    } catch {
      fatalError("\(error)")
    }
    
    /**
     Fader 클래스는 AudioKit의 Node를 상속받는 **스테레오 신호의 볼륨 조절기(페이더)**로,
     입력 노드의 좌우 채널에 개별적으로 또는 동시에 증폭(Gain)을 적용할 수 있습니다.
     또한 좌우 채널을 **전환(Flip Stereo)**하거나, 스테레오 신호를 **모노로 믹스(Mix to Mono)**
     할 수 있는 기능도 제공합니다. `automateGain()`을 통해 시간 기반 자동 볼륨 조절도 지원합니다.
     
     - `Fader(gain: 0)`를 통해 입력은 실제 출력에는 들리지 않게 처리됨 (무음)
     */
    let silencer = Fader(input, gain: 0)
    self.silencer = silencer
    mixer.addInput(silencer)
    mixer.addInput(player)
    engine.output = mixer
  }
}

struct RecorderView: View {
  @StateObject var conductor = RecorderConductor()
  @State private var hasPermission = false
  
  var body: some View {
    VStack {
      Spacer()
      
      if hasPermission || isPreview {
        Button(conductor.data.isRecording ? "STOP RECORDING" : "RECORD") {
          conductor.data.isRecording.toggle()
        }
        .buttonStyle(.borderedProminent)
        .tint(.pink)
        Spacer()
        Button(conductor.data.isPlaying ? "STOP PLAYING" : "PLAY") {
          conductor.data.isPlaying.toggle()
        }
        .buttonStyle(.borderedProminent)
        .tint(.teal)
      } else {
        Text("Mic permission required!")
      }
      
      Spacer()
    }
    .padding()
    .navigationTitle("Recorder")
    .onAppear {
      requestMicrophonePermission { granted in
        hasPermission = granted
      }
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  RecorderView()
}
