//
//  AutoPanner.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/28/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class AutoPannerConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  
  let panner: AutoPanner
  var mixer: Mixer
  
  init() {
    buffer = Cookbook.sourceBuffer(source: .piano)
    player.buffer = buffer
    player.isLooping = true
    
    panner = AutoPanner(player)
    dryWetMixer = DryWetMixer(player, panner)
    
    mixer = Mixer(dryWetMixer)
    engine.output = mixer
    /*
     Panner의 파라미터 값:
     
     Frequency | 10.0 | 0.0...100.0
     Depth | 1.0 | 0.0...1.0
     */
    
    panner.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
  
  @Published var pan: AUValue = 0 {
    didSet { mixer.pan = pan }
  }
}

struct AutoPannerView: View {
  @StateObject private var conductor = AutoPannerConductor()
  
  var body: some View {
    VStack {
      PlayerControls(conductor: conductor, sourceName: "Piano")
      HStack {
        ForEach(conductor.panner.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
        CookbookKnob(
          text: "Mixer Pan",
          parameter: $conductor.pan,
          range: -1.0...1.0,
          units: "L/R"
        )
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.panner,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Auto Panner")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  AutoPannerView()
}
