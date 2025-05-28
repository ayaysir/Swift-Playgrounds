//
//  PluckedString.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/27/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class PluckedStringConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let pluckedString = PluckedString() // SoundPipeAudioKit
  let pluckedString2 = PluckedString()
  var delay: Delay
  var reverb: Reverb!
  var loop: CallbackLoop!
  
  // 초당 3번 루프가 반복됨을 의미 (Hz)
  @Published var playRate: AUValue = 3.0 {
    didSet { loop.frequency = Double(playRate) }
  }
  @Published var isRunning = false {
    didSet { isRunning ? loop.start() : loop.stop() }
  }
  @Published var delayDryWetMix: AUValue = 0.7 {
    didSet { delay.dryWetMix = delayDryWetMix }
  }
  @Published var delayFeedback: AUValue = 0.9 {
    didSet { delay.feedback = delayFeedback }
  }
  @Published var reverbDryWetMix: AUValue = 0.9 {
    didSet { reverb.dryWetMix = reverbDryWetMix }
  }
  @Published var scale = [60, 62, 64, 66, 67, 69, 71] {
    didSet { loop.frequency = Double(playRate) }
  }
  @Published var transpose: Int = 0 {
    didSet { loop.frequency = Double(playRate) }
  }
  
  var transposedScale: [Int] {
    scale.map { $0 + Int(transpose) }
  }

  init() {
    let mixer = DryWetMixer(pluckedString, pluckedString2)
    delay = Delay(mixer)
    delay.time = AUValue(1.5 / playRate) // 1.5/3.0 => 약 0.5초 딜레이
    delay.dryWetMix = 0.7
    delay.feedback = 0.9 // 반복된 신호의 강도가 강함 (잔향 길어짐)
    reverb = Reverb(delay)
    reverb.dryWetMix = 0.9
    engine.output = reverb
  }
  
  func start() {
    do {
      try engine.start()
      loop = CallbackLoop(frequency: Double(playRate)) { [unowned self] in
        let note1 = Int.random(in: 0..<scale.count)
        let note2 = Int.random(in: 0..<scale.count)
        let newAmp = AUValue.random(in: 0.0...1.0)
        
        pluckedString.frequency = transposedScale[note1].midiNoteToFrequency()
        pluckedString.amplitude = newAmp
        pluckedString2.frequency = transposedScale[note2].midiNoteToFrequency()
        pluckedString2.amplitude = newAmp
        
        if AUValue.random(in: 0.0...1.0) > 0.5 {
          pluckedString.trigger()
          pluckedString2.trigger()
        }
      }
    } catch {
      Log(error)
    }
  }
  
  func stop() {
    engine.stop()
    loop.stop()
  }
}

struct PluckedStringView: View {
  @StateObject private var conductor = PluckedStringConductor()
  
  var body: some View {
    VStack {
      Button(conductor.isRunning ? "STOP" : "START") {
        conductor.isRunning.toggle()
      }
      .buttonStyle(.borderedProminent)
      HStack {
        CookbookKnob(
          text: "playRate\n(BPM \(String(format: "%.1f", conductor.playRate * 60)))",
          parameter: $conductor.playRate,
          range: 1.0...10.0,
          units: "Hz"
        )
        CookbookKnob(
          text: "delayDryWetMix",
          parameter: $conductor.delayDryWetMix,
          range: 0.0...1,
          units: "%"
        )
        CookbookKnob(
          text: "delayFeedback",
          parameter: $conductor.delayFeedback,
          range: 0.0...1,
          units: "%"
        )
        CookbookKnob(
          text: "reverbDryWetMix",
          parameter: $conductor.reverbDryWetMix,
          range: 0.0...1,
          units: "%"
        )
      }
      .padding()
      Stepper(
        "Transpose \(conductor.transpose > 0 ? "+" : "")\(conductor.transpose)",
        value: $conductor.transpose,
        in: -11...11,
        step: 1
      )
      Self.ScalePicker(selection: $conductor.scale)
      NodeOutputView(conductor.reverb)
    }
    .padding()
    .navigationTitle("Plucked String")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
  
  static func ScalePicker<SelectionValue: Hashable>(selection: Binding<SelectionValue>) -> some View {
    Picker("Scale", selection: selection) {
      Text("Lydian").tag([60, 62, 64, 66, 67, 69, 71])
      Text("Double Harmonic Scale").tag([60, 61, 64, 65, 67, 68, 71])
      Text("Blues Scale").tag([60, 63, 65, 66, 67, 70])
      Text("Whole Tone Scale").tag([60, 62, 64, 66, 68, 70])
      Text("Gypsy Scale").tag([60, 62, 63, 66, 67, 68, 70])
      Text("Insen Scale").tag([60, 61, 65, 67, 70])
      Text("Major Petantatonic").tag([60, 62, 64, 67, 69])
      Text("Minor Petantatonic").tag([60, 63, 65, 67, 70])
      Text("Major/Ionian").tag([60, 62, 64, 65, 67, 69, 71])
      Text("Minor/Aeolian").tag([60, 62, 63, 65, 67, 68, 70])
      Text("Harmonic Minor").tag([60, 62, 63, 65, 67, 68, 71])
      Text("Melodic Minor").tag([60, 62, 63, 65, 67, 69, 71])
      Text("Dorian").tag([60, 62, 63, 65, 67, 69, 70])
      Text("Phrygian").tag([60, 61, 63, 65, 67, 68, 70])
      Text("Mixolydian").tag([60, 62, 64, 65, 67, 69, 70])
      Text("Locrian").tag([60, 61, 63, 65, 66, 68, 70])
      Text("Chromatic Scale").tag(Array(60...71))
    }
  }
}



#Preview {
  PluckedStringView()
}
