//
//  BasicOscillatorConductor.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/17/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

protocol HasAmplitudeAndFrequency: Node {
  var amplitude: AUValue { get set }
  var frequency: AUValue { get set }
}

extension MorphingOscillator: HasAmplitudeAndFrequency {}
extension Oscillator: HasAmplitudeAndFrequency {}
extension PhaseDistortionOscillator: HasAmplitudeAndFrequency {}
extension PWMOscillator: HasAmplitudeAndFrequency {}

class BasicOscillatorConductor<OSC: HasAmplitudeAndFrequency>: ObservableObject, HasAudioEngine {
  var engine = AudioEngine()
  var osc: OSC
  
  @Published var isPlaying: Bool = false {
    didSet { isPlaying ? osc.start() : osc.stop() }
  }
  
  init(osc: OSC) {
    self.osc = osc
    osc.amplitude = 0.25
    engine.output = self.osc
    
    osc.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
  
  func noteOn(pitch: Pitch, point _: CGPoint) {
    isPlaying = true
    osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
  }
  
  func noteOff(pitch _: Pitch) {
    isPlaying = false
  }
}

struct BasicOscillatorView<OSC: HasAmplitudeAndFrequency>: View {
  let navigationTitle: String
  @StateObject var conductor: BasicOscillatorConductor<OSC>
  @Environment(\.colorScheme) var colorScheme
  
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
      .padding(.horizontal, 10)
      
      HStack {
        ForEach(conductor.osc.parameters) {
          if $0.def.name == "Amplitude" {
            ParameterRow(param: $0, customRange: 0...3.0)
          } else {
            ParameterRow(param: $0)
          }
        }
      }
      .padding(.horizontal, 10)
      
      NodeOutputView(conductor.osc)
      
      ZStack {
        if colorScheme == .dark {
          Color.clear
        } else {
          Color(white: 0.9)
        }
        CookbookKeyboard(
          noteOn: conductor.noteOn,
          noteOff: conductor.noteOff,
          pitchRange: Pitch(50)...Pitch(66)
        )
      }
    }
    .navigationTitle(navigationTitle)
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
    
  }
}
