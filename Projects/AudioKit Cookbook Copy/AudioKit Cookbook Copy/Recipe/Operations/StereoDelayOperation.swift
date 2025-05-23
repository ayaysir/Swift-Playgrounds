//
//  StereoDelayOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/23/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SporthAudioKit
import SwiftUI

struct StereoDelayOperationData {
  // Time: 해당 시간만큼 Delay됨
  // Feedback: 딜레이 효과의 크기
  
  var leftTime: AUValue = 0.2
  var leftFeedback: AUValue = 0.5
  var rightTime: AUValue = 0.01
  var rightFeedback: AUValue = 0.9
}

class StereoDelayOperationConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let buffer: AVAudioPCMBuffer
  let effect: OperationEffect
  
  @Published var data = StereoDelayOperationData() {
    didSet {
      effect.parameter1 = data.leftTime
      effect.parameter2 = data.leftFeedback
      effect.parameter3 = data.rightTime
      effect.parameter4 = data.rightFeedback
    }
  }
  
  init() {
    buffer = Cookbook.sourceBuffer(source: "Female Voice")
    player.buffer = buffer
    player.isLooping = true
    
    effect = OperationEffect(player, channelCount: 2) { _, params in
      let leftDelay = Operation.leftInput.variableDelay(
        time: params.n(1),
        feedback: params.n(2)
      )
      let rightDelay = Operation.rightInput.variableDelay(
        time: params.n(3),
        feedback: params.n(4)
      )
      
      return [leftDelay, rightDelay]
    }
    
    effect.parameter1 = data.leftTime
    effect.parameter2 = data.leftFeedback
    effect.parameter3 = data.rightTime
    effect.parameter4 = data.rightFeedback
    
    engine.output = effect
  }
}

struct StereoDelayOperationView: View {
  @StateObject private var conductor = StereoDelayOperationConductor()
  
  var body: some View {
    VStack {
      PlayerControls(conductor: conductor, sourceName: "Female Voice")
      HStack(spacing: 20) {
        CookbookKnob(
          text: "Left Time",
          parameter: self.$conductor.data.leftTime,
          range: 0 ... 0.3,
          units: "Seconds"
        )
        CookbookKnob(
          text: "Left Feedback",
          parameter: self.$conductor.data.leftFeedback,
          range: 0 ... 1,
          units: "%"
        )
      }
      HStack(spacing: 20) {
        CookbookKnob(
          text: "Right Time",
          parameter: self.$conductor.data.rightTime,
          range: 0 ... 0.3,
          units: "Seconds"
        )
        CookbookKnob(
          text: "Right Feedback",
          parameter: self.$conductor.data.rightFeedback,
          range: 0 ... 1,
          units: "%"
        )
      }
      NodeOutputView(conductor.effect)
    }
    .padding()
    .navigationTitle("Stereo Delay Operation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  StereoDelayOperationView()
}
