//
//  ChannelDeviceRouting.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

class ChannelDeviceRoutingConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var input: AudioEngine.InputNode?
  // Settings: global settings for AudioKit
  let inputDevices = Settings.session.availableInputs
  var inputDeviceList = [String]()
  var mixer = Mixer()
  
  init() {
    do {
      try Settings.setSession(
        category: .playAndRecord,
        with: [.defaultToSpeaker,
               .mixWithOthers,
               .allowBluetooth,
               .allowBluetoothA2DP]
      )
    } catch {
      Log(error.localizedDescription)
    }
    
    if let input = engine.input {
      self.input = input
      mixer = Mixer(input)
      engine.output = mixer
    } else {
      input = nil
      engine.output = mixer
    }
    
    if let existingInputs = inputDevices {
      for device in existingInputs {
        inputDeviceList.append(device.portName)
      }
    }
  }
  
  func switchInput(number: Int?) {
    stop()
    if let inputs = Settings.session.availableInputs {
      let newInput = inputs[number ?? 0]
      do {
        try Settings.session.setPreferredInput(newInput)
      } catch {
        Log(error.localizedDescription)
      }
    }
  }
}

struct ChannelDeviceRoutingView: View {
  @StateObject private var conductor = ChannelDeviceRoutingConductor()
  @State var isPlaying = false
  @State var inputDevice: Int = 0
  @State private var showingAlert = false
  @State private var headphonesIn = Settings.headPhonesPlugged
  
  var body: some View {
    VStack {
      Text("‼️ 이 예제는 Input Device Demo와 거의 동일합니다.")
        .font(.caption2)
        .foregroundStyle(.gray)
      Text("Input Devices")
        .font(.title2)
        .bold()
      
      Picker("Input Device", selection: $inputDevice) {
        ForEach(conductor.inputDeviceList.indices, id: \.self) { i in
          Text(conductor.inputDeviceList[i])
            .tag(i)
        }
      }
      
      Button {
        if isPlaying {
          conductor.stop()
          isPlaying.toggle()
        } else {
          if headphonesIn {
            conductor.start()
            isPlaying.toggle()
            showingAlert = false
          } else {
            showingAlert = true
          }
        }
      } label: {
        Image(systemName: isPlaying ? "mic.circle.fill" : "mic.circle")
            .resizable()
            .frame(
              minWidth: 25, // 너비가 최소 25pt 이하로는 줄어들지 않음
              idealWidth: 50, // 가능하다면 너비는 50pt로 맞추려고 시도함 (우선순위 중간)
              maxWidth: 100, // 너비가 최대 100pt 이상은 늘어나지 않음
              minHeight: 25, // 높이가 최소 25pt 이하로 줄어들지 않음
              idealHeight: 50, // 가능하다면 높이를 50pt로 맞추려 함
              maxHeight: 100, // 높이가 최대 100pt 이상은 안 됨
              alignment: .center // 뷰 내부 컨텐츠의 정렬 (기본은 .center)
            )
            .foregroundStyle(.pink)
      }
      .keyboardShortcut(.space, modifiers: [])
      
      NodeOutputView(conductor.mixer)
    }
    .padding()
    .navigationTitle("Channel/Device Routing")
    .onDisappear {
      conductor.stop()
    }
    .onChange(of: inputDevice) {
      conductor.switchInput(number: inputDevice)
    }
    .alert("Warning: Check your levels!", isPresented: $showingAlert) {
      Button("Proceed", role: .destructive) {
        conductor.start()
        isPlaying.toggle()
      }
    } message: {
      Text("Audio feedback may occur!")
    }
  }
}

#Preview {
  ChannelDeviceRoutingView()
}
