//
//  GraphicEqualizer.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/3/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct GraphicEqualizerData {
  private var gains: [AUValue] = Array(repeating: 1.0, count: 6)
  
  subscript(_ index: Int) -> AUValue {
    get {
      1...6 ~= index ? gains[index - 1] : 0
    }
    set {
      1...6 ~= index ? gains[index - 1] = newValue : nil
    }
  }
}

class GraphicEqualizerConductor: ObservableObject, ProcessesPlayerInput {
  let fader: Fader
  
  let engine = AudioEngine()
  let player = AudioPlayer()
  let buffer: AVAudioPCMBuffer
  
  var filterBands: [EqualizerFilter] = []
  
  @Published var data = GraphicEqualizerData() {
    didSet {
      for i in 1...6 {
        filterBands[i].gain = data[i]
      }
    }
  }
  
  init() {
    buffer = Cookbook.sourceBuffer
    player.buffer = buffer
    player.isLooping = true
    
    let centerFrequencies: [AUValue] = [32, 64, 125, 250, 500, 1_000]
    let bandwidths: [AUValue] = [44.7, 70.8, 141, 282, 562, 1_112]
    
    filterBands.append(EqualizerFilter(player))
    
    for i in 1...6 {
      filterBands
        .append(
          EqualizerFilter(
            i == 1 ? player : filterBands[i - 1],
            centerFrequency: centerFrequencies[i - 1],
            bandwidth: bandwidths[i - 1],
            gain: 1.0
          )
        )
    }
    
    fader = Fader(filterBands[6], gain: 0.4)
    engine.output = fader
  }
}

struct GraphicEqualizerView: View {
  @StateObject private var conductor = GraphicEqualizerConductor()
  
  var body: some View {
    VStack {
      PlayerControls(conductor: conductor)
      
      HStack {
        ForEach(1...6, id: \.self) { index in
          CookbookKnob(text: "Band \(index)", parameter: $conductor.data[index], range: 0...20)
        }
      }
      .padding(5)
      
      FFTView(conductor.fader)
    }
    .navigationTitle("Graphic Equalizer")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  GraphicEqualizerView()
}
