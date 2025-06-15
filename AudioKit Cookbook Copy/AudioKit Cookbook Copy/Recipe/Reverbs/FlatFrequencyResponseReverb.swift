//
//  FlatFrequencyResponseReverb.swift
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

class FlatFrequencyResponseReverbConductor: BasicEffectConductor<FlatFrequencyResponseReverb> {
  init() {
    super.init(source: .drums) { input in
      FlatFrequencyResponseReverb(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   FlatFrequencyResponseReverb의 파라미터 목록:
   Reverb duration | 0.5 | 0.0...10.0 // ⚠️ 0으로 하면 고장남
   */
}

struct FlatFrequencyResponseReverbView: View {
  @StateObject private var conductor = FlatFrequencyResponseReverbConductor()
  
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
    .navigationTitle("Flat Frequency Response Reverb")
    .onAppear {
        conductor.start()
    }
    .onDisappear {
        conductor.stop()
    }
  }
}

#Preview {
  FlatFrequencyResponseReverbView()
}
