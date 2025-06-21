//
//  CallbackInstrument.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/21/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import Controls
import AudioToolbox
import SwiftUI

class CallbackInstrumentConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var sequencer = AppleSequencer()
  var callbacker: MIDICallbackInstrument!
  let sampler = MIDISampler()
  var isFirstRun = true
  
  @Published var tempo: AUValue = 60.0 {
    didSet { sequencer.setTempo(Double(tempo)) }
  }
  @Published var division: AUValue = 1 {
    didSet {
      text = ""
      setCallback()
      sequencer.stop()
      createClickTrack()
      sequencer.rewind()
    }
  }
  @Published var text = ""
  
  init() {
    setCallback()
    
    do {
      let preset = Int.random(in: 0...127)
      try sampler.loadSoundFont("CT8MGM", preset: preset, bank: 0)
    } catch {
      print("사운드폰트 로딩 실패: \(error)")
    }
    
    // 트랙 미리 생성 (메모리에 생성됨)
    _ = sequencer.newTrack()
    _ = sequencer.newTrack("sound")
    
    createClickTrack()
    sequencer.setTempo(Double(tempo))
    
    //: We must link the clock's output to AudioKit (even if we don't need the sound)
    engine.output = sampler
  }
  
  func createClickTrack() {
    guard sequencer.trackCount >= 2 else {
      print("Track count error:", sequencer.trackCount)
      return
    }
    
    let clickTrack = sequencer.tracks[0]
    let soundTrack = sequencer.tracks[1]
    
    clickTrack.clear()
    soundTrack.clear()
    
    for i in 0 ..< Int(division) {
      let dvisionIntToDouble = Double(Int(division))
      let velocity: MIDIVelocity = 100
      let duration = Duration(beats: Double(0.1 / dvisionIntToDouble))
      
      let firstPosition = Duration(beats: Double(i) / dvisionIntToDouble)
      let secondPosition = Duration(beats: (Double(i) + 0.5) / dvisionIntToDouble)
      
      clickTrack.add(
        noteNumber: MIDINoteNumber(80 + i),
        velocity: velocity,
        position: firstPosition,
        duration: duration
      )
      soundTrack.add(
        noteNumber: MIDINoteNumber(80 + i),
        velocity: velocity,
        position: firstPosition,
        duration: duration
      )
      
      clickTrack.add(
        noteNumber: MIDINoteNumber(60 + i),
        velocity: velocity,
        position: secondPosition,
        duration: duration
      )
      soundTrack.add(
        noteNumber: MIDINoteNumber(60 + i),
        velocity: velocity,
        position: secondPosition,
        duration: duration
      )
    }
    
    clickTrack.setMIDIOutput(callbacker.midiIn)
    clickTrack.setLoopInfo(Duration(beats: 1.0), loopCount: 10)
    
    soundTrack.setMIDIOutput(sampler.midiIn)
    soundTrack.setLoopInfo(Duration(beats: 1.0), loopCount: 10)
  }
  
  func setCallback() {
    self.callbacker = MIDICallbackInstrument { [self] status, note, _ in
      guard let midiStatus = MIDIStatusType.from(byte: status) else {
        return
      }
      if midiStatus == .noteOn {
        DispatchQueue.main.async {
          self.text += String(format: """
          Start Note %d at %.4f\n
          """, note, self.sequencer.currentPosition.seconds)
        }
      }
    }
  }
}

struct CallbackInstrumentView: View {
  @StateObject var conductor = CallbackInstrumentConductor()
  
  var body: some View {
    VStack(spacing: 30) {
      HStack(spacing: 30) {
        Text("Play")
          .foregroundColor(.blue)
          .onTapGesture {
            conductor.sequencer.play()
          }
        Text("Pause")
          .foregroundColor(.blue)
          .onTapGesture {
            conductor.sequencer.stop()
          }
        Text("Rewind")
          .foregroundColor(.blue)
          .onTapGesture {
            conductor.text = ""
            conductor.sequencer.rewind()
          }
      }
      
      HStack {
        CookbookKnob(
          text: "Tempo:",
          parameter: $conductor.tempo,
          range: 1...300
        )
        VStack {
          Text("Division: \(String(format: "%.0f", conductor.division))")
          Slider(
            value: $conductor.division,
            in: 1...16, step: 1) {
              Text("Division:")
            }
        }
      }
      
      ScrollViewReader { proxy in
        ScrollView {
          Text(conductor.text)
            .id("logBottom")
            .monospaced()
            .font(.system(size: 14))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: conductor.text) {
          withAnimation {
            proxy.scrollTo("logBottom", anchor: .bottom)
          }
        }
      }
    }
    .padding()
    .navigationTitle("Callback Instrument")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  CallbackInstrumentView()
}
