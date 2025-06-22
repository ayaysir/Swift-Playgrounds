//
//  RolandTB303Filter.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class RolandTB303FilterConductor: BasicEffectConductor<RolandTB303Filter> {
  init() {
    super.init(source: .strings) { input in
      RolandTB303Filter(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   Roland TB303 Filter의 파라미터 목록:
   Cutoff Frequency | 500.0 | 12.0...20000.0
   Resonance | 0.5 | 0.0...2.0
   Distortion | 2.0 | 0.0...4.0
   Resonance Asymmetry | 0.5 | 0.0...1.0
   */
}

struct RolandTB303FilterView: View {
  @StateObject private var conductor = RolandTB303FilterConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.effect.parameters) {
          switch $0.def.name {
          case "Cutoff Frequency":
            // 400 미만, 약 15500 초과 시 오류 발생,
            ParameterRow(param: $0, customRange: 400...14500.0)
          case "Distortion":
            ParameterRow(param: $0, customRange: 0.01...2.29)
          default:
            ParameterRow(param: $0)
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
    .navigationTitle("Roland TB303 Filter")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  RolandTB303FilterView()
}
