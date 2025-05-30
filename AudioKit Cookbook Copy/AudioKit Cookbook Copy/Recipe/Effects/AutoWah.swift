//
//  AutoWah.swift
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

class AutoWahConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .guitar
  
  let autoWah: AutoWah
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    autoWah = AutoWah(player)
    dryWetMixer = DryWetMixer(player, autoWah)
    engine.output = dryWetMixer
    
    /*
     AutoWah의 파라미터 값:
     
     Wah Amount | 0.0 | 0.0...1.0
     Dry/Wet Mix | 1.0 | 0.0...1.0
     Overall level | 0.1 | 0.0...1.0
     */
    
    autoWah.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct AutoWahView: View {
  @StateObject private var conductor = AutoWahConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.autoWah.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.autoWah,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("AutoWah")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  AutoWahView()
}
