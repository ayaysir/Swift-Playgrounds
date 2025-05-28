//
//  Arpeggiator.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/28/25.
//

import SwiftUI
import AudioKit
import AudioKitEX
import AudioKitUI
import AVFAudio
import Keyboard
import Controls
import Tonic

class ArpeggiatorConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var instrument = AppleSampler()
  
  // View.body 에서 직접 read 를 하지 않으면 해당 데이터의 변경은 뷰 업데이트에 영향을 주지 않습니다.
  var sequencer: SequencerTrack!
  var midiCallback: CallbackInstrument!
  
  var heldNotes = [Int]()
  
  /*
   arpUp이라는 변수명은 기능은 전달하지만, 직관성과 정확성 측면에서는 아쉬운 점이 있습니다.

   ⸻

   ✅ 의미 분석
     •  arpUp == true: 현재 아르페지오가 하향 진행 중이며, 끝에 도달하면 방향을 상향으로 전환
     •  arpUp == false: 현재 아르페지오가 상향 진행 중이며, 끝에 도달하면 방향을 하향으로 전환

   즉, 이 변수는 현재 방향이 아니라 다음 진행 방향을 정하는 기준이 되고 있습니다.

   ⸻

   ❌ 문제점

   arpUp이라는 이름은 일반적으로 **“현재 위로 진행 중인가?”**라는 의미로 해석되기 쉽습니다.
   하지만 실제 로직에서는 위로 진행 중일 때는 false, 아래로 진행 중일 때는 true입니다. 이로 인해 코드의 의미와 이름이 충돌하며, 혼란을 초래할 수 있습니다.
   */
  // var arpUp = false
  var isArpDescending = false
  
  var currentNote = 0
  var sequencerNoteLength = 1.0
  
  // 외부 퍼블리시
  @Published var tempo: Float = 120.0 {
    didSet {
      sequencer.tempo = BPM(tempo)
    }
  }
  
  @Published var noteLength: Float = 1.0 {
    didSet {
      sequencerNoteLength = Double(noteLength)
      sequencer.clear()
      sequencer.add(
        noteNumber: 60,
        position: 0.0,
        duration: max(0.05, sequencerNoteLength * 0.24)
      )
    }
  }
  
  func noteOn(pitch: Pitch, point _: CGPoint) {
    heldNotes.append(max(0, pitch.intValue))
  }
  
  func noteOff(pitch: Pitch) {
    heldNotes = heldNotes.filter { $0 != pitch.intValue }
  }
  
  func fireTimer() {
    for i in 0...127 {
      self.instrument.stop(noteNumber: MIDINoteNumber(i), channel: 0)
    }
    
    if heldNotes.count < 1 {
      return
    }
    
    /*
     heldNotes는 읖높이별로 정렬이 되어있지 않음 (예: [4, 6, 3, 5]
     각 음은 바로 다음의 음을 찾아야 함
     6     6
      5   5 5
       4 4   4
        3     ...
     */
    if !isArpDescending {
      if heldNotes.max() != currentNote {
        currentNote = heldNotes.filter { $0 > currentNote }.min() ?? heldNotes.min()!
      } else {
        isArpDescending = true
        currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
      }
    } else {
      if heldNotes.min() != currentNote {
        currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
      } else {
        isArpDescending = false
        currentNote = heldNotes.filter { $0 > currentNote }.min() ?? heldNotes.min()!
      }
    }
    
    instrument.play(noteNumber: MIDINoteNumber(currentNote), velocity: 120, channel: 0)
  }
  
  init() {
    midiCallback = CallbackInstrument { status, note, velocity in
      if status == 144 { // NoteOn
        self.fireTimer()
      } else if status == 128 { // NoteOff
        for i in 0...127 {
          self.instrument.stop(noteNumber: MIDINoteNumber(i), channel: 0)
        }
      }
    }
    
    engine.output = PeakLimiter(
      Mixer(instrument, midiCallback), // Node
      attackTime: 0.001,
      decayTime: 0.001,
      preGain: 0
    )
    
    do {
      /*
       - Sounds 폴더 선택 > Build Rules: Apply Once to Folder
       - 폴더 포함하여 경로 적음
       */
      if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/sawPiano1", withExtension: "exs") {
        try instrument.loadInstrument(url: fileURL)
      } else {
        Log("Could not find file.")
      }
    } catch {
      Log("Could not load instrument.")
    }
    
    sequencer = SequencerTrack(targetNode: midiCallback)
    sequencer.length = 0.25
    sequencer.loopEnabled = true
    sequencer.add(noteNumber: 60, position: 0.0, duration: 0.24)
    
    sequencer.playFromStart()
  }
}

struct ArpeggiatorView: View {
  @StateObject private var conductor = ArpeggiatorConductor()
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    VStack {
      NodeOutputView(conductor.instrument)
      HStack {
        CookbookKnob(
          text: "BPM",
          parameter: $conductor.tempo,
          range: 20.0...250.0
        )
        CookbookKnob(
          text: "Length",
          parameter: $conductor.noteLength,
          range: 0.0...1.0
        )
      }
      CookbookKeyboard(
        noteOn: conductor.noteOn,
        noteOff: conductor.noteOff
      )
    }
    .navigationTitle("Arpeggiator")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
      conductor.sequencer.stop()
    }
    .background(colorScheme == .dark ?
                Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
  }
}

#Preview {
  ArpeggiatorView()
}
