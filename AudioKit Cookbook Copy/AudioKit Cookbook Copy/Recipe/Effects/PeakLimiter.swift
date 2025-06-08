//
//  PeakLimiter.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/8/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//: A peak limiter will set a hard limit on the amplitude of an audio signal.
//: 피크 리미터는 오디오 신호의 진폭에 고정적인 한계를 설정합니다.
//: They're especially useful for any type of live input processing, when you
//: 특히 어떠한 모든 유형의 라이브 입력 처리에 유용한데,
//: may not be in total control of the audio signal you're recording or processing.
//: 녹음 또는 처리 중인 오디오 신호를 완벽하게 제어할 수 없는 경우입니다.

class PeakLimiterConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .drums
  
  let peakLimiter: PeakLimiter
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    peakLimiter = PeakLimiter(player)
    dryWetMixer = DryWetMixer(player, peakLimiter)
    engine.output = dryWetMixer
    
    /*
     PeakLimiter의 파라미터 값:
     
     Attack Time | 0.012 | 0.0005...0.03
     Decay Time | 0.024 | 0.001...0.04
     Pre Gain | 0.0 | -40.0...40.0
     */
    
    peakLimiter.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct PeakLimiterView: View {
  @StateObject private var conductor = PeakLimiterConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.peakLimiter.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.peakLimiter,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Peak Limiter")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  PeakLimiterView()
}
