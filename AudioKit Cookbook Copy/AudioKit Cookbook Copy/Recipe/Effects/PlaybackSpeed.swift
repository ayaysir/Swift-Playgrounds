//
//  PlaybackSpeed.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/10/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

// This recipe uses the VariSpeed node to change the playback speed of a file (which also affects the pitch)

class PlaybackSpeedConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  let variSpeed: VariSpeed
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    // VariSpeed: 피치도 함께 변하는 재생 속도 조절 (Variable Speed)
    variSpeed = VariSpeed(player)
    variSpeed.rate = 2.0
    engine.output = variSpeed
  }
  
  @Published var rate: AUValue = 2.0 {
    didSet { variSpeed.rate = rate }
  }
}

struct PlaybackSpeedView: View {
  @StateObject private var conductor = PlaybackSpeedConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      CookbookKnob(
        text: "Rate",
        parameter: $conductor.rate,
        range: 0.3125...5,
        units: "Generic"
      )
      NodeRollingView(conductor.variSpeed)
    }
    .padding()
    .navigationTitle("Playback Speed")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  PlaybackSpeedView()
}
