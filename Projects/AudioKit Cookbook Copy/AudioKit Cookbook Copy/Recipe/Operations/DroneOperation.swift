//
//  DroneOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/16/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class DroneOperationConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  
  @Published var isRunning = false {
    didSet {
      isRunning ? generator.start() : generator.stop()
    }
  }
  
  let generator = OperationGenerator {
    func drone(frequency: Double, rate: Double) -> OperationParameter {
      let metronome = Operation.metronome(frequency: rate)
      let tone = Operation.sineWave(frequency: frequency, amplitude: 0.2)
      return tone.triggeredWithEnvelope(
        trigger: metronome,
        attack: 0.01,
        hold: 0.1,
        release: 0.1
      )
    }
    
    // 나누기 3으로 scale the volume
    return (drone(frequency: 440, rate: 3)
            + drone(frequency: 330, rate: 5)
            + drone(frequency: 450, rate: 7)) / 3
  }
  
  init() {
    engine.output = generator
  }
}

struct DroneOperationView: View {
  @StateObject private var conductor = DroneOperationConductor()
  
  var body: some View {
    VStack {
      Text(verbatim: #"Encapsualating functionality of operations into functions"#)
      Divider()
      Text(verbatim: "작업 기능을 함수로 캡슐화\nSporthAudioKit을 사용해 간단한 드론(지속음) 사운드를 만드는 예제")
      Divider()
      Button(conductor.isRunning ? "STOP" : "START") {
        conductor.isRunning.toggle()
      }
      NodeOutputView(conductor.generator)
    }
    .padding()
    .navigationTitle("Drone Operation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  DroneOperationView()
}
