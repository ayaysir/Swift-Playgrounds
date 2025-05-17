//
//  InstrumentOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/17/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class InstrumentOperationConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  
  @Published var isRunning = false {
    didSet {
      isRunning ? generator.start() : generator.stop()
    }
  }
  
  let generator = OperationGenerator {
    func instrument(
      noteNumber: MIDINoteNumber,
      rate: Double,
      amplitude: Double
    ) -> OperationParameter {
      let metronome = Operation.metronome(frequency: 82 / (60 * rate))
      let frequency = Double(noteNumber.midiNoteToFrequency())
      let fmOsc = Operation.fmOscillator(baseFrequency: frequency, amplitude: amplitude)
      
      return fmOsc.triggeredWithEnvelope(
        trigger: metronome,
        attack: 0.5,
        hold: 1,
        release: 1
      )
    }
    
    let instruments = [
      instrument(noteNumber: 60, rate: 4, amplitude: 0.5), // C
      instrument(noteNumber: 62, rate: 5, amplitude: 0.4), // D
      instrument(noteNumber: 65, rate: 7, amplitude: 1.3 / 4.0), // F
      instrument(noteNumber: 67, rate: 7, amplitude: 0.125), // G
    ].reduce(Operation.trigger) { $0 + $1 } * 0.13
    // reduce(Operation.trigger): 연산 시작점으로 더미 트리거 지정
    
    /// 8개의 딜레이 라인 스테레오 FDN 리버브, 동일한 특성 임피던스를 갖는 8개의 무손실 도파관의 물리적 산란 접합 모델링을 기반으로 하는 피드백 매트릭스
    ///
    ///
    /// - Parameters:
    ///    - feedback: 0~1 범위의 피드백 레벨. 0.6은 작고 '라이브'한 룸 사운드를, 0.8은 작은 홀 사운드를, 0.9는 넓은 홀 사운드를 제공합니다. 정확히 1로 설정하면 무한한 길이를 의미하며, 더 높은 값으로 설정하면 opcode가 불안정해집니다. (기본값: 0.6, 최소값: 0.0, 최대값: 1.0)
    ///    - cutoffFrequency: 저역 통과 차단 주파수. (기본값: 4000, 최소값: 12.0, 최대값: 20000.0)
    ///
    let reverb = instruments.reverberateWithCostello(feedback: 0.9, cutoffFrequency: 10000).toMono()
    
    // mixer(drySignal, wetSignal, balance: 0.4(wet의 비율))
    // output = dry × (1 - balance) + wet × balance
    return mixer(instruments, reverb, balance: 0.4)
  }
  
  init() {
    engine.output = generator
  }
}

struct InstrumentOperationView: View {
  @StateObject private var conductor = InstrumentOperationConductor()
  
  var body: some View {
    VStack {
      Text(verbatim: #"Procedural sound synthesizer class that generates rhythmically triggered FM tones with reverb using Sporth and AudioKit. Encapsualating functionality of operations into functions."#)
      Divider()
      Text(verbatim: #"Sporth와 AudioKit을 활용하여 리듬에 따라 트리거되는 FM 톤과 리버브를 생성하는 절차적 사운드 합성 클래스입니다."#)
      Divider()
      Button(conductor.isRunning ? "STOP" : "START") {
        conductor.isRunning.toggle()
      }
      NodeOutputView(conductor.generator)
    }
    .padding()
    .navigationTitle("Instrument Operation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  InstrumentOperationView()
}
