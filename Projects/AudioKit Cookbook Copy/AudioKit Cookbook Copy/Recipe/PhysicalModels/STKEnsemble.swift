//
//  STKEnsemble.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/27/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import STKAudioKit
import SwiftUI

class STKEnsembleConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let flute = Flute()
  let clarinet = Clarinet()
  let bells = TubularBells()
  var fluteFader, clarinetFader, bellsFader: Fader!
  var mixer: Mixer
  var loop: CallbackLoop!

  init() {
    fluteFader = Fader(flute)
    clarinetFader = Fader(clarinet)
    bellsFader = Fader(bells)
    
    mixer = Mixer(fluteFader, clarinetFader, bellsFader)
    
    fluteFader.gain = fluteGain
    clarinetFader.gain = clarinetGain
    bellsFader.gain = bellsGain
    
    engine.output = mixer
  }
  
  func random(_ probability: Double) -> Bool {
    Double.random(in: 0.0...1.0) < probability
  }
  
  func randomVelocity(range: ClosedRange<AUValue> = 30...100) -> MIDIVelocity {
    MIDIVelocity(.random(in: range))
  }
  
  private func stopAllInstruments() {
    flute.stop()
    clarinet.stop()
    bells.stop()
    playingNotes = [0, 0, 0]
  }
  
  func start() {
    do {
      try engine.start()
      
      loop = CallbackLoop(frequency: Double(playRate)) { [unowned self] in
        let note1 = Int.random(in: 0..<scale.count)
        let note2 = Int.random(in: 0..<scale.count)
        let note3 = Int.random(in: 0..<scale.count)
        
        if random(0.01) {
          stopAllInstruments()
          return
        }
        
        if random(0.35) {
          clarinet.trigger(
            note: MIDINoteNumber(transposedScale[note1]),
            velocity: randomVelocity(range: 30...60)
          )
          playingNotes[0] = transposedScale[note1]
        }
        
        if random(0.45) {
          flute.trigger(
            note: MIDINoteNumber(transposedScale[note2] + 12),
            velocity: randomVelocity()
          )
          playingNotes[1] = transposedScale[note2]
        }
        
        if random(0.8) {
          bells.trigger(
            note: MIDINoteNumber(transposedScale[note3] + 24),
            velocity: randomVelocity()
          )
          playingNotes[2] = transposedScale[note3]
        }
      }
    } catch {
      Log(error)
    }
  }
  
  var transposedScale: [Int] {
    let baseScale = scale.map { $0 + Int(transpose) }
    let downScale = baseScale.map { $0 - 12 }
    let upScale = baseScale.map { $0 + 12 }
    
    let half = scale.count / 2
    
    let downTail = Array(downScale.suffix(half))
    let upHead = Array(upScale.prefix(half))
    
    return downTail + baseScale + upHead
  }
  
  @Published var isRunning = false {
    didSet {
      if isRunning {
        loop.start()
      } else {
        stopAllInstruments()
        loop.stop()
      }
    }
  }
  
  @Published var playRate: AUValue = 1.67 {
    didSet { loop.frequency = Double(playRate) }
  }
  @Published var scale = [60, 62, 64, 66, 67, 69, 71] {
    didSet { loop.frequency = Double(playRate) }
  }
  @Published var transpose: Int = 0 {
    didSet { loop.frequency = Double(playRate) }
  }
  @Published var fluteGain: AUValue = 0.8 {
    didSet { fluteFader.gain = fluteGain }
  }
  @Published var clarinetGain: AUValue = 0.6 {
    didSet { clarinetFader.gain = clarinetGain }
  }
  @Published var bellsGain: AUValue = 1.0 {
    didSet { bellsFader.gain = bellsGain }
  }
  @Published var playingNotes: [Int] = [0, 0, 0]
  var playingNotesText: String {
    "Fl: \(playingNotes[0])\tCl: \(playingNotes[1])\tBls: \(playingNotes[2])"
  }
}

struct STKEnsembleView: View {
  @StateObject private var conductor = STKEnsembleConductor()
  
  var body: some View {
    VStack {
      HStack {
        Text(conductor.playingNotesText)
        Spacer()
        Button(conductor.isRunning ? "STOP" : "START") {
          conductor.isRunning.toggle()
        }
      }
      HStack {
        CookbookKnob(
          text: "playRate\n(BPM \(String(format: "%.1f", conductor.playRate * 60)))",
          parameter: $conductor.playRate,
          range: 1.0...5.0,
          units: "Hz"
        )
        CookbookKnob(
          text: "Flute Gain",
          parameter: $conductor.fluteGain,
          range: 0.0...1.0,
          units: "%"
        )
        CookbookKnob(
          text: "Clarinet Gain",
          parameter: $conductor.clarinetGain,
          range: 0.0...1.0,
          units: "%"
        )
        CookbookKnob(
          text: "Bells Gain",
          parameter: $conductor.bellsGain,
          range: 0.0...1.0,
          units: "%"
        )
      }
      Stepper(
        "Transpose \(conductor.transpose > 0 ? "+" : "")\(conductor.transpose)",
        value: $conductor.transpose,
        in: -11...11,
        step: 1
      )
      PluckedStringView.ScalePicker(selection: $conductor.scale)
      NodeOutputView(conductor.fluteFader)
      NodeOutputView(conductor.clarinetFader)
      NodeOutputView(conductor.bellsFader)
      NodeOutputView(conductor.mixer)
    }
    .padding()
    .navigationTitle("STK Ensemble")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
      
    }
  }
}

#Preview {
  STKEnsembleView()
}
