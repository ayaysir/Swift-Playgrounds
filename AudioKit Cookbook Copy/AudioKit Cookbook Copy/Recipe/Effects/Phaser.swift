//
//  Phaser.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/10/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class PhaserConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .strings
  
  let phaser: Phaser
  
  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    phaser = Phaser(player)
    dryWetMixer = DryWetMixer(player, phaser)
    dryWetMixer.parameters[0].value = 1
    engine.output = dryWetMixer
    
    /*
     Phaser의 파라미터 값:
     
     Min notch frequency | 100.0 | 20.0...5000.0
     Max notch frequency | 800.0 | 20.0...10000.0
     Notch width | 1000.0 | 10.0...5000.0
     Notch frequency | 1.5 | 1.1...4.0
     Vibrato mode | 1.0 | 0.0...1.0
     Depth | 1.0 | 0.0...1.0
     Feedback | 0.0 | 0.0...1.0
     Inversion | 0.0 | 0.0...1.0
     LFO Frequency | 30.0 | 24.0...360.0
     */
    
    phaser.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct PhaserView: View {
  @StateObject private var conductor = PhaserConductor()
  
  let columnsCount: Int = 5
  let columnsMargin: CGFloat = 10
  
  // 화면을 그리드형식으로 꽉채워줌
  var columns: [GridItem] {
    (1...columnsCount).map { _ in GridItem(.flexible(), spacing: columnsMargin) }
  }
  
  var body: some View {
    VStack {
      LazyVGrid(columns: columns, spacing: columnsMargin) {
        ForEach(conductor.phaser.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      
      ScrollView {
        PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
        
        DryWetMixView(
          dry: conductor.player,
          wet: conductor.phaser,
          mix: conductor.dryWetMixer
        )
      }
    }
    .padding()
    .navigationTitle("Phaser")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  PhaserView()
}
