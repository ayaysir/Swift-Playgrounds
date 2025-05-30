//
//  Chorus.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/30/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI
import DunneAudioKit

class ChorusConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  let chorus: Chorus // DunneAudioKit
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    chorus = Chorus(player)
    dryWetMixer = DryWetMixer(player, chorus)
    engine.output = dryWetMixer
    
    /*
     Chorus의 파라미터 값:
     
     Frequency (Hz) | 1.0 | 0.1...10.0
     Depth 0-1 | 0.25 | 0.0...1.0
     Feedback 0-1 | 0.0 | 0.0...0.95
     Dry Wet Mix 0-1 | 0.25 | 0.0...1.0
     */
    
    chorus.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct ChorusView: View {
  @StateObject private var conductor = ChorusConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.chorus.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.chorus,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Chorus")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  ChorusView()
}
