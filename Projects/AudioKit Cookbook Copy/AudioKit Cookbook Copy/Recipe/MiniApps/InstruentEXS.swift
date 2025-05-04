//
//  InstruentEXS.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/4/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

/**
 1. 오디오 엔진, 악기(애플 샘플러) 추가
 2. 샘플러 loadInstrument: sawPiano1.exs 지정
 3. 그래프 뷰 표시할 노드로 샘플러 지정, 키보드 on, off 이벤트 지정
 */
class InstruentEXSConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var instrument = AppleSampler()
  
  func noteOn(pitch: Pitch, point _: CGPoint) {
    instrument.play(
      noteNumber: MIDINoteNumber(pitch.midiNoteNumber),
      velocity: 90,
      channel: 0
    )
  }
  
  func noteOff(pitch: Pitch) {
    instrument.stop(
      noteNumber: MIDINoteNumber(pitch.midiNoteNumber),
      channel: 0
    )
  }
  
  init() {
    engine.output = instrument
    
    // Load EXS file (you can also load SoundFonts and WAV files too using the AppleSampler Class)
    do {
      if let fileURL = Bundle.main.url(
        forResource: "Sounds/Sampler Instruments/sawPiano1",
        withExtension: "exs"
      ) {
        try instrument.loadInstrument(url: fileURL)
      } else {
        Log("Could not find file.")
      }
    } catch {
      Log("Could not load instrument:", error)
    }
  }
}

struct InstrumentEXSView: View {
  @StateObject var conductor = InstruentEXSConductor()
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    VStack {
      NodeOutputView(conductor.instrument)
      CookbookKeyboard(noteOn: conductor.noteOn, noteOff: conductor.noteOff)
    }
    .navigationTitle("Instrument EXS")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
    .background(
      colorScheme == .dark ? Color.clear : Color(
        red: 0.9,
        green: 0.9,
        blue: 0.9
      )
    )
  }
}

#Preview {
  InstrumentEXSView()
}
