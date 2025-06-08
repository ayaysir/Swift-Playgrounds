//
//  Panner.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/8/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class PannerConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  let panner: Panner
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    panner = Panner(player)
    dryWetMixer = DryWetMixer(player, panner)
    engine.output = dryWetMixer
    
    /*
     Panner의 파라미터 값:
     
     Pan | 0.0 | -1.0...1.0
     */
    
    panner.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct PannerView: View {
  @StateObject private var conductor = PannerConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.panner.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.panner,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Panner")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  PannerView()
}
