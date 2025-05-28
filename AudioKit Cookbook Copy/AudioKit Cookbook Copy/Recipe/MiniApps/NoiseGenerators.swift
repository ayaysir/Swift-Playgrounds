//
//  NoiseGenerators.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/9/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Controls
import SoundpipeAudioKit
import SwiftUI

struct NoiseData {
  var brownianAmplitude: AUValue = 0
  var pinkAmplitude: AUValue = 0
  var whiteAmplitude: AUValue = 0
}

class NoiseGeneratorsConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  
  // SoundpipeAudioKit에 있음
  var brown = BrownianNoise()
  var pink = PinkNoise()
  var white = WhiteNoise()
  
  var mixer = Mixer()
  
  @Published var data = NoiseData() {
    didSet {
      // amplitude: 진폭, 소리의 크기(볼륨) 또는 에너지의 세기를 의미합니다.
      brown.amplitude = data.brownianAmplitude
      pink.amplitude = data.pinkAmplitude
      white.amplitude = data.whiteAmplitude
    }
  }
  
  init() {
    mixer.addInput(brown)
    mixer.addInput(pink)
    mixer.addInput(white)
    
    brown.amplitude = data.brownianAmplitude
    pink.amplitude = data.pinkAmplitude
    white.amplitude = data.whiteAmplitude
    
    brown.start()
    pink.start()
    white.start()
    
    engine.output = mixer
  }
}

struct NoiseGeneratorsView: View {
  @StateObject var conductor = NoiseGeneratorsConductor()
  
  var body: some View {
    VStack {
      HStack {
        CookbookKnob(
          text: "Brownian",
          parameter: $conductor.data.brownianAmplitude,
          range: 0...1
        )
        CookbookKnob(
          text: "Pink",
          parameter: $conductor.data.pinkAmplitude,
          range: 0...1
        )
        CookbookKnob(
          text: "white",
          parameter: $conductor.data.whiteAmplitude,
          range: 0...1
        )
      }
      .padding(5)
      Spacer()
      NodeOutputView(conductor.mixer)
        .frame(height: 300)
      Spacer()
    }
    .navigationTitle("Noise Generators")
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
  }
}

#Preview {
  NoiseGeneratorsView()
}
