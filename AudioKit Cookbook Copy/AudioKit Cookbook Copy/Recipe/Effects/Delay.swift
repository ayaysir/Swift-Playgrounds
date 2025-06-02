//
//  Delay.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/2/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

// 두 개의 입력을 정확히 믹싱하는 것은 매우 흔한 일입니다. 하나는 처리 전, 다른 하나는 처리 후, 그 결과 두 입력이 결합된 결과가 생성됩니다.
// 이는 매우 일반적이어서 많은 AudioKit 노드에 드라이/웻 믹스 매개변수가 내장되어 있습니다.
// 하지만 직접 커스텀 효과를 만들거나 긴 효과 체인을 만드는 경우 DryWetMixer를 사용하여 신호를 믹싱할 수 있습니다.

class DelayConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  let delay: Delay
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    delay = Delay(player)
    delay.feedback = 0.9
    delay.time = 0.01
    
    // 지연에 내장된 dry/wet 믹스를 사용하지 않습니다.
    // dry/wet 결과를 탭(tapping)하여 그래프로 표시하기 때문입니다.
    delay.dryWetMix = 100 // 0 - 100
    dryWetMixer = DryWetMixer(player, delay)
    engine.output = dryWetMixer
    
    /*
     Delay의 파라미터 값:
     
     Dry-Wet Mix | 100.0 | 0.0...100.0
     Delay time (Seconds) | 0.01 | 0.0001...2.0
     Feedback (%) | 0.9 | -99.9...99.9
     Low Pass Cutoff Frequency | 15000.0 | 10.0...22050.0
     */
    
    delay.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct DelayView: View {
  @StateObject private var conductor = DelayConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.delay.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.delay,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Delay")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  DelayView()
}
