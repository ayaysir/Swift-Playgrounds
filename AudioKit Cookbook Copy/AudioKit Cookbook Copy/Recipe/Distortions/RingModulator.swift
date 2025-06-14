//
//  RingModulator.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/14/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class RingModulatorConductor: BasicEffectConductor<RingModulator> {
  init() {
    super.init(source: .drums) { input in
      RingModulator(input) // from AudioKit
    }
    
    effect.ringModFreq1 = 2486
    effect.ringModFreq2 = 4655
    effect.ringModBalance = 56
    effect.finalMix = 100
  }
  
  /*
   RingModulator의 파라미터 목록:
   Ring Mod Freq1 | 100.0 | 0.5...8000.0
   Ring Mod Freq2 | 100.0 | 0.5...8000.0
   Ring Mod Balance | 50.0 | 0.0...100.0
   Final Mix | 50.0 | 0.0...100.0
   */
}

struct RingModulatorView: View {
  @StateObject private var conductor = RingModulatorConductor()
  
  var body: some View {
    BasicEffectView<RingModulator>(
      navTitle: "Ring Modulator",
      conductor: conductor
    )
  }
}

#Preview {
  RingModulatorView()
}
