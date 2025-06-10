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
import SoundpipeAudioKit
import SwiftUI

class PitchShifterConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  let pitchShifter: PitchShifter
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    pitchShifter = PitchShifter(player)
    dryWetMixer = DryWetMixer(player, pitchShifter)
    dryWetMixer.parameters[0].value = 1
    engine.output = dryWetMixer
    
    
    
    /*
     PitchShifter의 파라미터 값:
     
     Shift | 0.0 | -24.0...24.0
     Window size | 1024.0 | 0.0...10000.0
     Crossfade | 512.0 | 0.0...10000.0
     */
    
    pitchShifter.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct PitchShifterView: View {
  @StateObject private var conductor = PitchShifterConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.pitchShifter.parameters.indices, id: \.self) { i in
          if i == 1 {
            ParameterRow(
              param: conductor.pitchShifter.parameters[i],
              customRange: 1.0...10000.0
            )
          } else {
            ParameterRow(param: conductor.pitchShifter.parameters[i])
          }
        }
        // ForEach(conductor.pitchShifter.parameters) {
        //   ParameterRow(param: $0)
        // }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.pitchShifter,
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
