//
//  DrumSynthesizers.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/2/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class DrumSynthesizersConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let kick = SynthKick()
  let snare = SynthSnare()
  var reverb: Reverb
  var counter = 0
  
  lazy var loop: CallbackLoop = {
    CallbackLoop(frequency: Double(bpm / 60) * 4) { // Hz
      let randomVelocity = MIDIVelocity(AUValue.random(in: 0...127))
      let onFirstBeat = self.counter % 4 == 0 // 1박자마다 (16비트 4개)
      let everyOtherBeat = self.counter % 8 == 0 // 2박자마다 (16비트 8개)
      let randomHit = self.counter % 2 == 0 && Int.random(in: 0...3) == 0
      
      if onFirstBeat || randomHit  {
        // play kick
        self.kick.play(noteNumber: 60, velocity: randomVelocity)
        self.kick.stop(noteNumber: 60)
      }
      
      if everyOtherBeat {
        // snare
        let velocity = MIDIVelocity(UInt8.random(in: 0...100))
        self.snare.play(noteNumber: 60, velocity: velocity, channel: 0)
        self.snare.stop(noteNumber: 60)
      }
      
      self.counter += 1
    }
  }()
  
  @Published var bpm: Float = 120.0 {
    didSet {
      loop.frequency = Double(bpm) / 60 * 4
    }
  }
  @Published var isRunning = false {
    didSet {
      isRunning ? loop.start() : loop.stop()
    }
  }
  
  init() {
    let mixer = Mixer(kick, snare)
    reverb = Reverb(mixer)
    engine.output = reverb
  }
}

struct DrumSynthesizersView: View {
  @StateObject private var conductor = DrumSynthesizersConductor()
  
  var body: some View {
    VStack {
      CookbookKnob(
        text: "BPM",
        parameter: $conductor.bpm,
        range: 60.0...300.0
      )
      Button(conductor.isRunning ? "Stop" : "Start") {
        self.conductor.isRunning.toggle()
      }
      
      NodeOutputView(conductor.reverb)
    }
    .padding()
    .navigationTitle("Drum Synthesizers")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.isRunning = false
      conductor.stop()
    }
  }
}

#Preview {
  DrumSynthesizersView()
}
