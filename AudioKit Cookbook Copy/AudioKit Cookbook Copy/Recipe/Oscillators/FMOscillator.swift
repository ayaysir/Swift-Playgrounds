//
//  FMOscillator.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/16/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI

struct FMOscillatorPreset: Hashable {
  var name: String
  var baseFrequency: AUValue
  var carrierMultiplier: AUValue
  var modulatingMultiplier: AUValue
  var modulationIndex: AUValue
}

class FMOscillatorConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let osc = FMOscillator()
  
  @Published var isPlaying: Bool = false {
    didSet { isPlaying ? osc.start() : osc.stop() }
  }
  
  init() {
    osc.amplitude = 0.5
    engine.output = osc
    
    /*
     Base Frequency | 440.0 | 0.0...20000.0
     Carrier Multiplier | 1.0 | 0.0...1000.0
     Modulating Multiplier | 1.0 | 0.0...1000.0
     Modulation Index | 1.0 | 0.0...1000.0
     Amplitude | 0.5 | 0.0...10.0
     */
    
    self.osc.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
  
  func apply(preset: FMOscillatorPreset) {
    isPlaying = true
    
    osc.baseFrequency = preset.baseFrequency
    osc.carrierMultiplier = preset.carrierMultiplier
    osc.modulatingMultiplier = preset.modulatingMultiplier
    osc.modulationIndex = preset.modulationIndex
  }
  
  func applyRandom() {
    let randomPreset = FMOscillatorPreset(
      name: "Random",
      baseFrequency: .random(in: 0 ... 800),
      carrierMultiplier: .random(in: 0 ... 20),
      modulatingMultiplier: .random(in: 0 ... 20),
      modulationIndex: .random(in: 0 ... 100)
    )
    apply(preset: randomPreset)
  }
}

struct FMOscillatorView: View {
  @StateObject private var conductor = FMOscillatorConductor()
  @State var currentPresetName = ""
  @State var forceRefresh = 0
  
  let columnsCount: Int = 3
  let columnsMargin: CGFloat = 10
  
  var columns: [GridItem] {
    (1...columnsCount).map { _ in GridItem(.flexible(), spacing: columnsMargin) }
  }
  
  var body: some View {
    VStack {
      Button {
        conductor.isPlaying.toggle()
      } label: {
        Text(conductor.isPlaying ? "STOP" : "START")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .tint(.teal)
      
      LazyVGrid(columns: columns, spacing: columnsMargin) {
        ForEach(conductor.presets, id: \.self) { preset in
          Button {
            conductor.apply(preset: preset)
            currentPresetName = preset.name
            forceRefresh += 1
          } label: {
            Text(preset.name)
              .frame(maxWidth: .infinity)
          }
          .tagStyle(currentPresetName == preset.name ? .prominent : .bordered)
        }
        Button {
          conductor.applyRandom()
          currentPresetName = "Random"
          forceRefresh += 1
        } label: {
          Text("Random")
            .frame(maxWidth: .infinity)
        }
        .tagStyle(currentPresetName == "Random" ? .prominent : .bordered)
      }
      .tint(.pink)
      
      HStack {
        ParameterRow(param: conductor.osc.parameters[0])
        ParameterRow(param: conductor.osc.parameters[1], customRange: 0 ... 500)
        ParameterRow(param: conductor.osc.parameters[2], customRange: 0 ... 50)
        ParameterRow(param: conductor.osc.parameters[3], customRange: 0 ... 200)
        ParameterRow(param: conductor.osc.parameters[4])
      }
      .id(forceRefresh)
      
      NodeOutputView(conductor.osc)
    }
    .padding()
    .navigationTitle("FM Oscillator")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

extension FMOscillatorConductor {
  var presets: [FMOscillatorPreset] {
    [
      .init(
        name: "Stun Ray",
        baseFrequency: 200,
        carrierMultiplier: 90,
        modulatingMultiplier: 10,
        modulationIndex: 25
      ),
      .init(
        name: "Fog Horn",
        baseFrequency: 25,
        carrierMultiplier: 10,
        modulatingMultiplier: 5,
        modulationIndex: 10
      ),
      .init(
        name: "Buzzer",
        baseFrequency: 400,
        carrierMultiplier: 28,
        modulatingMultiplier: 0.5,
        modulationIndex: 100
      ),
      .init(
        name: "Spiral",
        baseFrequency: 5,
        carrierMultiplier: 280,
        modulatingMultiplier: 0.2,
        modulationIndex: 100
      ),
      .init(
        name: "Wobble",
        baseFrequency: 20,
        carrierMultiplier: 10,
        modulatingMultiplier: 0.9,
        modulationIndex: 20
      ),
    ]
  }
}

#Preview {
  FMOscillatorView()
}
