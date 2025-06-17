//
//  PWMOscillator.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/17/25.
//

import AudioKit
import SoundpipeAudioKit
import SwiftUI

struct PWMOscillatorView: View {
  var body: some View {
    BasicOscillatorView(
      navigationTitle: "PWM Oscillator",
      conductor: BasicOscillatorConductor(
        osc: PWMOscillator()
      )
    )
  }
  
  /*
   PWM Oscillator 파라미터 목록:
   Frequency | 440.0 | 0.0...20000.0
   Amplitude | 0.25 | 0.0...10.0
   Pulse Width | 0.5 | 0.0...1.0
   Frequency offset | 0.0 | -1000.0...1000.0
   Frequency detuning multiplier | 1.0 | 0.9...1.11
   */
}

#Preview {
  PWMOscillatorView()
}
