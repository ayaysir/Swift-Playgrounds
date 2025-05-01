//
//  Drums.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/30/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Combine
import SwiftUI

// MARK: - Structs

struct DrumSample {
  var name: String
  var fileName: String
  var midiNote: Int
  var audioFile: AVAudioFile?
  var color: UIColor = .red
  
  init(_ prettyName: String, fileName: String, midiNote: Int) {
    self.name = prettyName
    self.fileName = fileName
    self.midiNote = midiNote
    
    guard let url = Bundle.main.resourceURL?.appending(path: fileName) else {
      return
    }
    
    do {
      audioFile = try AVAudioFile(forReading: url)
    } catch {
      Log("Couldn't load: \(fileName)")
    }
  }
}

// MARK: - Conductors

@Observable
class DrumsConductor: HasAudioEngine {
  private(set) var lastPlayed: String = "None"
  let engine = AudioEngine()
  
  let drumSamples: [DrumSample] = [
    .init("OPEN HI HAT", fileName: "Samples/open_hi_hat_A#1.wav", midiNote: 34),
    .init("HI TOM", fileName: "Samples/hi_tom_D2.wav", midiNote: 38),
    .init("MID TOM", fileName: "Samples/mid_tom_B1.wav", midiNote: 35),
    .init("LO TOM", fileName: "Samples/lo_tom_F1.wav", midiNote: 29),
    .init("HI HAT", fileName: "Samples/closed_hi_hat_F#1.wav", midiNote: 30),
    .init("CLAP", fileName: "Samples/clap_D#1.wav", midiNote: 27),
    .init("SNARE", fileName: "Samples/snare_D1.wav", midiNote: 26),
    .init("KICK", fileName: "Samples/bass_drum_C1.wav", midiNote: 24),
  ]
  
  let drums = AppleSampler()
  
  func playPad(padNumber: Int) {
    drums.play(noteNumber: MIDINoteNumber(drumSamples[padNumber].midiNote))
    let fileName = drumSamples[padNumber].fileName
    lastPlayed = fileName.components(separatedBy: "/").last!
  }
  
  init() {
    engine.output = drums
    do {
      let files = drumSamples.map { $0.audioFile! }
      try drums.loadAudioFiles(files)
    } catch {
      Log("Files didn't load")
    }
  }
}

// MARK: - DrumsView

struct DrumsView: View {
  private var conductor = DrumsConductor()
  
  var body: some View {
    VStack(spacing: 2) {
      PadsView(conductor: conductor) { pad in
        conductor.playPad(padNumber: pad)
      }
    }
    .navigationTitle("Drum Pads")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

// MARK: - PadsView

struct PadsView: View {
  var conductor: DrumsConductor
  
  var padsAction: (_ padNumber: Int) ->  Void
  @State private var downPads: [Int] = []
  
  var body: some View {
    VStack(spacing: 10) {
      // 파형 그래프
      NodeOutputView(conductor.drums)
      
      // Row
      ForEach(0..<2, id: \.self) { row in
        HStack(spacing: 10) {
          
          // Column
          ForEach(0..<4, id: \.self) { column in
            padButton(id: padId(row: row, column: column))
          }
        }
        .padding(5)
      }
    }
  }
  
  private func padButton(id padId: Int) -> some View {
    ZStack {
      Rectangle()
        .fill(padColor(padId: padId))
        .cornerRadius(20)
      
      Text(padName(padId: padId))
        .foregroundColor(Color(.white))
        .fontWeight(.bold)
    }
    .gesture(gesture(padId: padId))
  }
}

extension PadsView {
  func gesture(padId: Int) -> some Gesture {
    DragGesture(minimumDistance: 0, coordinateSpace: .local)
      .onChanged { _ in
        let isPressed = downPads.contains(padId)
        if !isPressed {
          padsAction(padId)
          downPads.append(padId)
        }
      }
      .onEnded { _ in
        downPads.removeAll { $0 == padId }
      }
  }
  
  /**
   현재 row와 column에 해당하는 패드 ID가 존재하는지를 확인하는 조건입니다.
   - 여기서 row * 4 + column은 패드를 1차원 배열로 인덱싱하기 위한 고정 규칙이며,
   - 4개의 column을 기준으로 패드가 정렬되어 있다고 가정한 구조입니다.
   ```
   예) row = 1, column = 2인 경우 (zero-based)
   1 * 4 + 2 = 6
   □ □ □ □          0 1 2 3
   □ □ ■ □          4 5 6 7
   ```
   */
  func padId(row: Int, column: Int) -> Int {
    (row * 4) + column
  }

  func padColor(padId: Int) -> Color {
    /*
     Rectangle()
       .fill(
         Color(
           conductor.drumSamples.map {
             downPads.contains(where: { $0 == row * 4 + column }) ? .gray : $0.color
           }[padId(row: row, column: column)]))
       .cornerRadius(20)
     */
    
    let colors = conductor.drumSamples.map { sample in
      downPads.contains { $0 == padId } ? UIColor.gray : sample.color
    }

    return .init(colors[padId])
  }
 
  func padName(padId: Int) -> String {
    // conductor.drumSamples.map { $0.name }[padId(row: row, column: column)]
    
    return conductor.drumSamples[padId].name
  }
}

// MARK: - Previews
 
#Preview {
  DrumsView()
}
