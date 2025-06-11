//
//  PitchShifter.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/10/25.
//



import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class PitchShifterConductor: BasicEffectConductor<PitchShifter> {
  init() {
    super.init(source: .strings) { input in
      PitchShifter(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   PitchShifter의 파라미터 목록:
   Shift | 0.0 | -24.0...24.0
   Window size | 1024.0 | 0.0...10000.0
   Crossfade | 512.0 | 0.0...10000.0
   */
}

struct PitchShifterView: View {
  @StateObject private var conductor = PitchShifterConductor()

  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.effect.parameters.indices, id: \.self) { i in
          if i == 1 {
            ParameterRow(
              param: conductor.effect.parameters[i],
              customRange: 1.0...10000.0
            )
          } else {
            ParameterRow(param: conductor.effect.parameters[i])
          }
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.effect,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Pitch Shifter")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  PitchShifterView()
}
