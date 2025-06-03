//
//  DynamicRangeCompressor.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/3/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class DynamicRangeCompressorConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  let compressor: DynamicRangeCompressor
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    compressor = DynamicRangeCompressor(player)
    dryWetMixer = DryWetMixer(player, compressor)
    engine.output = dryWetMixer
    
    /*
     DynamicRangeCompressor의 파라미터 값:
     
     Ratio | 1.0 | 0.01...100.0
     Threshold | 0.0 | -100.0...0.0
     Attack duration | 0.1 | 0.0...1.0
     Release duration | 0.1 | 0.0...1.0
     */
    
    compressor.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct DynamicRangeCompressorView: View {
  @StateObject private var conductor = DynamicRangeCompressorConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.compressor.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.compressor,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Dynamic Range Compressor")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  DynamicRangeCompressorView()
}
