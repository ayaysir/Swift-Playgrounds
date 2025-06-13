//
//  BasicEffectConductor.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/11/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class BasicEffectConductor<FX: Node>: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource
  let effect: FX
  
  init(source: GlobalSource = .strings, isUseDryWetMixer: Bool = true, effectBuilder: (Node) -> FX) {
    self.defaultSource = source
    
    // 1. 버퍼 로딩
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    // 2. 이펙트 초기화
    effect = effectBuilder(player)
    dryWetMixer = DryWetMixer(player, effect)
    
    if isUseDryWetMixer {
      // 3. DryWet 믹서 설정
      dryWetMixer.parameters[0].value = 1
      engine.output = dryWetMixer
    } else {
      // 3-2. DryWet 미사용
      engine.output = effect
    }
    
    // 4. 파라미터 출력 (옵션)
    if !effect.parameters.isEmpty {
      effect.parameters.forEach {
        print("\($0.def.name) | \($0.value) | \($0.range)")
      }
    } else {
      print("Effect.parameters is empty.")
    }
  }
}

