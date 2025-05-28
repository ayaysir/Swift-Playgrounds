//
//  PhasorOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/19/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class PhasorOperationConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()

  let generator = OperationGenerator { params in
    let interval = params[0]
    let noteCount = params[1]
    let startingNote = params[2] // C
    
    // Phasor: Produces a normalized sawtooth wave between the values of 0 and 1. Phasors are often used when building table-lookup oscillators.
    // frequency: 재생 속도 변화
    let phasing = Operation.phasor(frequency: params[3])
    // Scaled noise sent through a classic sample and hold module.
      * Operation.randomNumberPulse(
        minimum: 0.9,
        maximum: 2,
        updateFrequency: params[4] // Frequency of randomization (in Hz) (Default: 10), 새로운 랜덤 진행으로 변하는 시간
      )
    // Operation = (Operation * double + double).midiNoteToFreq()
    let frequency = (floor(phasing * noteCount) * interval + startingNote)
      .midiNoteToFrequency()
    
    var amplitude = (phasing - 1).portamento() // prevents the click sound
    var oscillator = Operation.sineWave(
      frequency: frequency,
      amplitude: amplitude
    )
    /*
     reverberateWithChowning() [John Chowning: 작곡가 이름]
     이 클래스는 FAUST에서 발견된 JC 리버브 구현을 사용하여 구축되었습니다.
     소스 코드에 따르면, 이 구현의 사양은 오래된 SAIL DART 백업 테이프에서 발견되었습니다.
     이 클래스는 단순 전역 통과 및 빗살 지연 필터 네트워크를 사용하는 CLM JCRev 함수에서 파생되었습니다.
     이 클래스는 세 개의 직렬 전역 통과 유닛(allpass units), 네 개의 병렬 빗살 필터(comb filter),
     그리고 출력에 병렬로 연결된 두 개의 비상관 지연 라인(decorrelation delay lines)을 구현합니다.
     */
    let reverb = oscillator.reverberateWithChowning()
    
    return mixer(oscillator, reverb, balance: 0.6)
  }
  
  init() {
    engine.output = generator
    generator.parameter1 = phasorInterval
    generator.parameter2 = phasorNoteCount
    generator.parameter3 = phasorStartingNote
    generator.parameter4 = phasorFrequency
    generator.parameter5 = phasorFrequency
  }
  
  @Published var isRunning = false {
    didSet {
      isRunning ? generator.start() : generator.stop()
    }
  }
  @Published var phasorInterval: AUValue = 2 {
    didSet {
      generator.parameter1 = phasorInterval // 1 ~ 4 (step 1)
    }
  }
  @Published var phasorNoteCount: AUValue = 24 {
    didSet {
      generator.parameter2 = phasorNoteCount // 12 ~ 48 (step 12)
    }
  }
  @Published var phasorStartingNote: AUValue = 48 {
    didSet {
      generator.parameter3 = phasorStartingNote // 36 ~ 72 (step 1)
    }
  }
  @Published var phasorFrequency: AUValue = 0.5 {
    didSet {
      generator.parameter4 = phasorFrequency // 0.1 ~ 2 (step 0.1)
    }
  }
  @Published var phasorRandomUpdateFrequency: AUValue = 0.5 {
    didSet {
      generator.parameter5 = phasorFrequency // 0.1 ~ 2 (step 0.1)
    }
  }
}

struct PhasorOperationView: View {
  @StateObject private var conductor = PhasorOperationConductor()
  
  var body: some View {
    VStack {
      Text(verbatim: #"Using the phasor to sweep amplitude and frequencies"#)
      Divider()
      Text(verbatim: #"페이저(phasor)를 사용하여 진폭과 주파수를 스윕합니다."#)
      Divider()
      Button(conductor.isRunning ? "STOP" : "START") {
        conductor.isRunning.toggle()
      }
      Divider()
      VStack(spacing: 20) {
        // Interval
        HStack {
          Text("Interval: \(conductor.phasorInterval, specifier: "%.1f")")
          Slider(value: $conductor.phasorInterval, in: 1...4, step: 1)
        }

        // Note Count
        HStack {
          Text("Note Count: \(Int(conductor.phasorNoteCount))")
          Slider(value: $conductor.phasorNoteCount, in: 12...48, step: 12)
        }

        // Starting Note
        HStack {
          Text("Starting Note: \(Int(conductor.phasorStartingNote))")
          Slider(value: $conductor.phasorStartingNote, in: 36...72, step: 1)
        }

        // Phasor Frequency
        HStack {
          Text("Phasor Frequency: \(conductor.phasorFrequency, specifier: "%.1f")")
          Slider(value: $conductor.phasorFrequency, in: 0.1...2.0, step: 0.1)
        }

        // Random Update Frequency
        HStack {
          Text("Random Update Freq: \(conductor.phasorRandomUpdateFrequency, specifier: "%.1f")")
          Slider(value: $conductor.phasorRandomUpdateFrequency, in: 0.1...2.0, step: 0.1)
        }
      }
      .padding(10)
      .font(.system(size: 10))
      NodeOutputView(conductor.generator)
    }
    .padding()
    .navigationTitle("Phasor Operation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  PhasorOperationView()
}
