//
//  PolyphonicOscillator.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class PolyphonicOscillatorConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var notes = Array(repeating: 0, count: 11)
  // 주의: oscs = Array(repeating: Oscillator(), count: 11)로 설정하면 모두 같은 Oscillator 클래스를 가리킨다.
  var oscs: [Oscillator] = []
  
  init() {
    for _ in notes.indices {
      let osc = Oscillator()
      osc.amplitude = 0.0
      osc.start()
      oscs.append(osc)
    }
    
    engine.output = Mixer(oscs)
  }
  
  func noteOn(pitch: Pitch, point _: CGPoint) {
    for i in notes.indices where notes[i] == 0 {
      oscs[i].frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
      oscs[i].$amplitude.ramp(to: 1, duration: 0.005)
      notes[i] = pitch.intValue
      break
    }
  }
  
  func noteOff(pitch: Pitch) {
    for i in notes.indices where notes[i] == pitch.intValue {
      oscs[i].$amplitude.ramp(to: 0, duration: 0.005)
      notes[i] = 0
      break
    }
  }
}

struct PolyphonicOscillatorView: View {
  @Environment(\.colorScheme) var colorScheme
  @StateObject private var conductor = PolyphonicOscillatorConductor()
  
  var body: some View {
    VStack {
      if let output = conductor.engine.output {
        NodeOutputView(output)
      }
      CookbookKeyboard(
        noteOn: conductor.noteOn,
        noteOff: conductor.noteOff
      )
    }
    .navigationTitle("Polyphonic Oscillator")
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
    .background(colorScheme == .dark ?
                Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
  }
}

#Preview {
  PolyphonicOscillatorView()
}
