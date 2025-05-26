//
//  VocalTractOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/26/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class VocalTractOperationConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  
  let generator = OperationGenerator { params in
    // 성문 주파수 (Glottal Frequency)
    let frequency = Operation.sineWave(frequency: params.n(1))
      .scale(minimum: 100, maximum: 300)
    // 지터(전기 신호 불규칙으로 생기는 순간적 파형(波形) 난조)
    // A signal with random fluctuations This is useful for emulating jitter found in analogue equipment.
    let jitter = Operation.jitter(
      // The amplitude of the line. Will produce values in the range of (+/-)amp. (Default: 0.5)
      amplitude: 300,
      // The minimum frequency of change in Hz. (Default: 0.5)
      minimumFrequency: 1,
      // The maximum frequency of change in Hz. (Default: 4)
      maximumFrequency: 3
    )
      .scale() // 기본값 -1 ~ 1
    let position = Operation.sineWave(frequency: 0.1).scale() // 혀 위치
    let diameter = Operation.sineWave(frequency: 0.2).scale() // 혀 직경
    let tenseness = Operation.sineWave(frequency: 0.3).scale() // 혀 긴장도
    let nasality = Operation.sineWave(frequency: 0.35).scale() // 비음도 (콧소리 성분)
    
    return Operation.vocalTract(
      frequency: frequency + jitter,
      tonguePosition: position,
      tongueDiameter: diameter,
      tenseness: tenseness,
      nasality: nasality
    )
  }
  
  @Published var isRunning = false {
    didSet { isRunning ? generator.start() : generator.stop() }
  }
  
  @Published var frequencyHz: AUValue = 1 {
    didSet { generator.parameter1 = frequencyHz }
  }
  
  init() {
    engine.output = generator
    generator.parameter1 = frequencyHz
  }
}

struct VocalTractOperationView: View {
  @StateObject private var conductor = VocalTractOperationConductor()
  
  var body: some View {
    VStack {
      Text(verbatim: #"AudioKit의 OperationGenerator를 사용해 인간의 음성을 물리적으로 모델링한 음향 합성기를 구성합니다. vocalTract는 성도(목구멍~입)의 구조를 모사한 음향 모델이며, 다양한 인자에 따라 음색이 변합니다."#)
      Divider()
      HStack {
        Text("Frequency (\(String(format: "%.2f", conductor.frequencyHz)))")
        Slider(value: $conductor.frequencyHz, in: 0.1...4, step: 0.01)
      }
      
      Button(conductor.isRunning ? "STOP" : "START") {
        conductor.isRunning.toggle()
      }
      NodeOutputView(conductor.generator)
    }
    .padding()
    .navigationTitle("VocalTractOperation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  VocalTractOperationView()
}
