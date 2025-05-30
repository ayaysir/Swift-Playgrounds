//
//  PitchShiftOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/20/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SporthAudioKit
import SwiftUI

struct PitchShiftOperationData {
  /// 기본 피치 시프트 양 (세미톤 단위, 예: +12는 한 옥타브 위)
  var baseShift: AUValue = 0
  /// 진동의 범위 (진폭) — sin 곡선의 위아래 피치 이동 폭
  var range: AUValue = 7
  /// 피치를 흔드는 속도 — 초당 몇 번 흔들릴지 (주파수)
  var speed: AUValue = 3
  /// 파라미터 값이 바뀔 때 얼마나 부드럽게 변화할지
  var rampDuration: AUValue = 0.1
  /// Dry/Wet 믹스 비율. 0 = 원본만, 1 = 이펙트(wet)만, 0.5 = 절반 믹스
  var balance: AUValue = 0.5
}

class PitchShiftOperationConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let pitchShift: OperationEffect
  
  init() {
    buffer = Cookbook.sourceBuffer(source: .piano)
    player.buffer = buffer
    player.isLooping = true
    
    let r: ((Int) -> Int) = { oneBasedIndex in
      oneBasedIndex - 1
    }
    
    pitchShift = OperationEffect(player) { player, params in
      // sinusoid: Sine Wave의 다른 말
      let sinusoid = Operation.sineWave(frequency: params[r(3)])
      let shift = params[r(1)] + sinusoid * params[r(2)] / 2.0
      return player.pitchShift(semitones: shift)
    }
    
    pitchShift.parameter1 = 0
    pitchShift.parameter2 = 7
    pitchShift.parameter3 = 3
    
    dryWetMixer = DryWetMixer(player, pitchShift)
    engine.output = dryWetMixer
  }
  
  @Published var data = PitchShiftOperationData() {
    didSet {
      // $parameter: NodeParameter, parameter: AUValue
      pitchShift.$parameter1.ramp(to: data.baseShift, duration: data.rampDuration)
      pitchShift.$parameter2.ramp(to: data.range, duration: data.rampDuration)
      pitchShift.$parameter3.ramp(to: data.speed, duration: data.rampDuration)
      dryWetMixer.balance = data.balance
    }
  }
}

struct PitchShiftOperationView: View {
  @StateObject private var conductor = PitchShiftOperationConductor()
  
  var body: some View {
    VStack {
      PlayerControls(conductor: conductor, sourceName: "Piano")
      HStack {
        CookbookKnob(
          text: "Base Shift",
          parameter: $conductor.data.baseShift,
          range: -12...12,
          units: "Semitones"
        )
        CookbookKnob(
          text: "Range",
          parameter: $conductor.data.range,
          range: 0...24,
          units: "Semitones"
        )
        CookbookKnob(
          text: "Speed",
          parameter: $conductor.data.speed,
          range: 0.001...10,
          units: "Hz"
        )
        CookbookKnob(
          text: "Dry/Wet Mix",
          parameter: $conductor.data.balance,
          range: 0...1,
          units: "%"
        )
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.pitchShift,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Pitch Shift Operation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  PitchShiftOperationView()
}
