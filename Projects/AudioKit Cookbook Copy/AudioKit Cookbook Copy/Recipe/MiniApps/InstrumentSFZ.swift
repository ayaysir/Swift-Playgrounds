//
//  InstrumentSFZ.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/5/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic
import DunneAudioKit

class InstrumentSFZConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var instrument = Sampler()
  
  func noteOn(pitch: Pitch, point _: CGPoint) {
    instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 90, channel: 0)
  }
  
  func noteOff(pitch: Pitch) {
    instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
  }
  
  init() {
    DispatchQueue.main.async {
      // Load SFZ file with Dunne Sampler.
      // This needs to be loaded after a delay the first time
      // to get the correct Settings.sampleRate if it is 48_000.
      if let fileURL = Bundle.main.url(forResource: "Sounds/sqr", withExtension: "SFZ") {
        self.instrument.loadSFZ(url: fileURL)
      } else {
        Log("Could note find file")
      }
      
      self.instrument.masterVolume = 0.15
    }
    
    engine.output = instrument
  }
}

struct InstrumentSFZView: View {
  @StateObject var conductor = InstrumentSFZConductor()
  @Environment(\.colorScheme) var colorScheme
  // 이 값은 해당 값을 읽는 뷰에서 사용할 수 있는 가로 공간의 크기(사이즈 클래스)를 알려줍니다.
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  @ViewBuilder func paramRows(chunked: [[NodeParameter]]) -> some View {
    ForEach(0..<chunked.count, id: \.self) { chunkIndex in
      HStack {
        ForEach(chunked[chunkIndex], id: \.self) { param in
          ParameterRow(param: param)
            // .simultaneousGesture(DragGesture())
        }
      }
      .padding(5)
    }
  }
  
  var body: some View {
    let instrumentParams = conductor.instrument.parameters
    let paramsPerLine = horizontalSizeClass == .compact ? 6 : 8
    let instrumentParamsChunked = instrumentParams.chunked(into: paramsPerLine)
    let _ = print(instrumentParams, instrumentParamsChunked)
    
    GeometryReader { proxy in
      VStack {
        if horizontalSizeClass == .compact {
          ScrollView {
            paramRows(chunked: instrumentParamsChunked)
          }
          // .gesture(DragGesture(), including: .subviews)
        } else {
          paramRows(chunked: instrumentParamsChunked)
        }
        
        CookbookKeyboard(noteOn: conductor.noteOn, noteOff: conductor.noteOff)
          .frame(height: proxy.size.height / 5)
      }
    }
    .navigationTitle("Instrument SFZ")
    .background(colorScheme == .dark ?
                Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    .onAppear {
      conductor.start()
    }.onDisappear {
      conductor.stop()
    }
  }
  
}
