//
//  Compressor.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/31/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class CompressorConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  let compressor: Compressor
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    compressor = Compressor(player)
    dryWetMixer = DryWetMixer(player, compressor)
    engine.output = dryWetMixer
    
    /*
     Compressor의 파라미터 값:
     
     Threshold | -20.0 | -100.0...20.0
     Head Room | 5.0 | 0.1...40.0
     Attack Time | 0.001 | 0.001...0.3
     Release Time | 0.05 | 0.01...3.0
     Master Gain | 0.0 | -40.0...40.0
     */
    
    compressor.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct CompressorView: View {
  @StateObject private var conductor = CompressorConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      .padding()
      HStack {
        ForEach(conductor.compressor.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      .frame(height: 80)
      .padding(.horizontal, 10)
      TabView {
        DryWetMixView(
          dry: conductor.player,
          wet: conductor.compressor,
          mix: conductor.dryWetMixer
        )
        ResizableImageView(image: Image(.imageParameterOfCompressor))
      }
      .padding(.horizontal, 10)
      .tabViewStyle(.page)
      .onAppear {
        UIPageControl.appearance().isHidden = true
      }
      .onDisappear {
        UIPageControl.appearance().isHidden = false
      }
    }
    .navigationTitle("Compressor")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  CompressorView()
}
