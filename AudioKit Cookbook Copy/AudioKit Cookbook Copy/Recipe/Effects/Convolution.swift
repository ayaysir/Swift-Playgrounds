//
//  Convolution.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/1/25.
//

//: 리버브나 환경 효과 등 다양한 효과를 만들 수 있습니다.
//: 모델링에도 사용할 수 있습니다.
//: Allows you to create a large variety of effects, usually reverbs or environments,
//: but it could also be for modeling.

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct ConvolutionData {
  var dryWetMix: AUValue = 0.5
  var stairwellDishMix: AUValue = 0.5
}

class ConvolutionConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  var dryWetMixer: DryWetMixer
  var stairwellDishMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  // Convolution(SoundPipeAudioKit): This module will perform partitioned convolution on an input signal using an ftable as an impulse response.
  let dishConvolution: Convolution!
  let stairwellConvolution: Convolution!
  
  @Published var data = ConvolutionData() {
    didSet {
      dryWetMixer.balance = data.dryWetMix
      stairwellDishMixer.balance = data.stairwellDishMix
    }
  }
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    guard
      let stairwellURL = Bundle.main.url(forResource: "Sounds/Impulse Responses/stairwell", withExtension: "wav"),
      let dishURL = Bundle.main.url(forResource: "Sounds/Impulse Responses/dish", withExtension: "wav")
    else {
      fatalError("Impulse Responses files not found")
    }
    
    stairwellConvolution = Convolution(
      player,
      impulseResponseFileURL: stairwellURL,
      partitionLength: 8192 // (in samples). Must be a power of 2. Lower values will add less latency, at the cost of requiring more CPU power.
    )
    
    dishConvolution = Convolution(
      player,
      impulseResponseFileURL: dishURL,
      partitionLength: 8192
    )
    
    stairwellDishMixer = DryWetMixer(stairwellConvolution, dishConvolution, balance: 0.5)
    dryWetMixer = DryWetMixer(player, stairwellDishMixer, balance: 0.5)
    engine.output = dryWetMixer
    stairwellConvolution.start()
    dishConvolution.start()
  }
}

struct ConvolutionView: View {
  @StateObject private var conductor = ConvolutionConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        CookbookKnob(
          text: "Dry Audio to Convolved",
          parameter: $conductor.data.dryWetMix,
          range: 0...1,
          units: "%"
        )
        CookbookKnob(
          text: "Stairwell to Dish",
          parameter: $conductor.data.stairwellDishMix,
          range: 0...1,
          units: "%"
        )
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.stairwellDishMixer,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Convolution")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  ConvolutionView()
}
