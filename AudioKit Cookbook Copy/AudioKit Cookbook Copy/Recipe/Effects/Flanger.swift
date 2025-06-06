//
//  Flanger.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/6/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class FlangerConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .guitar
  
  let flanger: Flanger // DunneAudioKit
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    flanger = Flanger(player)
    dryWetMixer = DryWetMixer(player, flanger)
    engine.output = dryWetMixer
    
    /*
     Flanger의 파라미터 값:
     
     Frequency (Hz) | 1.0 | 0.1...10.0
     Depth 0-1 | 0.25 | 0.0...1.0
     Feedback 0-1 | 0.0 | -0.95...0.95
     Dry Wet Mix 0-1 | 0.5 | 0.0...1.0
     */
    
    flanger.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct FlangerView: View {
  @StateObject private var conductor = FlangerConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.flanger.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.flanger,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Flanger")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  FlangerView()
}
