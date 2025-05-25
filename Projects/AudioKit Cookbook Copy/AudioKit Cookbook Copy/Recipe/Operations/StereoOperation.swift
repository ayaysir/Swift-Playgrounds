//
//  StereoOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/24/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI
import SoundpipeAudioKit

class StereoOperationConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  private let panner: Panner
  
  let generator = OperationGenerator(channelCount: 2) { params in
    let slowSine = round(Operation.sineWave(frequency: 1) * 12) / 12
    // 단위: cent -> 오퍼레이션 사인 웨이브에 frequency:vibrato로 사용
    let vibrato = slowSine.scale(minimum: -1200, maximum: 1200)
    
    let fastSine = Operation.sineWave(frequency: 10)
    // 단위: 볼륨 -> 오퍼레이션 사인 웨이브에 amplitude:volume로 사용
    let volume = fastSine.scale(minimum: 0, maximum: 0.5)
    
    let leftOutput = Operation.sineWave(
      frequency: params[0] + vibrato,
      amplitude: volume
    )
    let rightOutput = Operation.sineWave(
      frequency: params[1] + vibrato,
      amplitude: volume
    )
    
    return [leftOutput, rightOutput]
  }
  
  init() {
    let panner = Panner(generator)
    engine.output = panner
    self.panner = panner
    
    generator.parameter1 = leftStartFreq
    generator.parameter2 = rightStartFreq
  }
  
  @Published var isRunning = false {
    didSet { isRunning ? generator.start() : generator.stop() }
  }
  @Published var pan: AUValue = 0.0 {
    didSet { panner.pan = pan }
  }
  @Published var leftStartFreq: AUValue = 440.0 {
    didSet { generator.parameter1 = leftStartFreq }
  }
  @Published var rightStartFreq: AUValue = 220.0 {
    didSet { generator.parameter2 = rightStartFreq }
  }
}

struct StereoOperationView: View {
  @StateObject private var conductor = StereoOperationConductor()
  
  var body: some View {
    VStack {
      Text(verbatim: #"This is an example of building a stereo sound generator."#)
      Divider()
      Text(verbatim: #"스테레오 사운드 생성기를 만드는 예제입니다."#)
      Divider()
      Button(conductor.isRunning ? "STOP" : "START") {
        conductor.isRunning.toggle()
      }
      Divider()
      VStack {
        makeSlider(
          name: "Stereo Pan",
          bindingValue: $conductor.pan,
          boundary: -1.0...1.0,
          step: 0.01
        )
        makeSlider(
          name: "L Start Freq",
          bindingValue: $conductor.leftStartFreq,
          boundary: 110...880,
          step: 1
        )
        makeSlider(
          name: "R Start Freq",
          bindingValue: $conductor.rightStartFreq,
          boundary: 110...880,
          step: 1
        )
      }
      NodeOutputView(conductor.generator)
    }
    .padding()
    .navigationTitle("Stereo Operation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
  
  @ViewBuilder private func makeSlider(
    name: String,
    bindingValue: Binding<AUValue>,
    boundary: ClosedRange<AUValue>,
    step: AUValue
  ) -> some View {
    HStack {
      Text("\(name): \(String(format: "%.2f", bindingValue.wrappedValue))")
        .font(.caption)

      Slider(value: bindingValue, in: boundary, step: step)
        .padding(.horizontal)
    }
  }
}

#Preview {
  StereoOperationView()
}
