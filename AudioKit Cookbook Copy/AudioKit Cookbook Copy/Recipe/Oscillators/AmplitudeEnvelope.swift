//
//  AmplitudeEnvelope.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/16/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import AVFoundation
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class AmplitudeEnvelopeConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine() // AudioKit
  var oscillator: Oscillator // SoundpipeAudioKit
  var envelope: AmplitudeEnvelope // SoundpipeAudioKit
  var fader: Fader // AudioKitEX
  var currentNote = 0
  
  // MARK: - Init
  
  init() {
    oscillator = Oscillator()
    envelope = AmplitudeEnvelope(oscillator)
    fader = Fader(envelope)
    oscillator.amplitude = 1.0
    engine.output = fader
  }
  
  // MARK: - Note On/Off
  
  func noteOn(pitch: Pitch, point _: CGPoint) {
    if pitch.midiNoteNumber != currentNote {
      envelope.closeGate()
    }
    
    oscillator.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
    envelope.openGate()
  }
  
  func noteOff(pitch _: Pitch) {
    envelope.closeGate()
  }
  
  // MARK: - Engine Start/Stop
  
  func start() {
    oscillator.start()
    do {
      try engine.start()
    } catch {
      Log(error)
    }
  }
  
  func stop() {
    oscillator.stop()
    engine.stop()
  }
}

struct AmplitudeEnvelopeView: View {
  @StateObject var conductor = AmplitudeEnvelopeConductor()
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    VStack {
      Text("Attack, Decay 부분은 오른쪽 가장자리를 드래그하여 조절하고, Sustain, Release 부분은 왼쪽 가장자리를 드래그하여 높이를 조절합니다.")
        .font(.caption2)
      
      #if os(iOS)
      ADSRWidget { a, d, s, r in
        conductor.envelope.attackDuration = a
        conductor.envelope.decayDuration = d
        conductor.envelope.sustainLevel = s
        conductor.envelope.releaseDuration = r
      }
      .frame(maxWidth: UIScreen.main.bounds.width)
      #elseif os(macOS)
      Text("⚠️ macOS에서는 ADSRWidget을 지원하지 않습니다.")
        .frame(height: 200)
      #endif
      
      HStack {
        Text("Attack")
          .foregroundStyle(.red)
        Spacer()
        Text("Decay")
          .foregroundStyle(.orange)
        Spacer()
        Text("Sustain")
          .foregroundStyle(Color(red: 0.32, green: 0.8, blue: 0.616))
        Spacer()
        Text("Release")
          .foregroundStyle(.purple)
      }
      .font(.system(size: 12, weight: .bold))
      .padding(10)
      .frame(height: 10)
      
      NodeRollingView(conductor.fader, color: .pink)
      ZStack {
        if colorScheme == .dark {
          Color.clear
        } else {
          Color(white: 0.9)
        }
        CookbookKeyboard(noteOn: conductor.noteOn, noteOff: conductor.noteOff)
      }
    }
    .padding(0)
    .navigationTitle("Amplitude Envelope")
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
  }
}

#Preview {
  AmplitudeEnvelopeView()
}

/*
 //: ## Amplitude Envelope
 //: ## 진폭 엔벨로프
 
 //: A surprising amount of character can be added to a sound by changing its amplitude over time.
 //: 시간이 지남에 따라 진폭을 변화시키면 소리에 놀라울 정도로 많은 개성을 더할 수 있습니다.
 
 //: A very common means of defining the shape of amplitude is to use an ADSR envelope which stands for
 //: 진폭의 형태를 정의하는 매우 일반적인 방법은 ADSR 엔벨로프를 사용하는 것입니다. 이는
 
 //: Attack, Sustain, Decay, Release.
 //: 어택(Attack), 서스테인(Sustain), 디케이(Decay), 릴리스(Release)의 약자입니다.
 
 //: * Attack is the amount of time it takes a sound to reach its maximum volume.  An example of a fast attack is a
 //: * 어택은 소리가 최대 음량에 도달하는 데 걸리는 시간입니다. 빠른 어택의 예로는
 
 //:   piano, where as a cello can have a longer attack time.
 //: 피아노가 있고, 첼로는 더 긴 어택 시간을 가질 수 있습니다.
 
 //: * Decay is the amount of time after which the peak amplitude is reached for a lower amplitude to arrive.
 //: * 디케이는 피크 진폭에 도달한 후 더 낮은 진폭이 도달하는 데 걸리는 시간입니다.
 
 //: * Sustain is not a time, but a percentage of the peak amplitude that will be the the sustained amplitude.
 //: * 서스테인은 시간이 아니라, 피크 진폭 대비 지속되는 진폭의 백분율입니다.
 
 //: * Release is the amount of time after a note is let go for the sound to die away to zero.
 //: * 릴리스는 건반에서 손을 뗀 후 소리가 0으로 사라질 때까지 걸리는 시간입니다.
 */
