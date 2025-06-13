//
//  AppleDistortion.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/13/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class AppleDistortionConductor: BasicEffectConductor<AppleDistortion> {
  init() {
    super.init(source: .piano, isUseDryWetMixer: true) { input in
      let distortion = AppleDistortion(input) // from AudioKit
      distortion.loadFactoryPreset(.multiDistortedCubed)
      
      // We're not using distortion's built in dry wet mix because
      // we are tapping the wet result so it can be plotted.
      distortion.dryWetMix = 100
      return distortion
    }
  }
  
  @Published var preGain: AUValue = -6.0 {
    didSet { effect.preGain = preGain }
  }
  
  /*
   AVAudioUnitDistortionPreset 목록:
   
   Drums Bit Brush
   Drums Buffer Beats
   Drums LoFi
   Multi-Broken Speaker
   Multi-Cellphone Concert
   Multi-Decimated 1
   Multi-Decimated 2
   Multi-Decimated 3
   Multi-Decimated 4
   Multi-Distorted Funk
   Multi-Distorted Cubed
   Multi-Distorted Squared
   Multi-Echo 1
   Multi-Echo 2
   Multi-Echo Tight 1
   Multi-Echo Tight 2
   Multi-Everything Is Broken
   Speech Alien Chatter
   Speech Cosmic Interference
   Speech Golden Pi
   Speech Radio Tower
   Speech Waves
   */
}

struct AppleDistortionView: View {
  @StateObject private var conductor = AppleDistortionConductor()
  @State private var currentPreset = 0
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      PresetSelector
      ParametersArea
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.effect,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Apple Distortion")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
    .onChange(of: currentPreset) {
      conductor.effect.loadFactoryPreset(factoryPreset)
    }
  }
  
  private var factoryPreset: AVAudioUnitDistortionPreset {
    AVAudioUnitDistortionPreset(rawValue: currentPreset) ?? .drumsBitBrush
  }
  
  private var PresetSelector: some View {
    HStack {
      Button {
        currentPreset = currentPreset - 1 < 0 ? 21 : currentPreset - 1
      } label: {
        Image(systemName: "arrowtriangle.backward.fill")
          .foregroundColor(.teal)
      }
      // Text("\(factoryPreset.rawValue + 1). \(factoryPreset.name)")
      Picker("Factory Presets", selection: $currentPreset) {
        ForEach(0..<22) { i in
          Text("\(i + 1). \(AVAudioUnitDistortionPreset(rawValue: i)?.name ?? "Unknown")")
            .tag(i)
        }
      }
      .tint(.black)
      Button {
        currentPreset = (currentPreset + 1) % 22
      } label: {
        Image(systemName: "arrowtriangle.forward.fill")
          .foregroundColor(.teal)
      }
    }
  }
  
  private var ParametersArea: some View {
    HStack {
      ForEach(conductor.effect.parameters) {
        ParameterRow(param: $0)
      }
      CookbookKnob(text: "Pre-Gain", parameter: $conductor.preGain, range: -20...20)
      ParameterRow(param: conductor.dryWetMixer.parameters[0])
    }
  }
}

#Preview {
  AppleDistortionView()
}

/*
 // It's very common to mix exactly two inputs, one before processing occurs,
 // and one after, resulting in a combination of the two.  This is so common
 // that many of the AudioKit nodes have a dry/wet mix parameter built in.
 //  But, if you are building your own custom effects, or making a long chain
 // of effects, you can use DryWetMixer to blend your signals.
 
 // 두 개의 입력을 정확히 믹싱하는 것은 매우 흔한 일입니다. 하나는 처리 전, 다른 하나는 처리 후, 그 결과 두 입력이 결합된 결과가 생성됩니다.
 // 이는 매우 일반적이어서
 // 많은 AudioKit 노드에 드라이/웻 믹스 매개변수가 내장되어 있습니다.
 // 하지만 직접 커스텀 효과를 만들거나 긴 효과 체인을 만드는 경우
 // DryWetMixer를 사용하여 신호를 믹싱할 수 있습니다.
 */
