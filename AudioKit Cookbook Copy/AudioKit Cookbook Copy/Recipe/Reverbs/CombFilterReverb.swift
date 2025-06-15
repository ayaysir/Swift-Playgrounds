//
//  CombFilterReverb.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/15/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class CombFilterReverbConductor: BasicEffectConductor<CombFilterReverb> {
  init() {
    super.init(source: .drums) { input in
      CombFilterReverb(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   CombFilterReverb의 파라미터 목록:
   Reverb duration | 1.0 | 0.0...10.0 // ⚠️ 0으로 하면 고장남
   */
}

struct CombFilterReverbView: View {
  @StateObject private var conductor = CombFilterReverbConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor)
      ParameterRow(param: conductor.effect.parameters[0], customRange: 0.1...10.0)
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.effect,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Comb Filter Reverb")
    .onAppear {
        conductor.start()
    }
    .onDisappear {
        conductor.stop()
    }
  }
}

#Preview {
  CombFilterReverbView()
}
