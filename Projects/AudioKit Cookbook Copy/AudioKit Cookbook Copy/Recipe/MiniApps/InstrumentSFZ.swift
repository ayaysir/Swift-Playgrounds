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
  
  private let rowsInPage = 3
  @State private var currentPage = 0
  
  /// 서랍 한 줄
  @ViewBuilder func paramOneRow(params: [NodeParameter]) -> some View {
    HStack {
      ForEach(params, id: \.self) { param in
        ParameterRow(param: param)
      }
    }
    .padding(5)
  }
  
  /// 서랍 전체 (단일 페이지)
  @ViewBuilder func paramRows(chunked: [[NodeParameter]]) -> some View {
    ForEach(0..<chunked.count, id: \.self) { chunkIndex in
      paramOneRow(params: chunked[chunkIndex])
    }
  }
  
  /// 서랍 (여러 페이지)
  @ViewBuilder func paramRowsForPage(chunked: [[NodeParameter]], rowsInPage: Int = 3) -> some View {
    let stridedIndice = Array(stride(from: 0, to: chunked.count, by: rowsInPage))
    
    ForEach(stridedIndice, id: \.self) { stridedIndex in
      VStack {
        ForEach(0..<rowsInPage, id: \.self) { innerIndex in
          if let params = chunked[safe: stridedIndex + innerIndex] {
            paramOneRow(params: params)
          }
        }
        
        Spacer()
      }
      .tag(stridedIndex / rowsInPage)
    }
  }
  
  /// 페이지 내비게이터
  @ViewBuilder func pageNavigator(chunkedCount: Int) -> some View {
    let totalPage = Int(ceil(Double(chunkedCount) / Double(rowsInPage)))
    HStack {
      Spacer()
      Button("이전") {
        if currentPage > 0 {
          currentPage -= 1
        }
      }
      .disabled(currentPage == 0)
      Text("\(currentPage + 1) /  \(totalPage)")
      Button("다음") {
        if currentPage < totalPage - 1 {
          currentPage += 1
        }
      }
      .disabled(currentPage == totalPage - 1)
      Spacer()
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
          // ScrollView {
          //   paramRows(chunked: instrumentParamsChunked)
          // }
          
          TabView(selection: $currentPage) {
            paramRowsForPage(chunked: instrumentParamsChunked, rowsInPage: rowsInPage)
          }
          .indexViewStyle(.page(backgroundDisplayMode: .interactive))
          
          pageNavigator(chunkedCount: instrumentParamsChunked.count)
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
