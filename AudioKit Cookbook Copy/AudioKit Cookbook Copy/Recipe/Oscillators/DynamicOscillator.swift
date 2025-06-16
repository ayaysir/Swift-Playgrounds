//
//  DynamicOscillator.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/16/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class DynamicOscillatorConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var osc = DynamicOscillator()
  
  @Published var isPlaying: Bool = false {
    didSet { isPlaying ? osc.start() : osc.stop() }
  }
  
  // MARK: - Init
  
  init() {
    osc.amplitude = 0.2
    osc.setWaveform(Table(.sawtooth))
    engine.output = osc
    
    /*
     DynamicOscillator 파라미터 목록
     
     Frequency | 440.0 | 0.0...20000.0
     Amplitude | 0.2 | 0.0...10.0
     Frequency offset | 0.0 | -1000.0...1000.0
     Frequency detuning multiplier | 1.0 | 0.9...1.11
     */
    
    osc.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
  
  // MARK: - Note On/Off
  
  func noteOn(pitch: Pitch, point _: CGPoint) {
    isPlaying = true
    osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
  }
  
  func noteOff(pitch _: Pitch) {
    isPlaying = false
  }
}

struct DynamicOscillatorView: View {
  @StateObject var conductor = DynamicOscillatorConductor()
  @Environment(\.colorScheme) var colorScheme
  @State private var currentTableType = "Sawtooth"
  
  let types = ["Sine", "Square", "Triangle", "Sawtooth"]
  
  var body: some View {
    VStack {
      HStack {
        Button(conductor.isPlaying ? "STOP" : "START") {
          conductor.isPlaying.toggle()
        }
        .buttonStyle(.bordered)
        .frame(width: 100)
        
        Picker("", selection: $currentTableType) {
          ForEach(types, id: \.self) {
            Text($0)
              .tag($0)
          }
        }
        .pickerStyle(.segmented)
      }
      
      HStack {
        ForEach(conductor.osc.parameters) {
          ParameterRow(param: $0)
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
          pitchRange: Pitch(58)...Pitch(74)
        )
      }
    }
    .navigationTitle("Dynamic Oscillator")
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
    .onChange(of: currentTableType) {
      switch currentTableType {
      case "Sine":
        conductor.osc.setWaveform(Table(.sine))
      case "Square":
        conductor.osc.setWaveform(Table(.square))
      case "Triangle":
        conductor.osc.setWaveform(Table(.triangle))
      case "Sawtooth":
        conductor.osc.setWaveform(Table(.sawtooth))
      default:
        break
      }
    }
  }
}

#Preview {
  DynamicOscillatorView()
}
