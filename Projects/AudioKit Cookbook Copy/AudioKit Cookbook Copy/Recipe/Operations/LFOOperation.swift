//
//  LFOOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/18/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class LFOOperationConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  
  @Published var isRunning = false {
    didSet {
      isRunning ? generator.start() : generator.stop()
    }
  }
  
  let generator = OperationGenerator {
    // 주파수 영역 정의: 1초마다 1옥타브 이동 (A3 - A4)
    let frequencyLFO = Operation.square(frequency: 1)
    // scale: 입력 및 출력 도메인의 최소 및 최대 지점으로 정의된 범위
      .scale(minimum: 440, maximum: 880)
    // 캐리어 주파수: 주파수 대비 톤의 밝기 변화
    let carrierLFO = Operation.triangle(frequency: 1)
      .scale(minimum: 1, maximum: 2)
    // 변조 주파수: 빠르게 진동할수록 더 거친 소리
    let modulatingMultiplierLFO = Operation.sawtooth(frequency: 1)
      .scale(minimum: 0.1, maximum: 2)
    // FM 복잡도: 0.1 순음 ~ 20 거침
    let modulatingIndexLFO = Operation.reverseSawtooth(frequency: 1)
      .scale(minimum: 0.1, maximum: 20)
    
    return Operation.fmOscillator(
      baseFrequency: frequencyLFO,
      carrierMultiplier: carrierLFO,
      modulatingMultiplier: modulatingMultiplierLFO,
      modulationIndex: modulatingIndexLFO,
      amplitude: 0.2
    )
  }
  
  init() {
    engine.output = generator
  }
}

struct LFOOperationView: View {
  @StateObject private var conductor = LFOOperationConductor()
  
  var body: some View {
    VStack {
      Text(verbatim: #"Often we want rhythmic changing of parameters that varying in a standard way. This is traditionally done with Low-Frequency Oscillators, LFOs."#)
      Divider()
      Text(verbatim: #"우리는 종종 표준적인 방식으로 변하는 매개변수의 리드미컬한 변화를 원합니다. 이는 전통적으로 저주파 발진기(LFO)를 통해 구현됩니다."#)
      Divider()
      Button(conductor.isRunning ? "STOP" : "START") {
        conductor.isRunning.toggle()
      }
      NodeOutputView(conductor.generator)
    }
    .padding()
    .navigationTitle("LFO Operation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  LFOOperationView()
}
