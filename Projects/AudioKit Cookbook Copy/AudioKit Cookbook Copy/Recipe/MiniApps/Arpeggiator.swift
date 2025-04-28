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

@Observable
class ArpeggiatorConductor: HasAudioEngine {
  let engine = AudioEngine()
  var instrument = AppleSampler()
  
  // View.body 에서 직접 read 를 하지 않으면 해당 데이터의 변경은 뷰 업데이트에 영향을 주지 않습니다.
  var sequencer: SequencerTrack!
  var midiCallback: CallbackInstrument!
  
  var heldNotes = [Int]()
  var arpUp = false
  var currentNote = 0
  var sequencerNoteLength = 1.0
  
  // 외부 퍼블리시
  var tempo: Float = 120.0 {
    didSet {
      sequencer.tempo = BPM(tempo)
    }
  }
  
  var noteLength: Float = 1.0 {
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
    
    if !arpUp {
      // UP 시킴
      if heldNotes.max() != currentNote {
        currentNote = heldNotes.filter { $0 > currentNote }.min() ?? heldNotes.min()!
      } else {
        arpUp = true
        currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
      }
    } else {
      // DOWN 시킴
      if heldNotes.min() != currentNote {
        currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
      } else {
        arpUp = false
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
  @State private var conductor = ArpeggiatorConductor()
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
