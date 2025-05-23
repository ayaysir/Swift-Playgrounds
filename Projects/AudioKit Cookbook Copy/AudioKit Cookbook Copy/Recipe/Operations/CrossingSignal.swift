//
//  CrossingSignal.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/15/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class CrossingSignalConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  
  @Published var isRunning = false {
    didSet {
      isRunning ? generator.start() : generator.stop()
    }
  }
  
  let generator = OperationGenerator {
    // Generate a sine wave at the right frequency
    // 적절한 주파수에서 사인파를 생성합니다
    let crossingSignalTone = Operation.sineWave(frequency: 2500)
    
    // Periodically trigger an envelope around that signal
    // 주기적으로 해당 신호 주변의 envelope를 트리거합니다.
    let crossingSignalTrigger = Operation.periodicTrigger(period: 0.2) // 0.2초
    let crossingSignal = crossingSignalTone.triggeredWithEnvelope(
      trigger: crossingSignalTrigger,
      attack: 0.01,
      hold: 0.1,
      release: 0.01
    )
    
    // scale the volume
    return crossingSignal * 0.2
  }
  
  init() {
    engine.output = generator
  }
}

struct CrossingSignalView: View {
  @StateObject private var conductor = CrossingSignalConductor()
  
  var body: some View {
    VStack {
      Text(verbatim: #"A British crossing signal implemented with AudioKit, an example from Andy Farnell's excellent book "Designing Sound""#)
      Divider()
      Text(verbatim: #"Andy Farnell의 훌륭한 책 "Designing Sound"에서 발췌한 AudioKit을 사용하여 구현한 영국 횡단보도 경고음 (Crossing Signal)"#)
      Divider()
      Button(conductor.isRunning ? "STOP" : "START") {
        conductor.isRunning.toggle()
      }
      NodeOutputView(conductor.generator)
    }
    .padding()
    .navigationTitle("Crossing Signal")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  CrossingSignalView()
}
