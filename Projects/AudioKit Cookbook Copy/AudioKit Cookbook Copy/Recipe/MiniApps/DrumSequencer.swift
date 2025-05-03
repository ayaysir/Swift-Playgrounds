//
//  DrumSequencer.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/1/25.
//
// ⚠️ Backgrounds Mode > Audio, AirPlay, and Picture in Picture를 활성화해야함 (kMIDINotPermitted) 문제

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Combine
import SwiftUI

class DrumSequencerConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let drums = MIDISampler(name: "Drums")
  var midiCallback = MIDICallbackInstrument()
  let sequencer = AppleSequencer(
    fromURL: Bundle.main.url(forResource: "MIDI Files/4tracks", withExtension: "mid")!
  )
  
  // published
  @Published var tempo: Float = 120 {
    didSet {
      sequencer.setTempo(BPM(tempo))
    }
  }
  
  @Published var isPlaying = false {
    didSet {
      isPlaying ? sequencer.play() : sequencer.stop()
    }
  }
  
  @Published var hiHatsRoll: String = "⬜️⬜️⬜️⬜️ ⬜️⬜️⬜️⬜️ ⬜️⬜️⬜️⬜️ ⬜️⬜️⬜️⬜️"
  
  /// 랜덤 리듬 패턴을 생성하여 `sequencer.tracks[2]`에 할당합니다.
  ///
  /// - 이 함수는 먼저 해당 트랙의 4마디 구간(4박)을 초기화한 뒤,
  ///   16분음표 간격으로 총 16개의 노트를 새롭게 추가합니다 (1마디 기준).
  ///
  /// - 각 노트는 다음과 같은 방식으로 생성됩니다:
  ///   - 음높이(noteNumber)는 MIDI 번호 30(베이스 드럼 영역)을 기준으로,
  ///     여기에 0~1.99 사이의 랜덤한 실수 값을 더한 뒤 `Int()`로 변환하여
  ///     30 또는 31번 노트 중 하나를 무작위로 선택합니다.
  ///     즉, 두 개의 서로 다른 저음 음색을 무작위로 사용하게 됩니다.
  ///
  ///   - 벨로시티(velocity)는 80~127 범위에서 무작위로 설정되며,
  ///     이는 각 타격의 세기(강약)를 자연스럽게 변화시켜
  ///     인간적인 연주 느낌을 줍니다.
  ///
  ///   - 각 노트의 시작 시점(position)은 16분음표 간격(`i / 4.0`)으로
  ///     설정되므로 **1마디 안에 정확히 16개의 노트가 등간격으로 배치**됩니다.
  ///
  ///   - 노트 길이(duration)는 0.5 비트로 고정되어 있어,
  ///     각 음이 리듬적으로 짧게 연주됩니다.
  ///
  /// 이 함수는 박자 감각과 다이나믹이 있는, 반복 가능한 랜덤 리듬 패턴을
  /// 생성하는 데 활용할 수 있습니다. 주로 킥 드럼이나 퍼커션 트랙에 적합합니다.
  func randomizeHiHats() {
    sequencer.tracks[2].clearRange(
      start: Duration(beats: 0),
      duration: Duration(beats: 4)
    )
    
    for i in 0...15 {
      sequencer.tracks[2].add(
        noteNumber: MIDINoteNumber( 30 + MIDINoteNumber(AUValue.random(in: 0...1.99)) ),
        velocity: MIDIVelocity(AUValue.random(in: 80...127)),
        position: Duration(beats: Double(i) / 4.0),
        // ⚠️ 마지막 노트의 position: 3.75일때 duration 0.5를 연주하면 3.75 + 0.5 = 4.25로
        // 비트가 4를 넘어 다음 루프의 첫 번째 하이햇이 연주되지 않음
        // 마지막 노트인 경우 duration 0.25 로 조정해서 겹치지 않게
        // (사실 처음부터 duration 0.1로 해도 알아서 잘 연주됨)
        duration: Duration(beats: i == 15 ? 0.25 : 0.5)
      )
    }
    
    sequencer.tracks[2].debug()
    print("===========================")
    
    updateHiHatsRoll()
  }
  
  init() {
    midiCallback.callback = { status, note, velocity in
      if status == 144 {
        self.drums.play(noteNumber: note, velocity: velocity, channel: 0)
      } // status == 128: note off: 아무것도 안함
    }
    
    engine.output = drums
    
    do {
      // If a file name ends with a note name (ex: "violinC3.wav")
      // The file will be set to this note
      try drums.loadAudioFiles(audioFiles!)
      
    } catch {
      Log("❌ Failed to load audio files: \(error)")
    }
    
    sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: 100))
    sequencer.debug()
    sequencer.setGlobalMIDIOutput(midiCallback.midiIn)
    sequencer.enableLooping(Duration(beats: 4))
    sequencer.setTempo(Double(tempo))
    
    // 베이스 1 (24, C1, 트랙 0)
    sequencer.tracks[0].add(
      noteNumber: 24,
      velocity: 80,
      position: Duration(beats: 0),
      duration: Duration(beats: 1)
    )
    
    // 베이스 2 (트랙 0)
    sequencer.tracks[0].add(
      noteNumber: 24,
      velocity: 80,
      position: Duration(beats: 2),
      duration: Duration(beats: 1)
    )
    
    // 베이스 2? (트랙 1)
    sequencer.tracks[1].add(
      noteNumber: 24,
      velocity: 80,
      position: Duration(beats: 2),
      duration: Duration(beats: 1)
    )
    
    // 기본 8비트 하이햇 (30, F#1)
    for i in 0...7 {
      sequencer.tracks[2].add(
        noteNumber: 30,
        velocity: 127,
        position: Duration(beats: Double(i) / 2.0),
        duration: Duration(beats: 0.5)
      )
    }
    
    updateHiHatsRoll()
    
    // 스네어 (26, D1)
    sequencer.tracks[3].add(
      noteNumber: 26,
      velocity: 127,
      position: Duration(beats: 2),
      duration: Duration(beats: 1)
    )
    
  }
  
  func updateHiHatsRoll() {
    hiHatsRoll = if sequencer.tracks[2].isNotEmpty {
      sequencer.tracks[2].getMIDINoteData().enumerated().map { index, noteData in
        (noteData.noteNumber == 30 ? "🟩" : "⬜️") + ((index + 1) % 4 == 0 ? " " : "")
      }.joined()
    } else {
      "⬜️⬜️⬜️⬜️ ⬜️⬜️⬜️⬜️ ⬜️⬜️⬜️⬜️ ⬜️⬜️⬜️⬜️"
    }
  }
  
  private let sampleFileNames = [
    "Samples/bass_drum_C1.wav",
    "Samples/clap_D#1.wav",
    "Samples/closed_hi_hat_F#1.wav",
    "Samples/hi_tom_D2.wav",
    "Samples/lo_tom_F1.wav",
    "Samples/mid_tom_B1.wav",
    "Samples/open_hi_hat_A#1.wav",
    "Samples/snare_D1.wav"
  ]
  
  private var audioFiles: [AVAudioFile]! {
    try! sampleFileNames.map { fileName in
      let url = Bundle.main.resourceURL!.appendingPathComponent(fileName)
      return try AVAudioFile(forReading: url)
    }
  }
}

struct DrumSequencerView: View {
  @StateObject private var conductor = DrumSequencerConductor()
  
  var body: some View {
    VStack(spacing: 10) {
      // 왜 버튼으로 안하고??
      Text(conductor.isPlaying ? "Stop" : "Start")
        .foregroundStyle(.blue)
        .onTapGesture {
          conductor.isPlaying.toggle()
        }
      
      Text("Randomized Hi-hats")
        .foregroundStyle(.blue)
        .onTapGesture {
          conductor.randomizeHiHats()
        }
      
      CookbookKnob(
        text: "Tempo",
        parameter: $conductor.tempo,
        range: 60...300
      )
      .padding(5)
      
      Text(conductor.hiHatsRoll)
        .font(.system(size: 10))
      
      NodeOutputView(conductor.drums)
      
      Spacer()
    }
    .navigationTitle("Drum Sequencer")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.isPlaying = false
      conductor.drums.destroyEndpoint()
      conductor.stop()
    }
  }
}

#Preview {
  DrumSequencerView()
}
