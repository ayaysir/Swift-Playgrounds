//
//  InputDeviceDemo.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SwiftUI

class InputDeviceDemoConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var mic: AudioEngine.InputNode?
  let inputDevices = Settings.session.availableInputs
  var inputDeviceList = [String]()
  var mixer: Mixer
 
  init() {
    if let input = engine.input {
      mic = input
      mixer = Mixer(input)
    } else {
      mic = nil
      mixer = Mixer()
    }
    
    engine.output = mixer
    
    if let inputDevices {
      for device in inputDevices {
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

struct InputDeviceDemoView: View {
  @StateObject var conductor = InputDeviceDemoConductor()
  
  @State var isPlaying = false
  @State var inputDevice: Int = 0
  
  var body: some View {
    VStack {
      Text("‼️ 이 예제는 Channel/Device Routing과 거의 동일합니다.")
        .font(.caption2)
        .foregroundStyle(.gray)
      Text("Please plug in headphones")
      Text("to avoid a feedback loop.")
      Text("Then, select a device to start!")
      
      Picker("Input Device", selection: $inputDevice) {
        ForEach(conductor.inputDeviceList.indices, id: \.self) { i in
          Text(conductor.inputDeviceList[i])
            .tag(i)
        }
      }
      
      Text("For multiple input devices,")
      Text("create an Aggregate Device")
      Text("with the devices you want in it.")
      
      Button {
        isPlaying ? conductor.stop() : conductor.start()
        isPlaying.toggle()
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
            .foregroundStyle(.red)
      }
      
      NodeOutputView(conductor.mixer)
    }
    .padding()
    .navigationTitle("Input Device Demo")
    .onDisappear {
      conductor.stop()
    }
    .onChange(of: inputDevice) {
      conductor.switchInput(number: inputDevice)
    }
  }
}

#Preview {
  InputDeviceDemoView()
}
