//
//  Expander.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/5/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class ExpanderConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  let expander: Expander
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    expander = Expander(player)
    dryWetMixer = DryWetMixer(player, expander)
    engine.output = dryWetMixer
    
    /*
     Expander의 파라미터 값:
     
     Expansion Ratio | 2.0 | 1.0...50.0
     Expansion Threshold | 0.0 | -120.0...0.0
     Attack Time | 0.001 | 0.001...0.3
     Release Time | 0.05 | 0.01...3.0
     Master Gain | 0.0 | -40.0...40.0
     */
    
    expander.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct ExpanderView: View {
  @StateObject private var conductor = ExpanderConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.expander.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.expander,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Expander")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  ExpanderView()
}
