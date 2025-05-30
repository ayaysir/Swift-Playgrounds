//
//  VariableDelayOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/25/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SporthAudioKit
import SwiftUI

struct VariableDelayOperationData {
  var maxTime: AUValue = 0.2
  var frequency: AUValue = 0.3
  var feedbackFrequency: AUValue = 0.21
  var rampDuration: AUValue = 0.1
  var balance: AUValue = 0.5
}

class VariableDelayOperationConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let delay: OperationEffect
  
  init() {
    buffer = Cookbook.sourceBuffer(source: .piano)
    player.buffer = buffer
    player.isLooping = true
    
    defer {
      delay.parameter1 = 0.2
      delay.parameter2 = 0.3
      delay.parameter3 = 0.21
    }
    
    delay = OperationEffect(player) { player, params in
      let time = Operation.sineWave(frequency: params.n(2))
        .scale(minimum: 0.001, maximum: params.n(1))
      let feedback = Operation.sineWave(frequency: params.n(3))
        .scale(minimum: 0.5, maximum: 0.9)
      return player.variableDelay(
        time: time,
        feedback: feedback,
        maximumDelayTime: 1.0
      )
    }
    
    dryWetMixer = DryWetMixer(player, delay)
    engine.output = dryWetMixer
  }
  
  @Published var data = VariableDelayOperationData() {
    didSet {
      // Max Time(s): 0...0.3
      delay.$parameter1.ramp(to: data.maxTime, duration: data.rampDuration)
      // Frequency(Hz): 0...1
      delay.$parameter2.ramp(to: data.frequency, duration: data.rampDuration)
      // Feedback Frequency(Hz): 0...1
      delay.$parameter3.ramp(to: data.feedbackFrequency, duration: data.rampDuration)
      // Dry/Wet Mix(%): 0...1
      dryWetMixer.balance = data.balance
    }
  }
}

struct VariableDelayOperationView: View {
  @StateObject private var conductor = VariableDelayOperationConductor()
  
  var body: some View {
    VStack {
      PlayerControls(conductor: conductor, sourceName: "Piano")
      HStack(spacing: 20) {
        CookbookKnob(
          text: "Max Time",
          parameter: $conductor.data.maxTime,
          range: 0...0.3,
          units: "s"
        )
        CookbookKnob(
          text: "Frequency",
          parameter: $conductor.data.frequency,
          range: 0...1,
          units: "Hz"
        )
        CookbookKnob(
          text: "Feedback Frequency",
          parameter: $conductor.data.feedbackFrequency,
          range: 0...1,
          units: "Hz"
        )
        CookbookKnob(
          text: "Dry/Wet Mix",
          parameter: $conductor.data.balance,
          range: 0...1,
          units: "%"
        )
      }
      NodeOutputView(conductor.dryWetMixer)
    }
    .padding()
    .navigationTitle("Variable Delay Operation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  VariableDelayOperationView()
}
