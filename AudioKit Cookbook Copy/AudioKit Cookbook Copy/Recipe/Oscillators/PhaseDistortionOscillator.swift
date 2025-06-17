//
//  PhaseDistortionOscillator.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/17/25.
//

import AudioKit
import SoundpipeAudioKit
import SwiftUI

struct PhaseDistortionOscillatorView: View {
  var body: some View {
    BasicOscillatorView(
      navigationTitle: "Phase Distortion Oscillator",
      conductor: BasicOscillatorConductor(
        osc: PhaseDistortionOscillator()
      )
    )
  }
  
  /*
   PhaseDistortionOscillator 파라미터 목록:
   Frequency | 440.0 | 0.0...20000.0
   Amplitude | 0.25 | 0.0...10.0
   Phase distortion | 0.0 | -1.0...1.0
   Frequency offset | 0.0 | -1000.0...1000.0
   Detuning multiplier | 1.0 | 0.9...1.11
   */
}

#Preview {
  PhaseDistortionOscillatorView()
}
