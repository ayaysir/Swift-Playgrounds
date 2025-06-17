//
//  MorphingOscillator.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/17/25.
//

import AudioKit
import SoundpipeAudioKit
import SwiftUI

struct MorphingOscillatorView: View {
  var body: some View {
    BasicOscillatorView(
      navigationTitle: "Morphing Oscillator",
      conductor: BasicOscillatorConductor(
        osc: MorphingOscillator()
      )
    )
  }
  
  /*
   Morphing Oscillator 파라미터 목록:
   Frequency | 440.0 | 0.0...22050.0
   Amplitude | 0.25 | 0.0...1.0
   Index | 0.0 | 0.0...3.0
   Detuning offset | 0.0 | -1000.0...1000.0
   Detuning multiplier | 1.0 | 0.9...1.11
   */
}

#Preview {
  MorphingOscillatorView()
}
