//
//  SynthesisToolkitView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/20/25.
//

import Foundation
import AudioKit
import AudioKitEX
import AudioKitUI
import STKAudioKit
import SwiftUI

struct ShakerMetronomeData {
  var isPlaying = false
  var tempo: BPM = 120
  var timeSignatureTop: Int = 4
  var downbeatNoteNumber = MIDINoteNumber(6)
  var beatNoteNumber = MIDINoteNumber(10)
  var beatNoteVelocity = 100.0
  var currentBeat = 0
}

class ShakerConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let shaker = Shaker()
  var callbackInstrument = CallbackInstrument()
  let reverb: Reverb
  let mixer = Mixer()
  var sequencer = Sequencer()
  
  @Published var data = ShakerMetronomeData() {
    didSet {
      data.isPlaying ? sequencer.play() : sequencer.stop()
      sequencer.tempo = data.tempo
      updateSequences()
    }
  }
  
  init() {
    let fader = Fader(shaker)
    fader.gain = 20.0
    reverb = Reverb(fader)
    
    _ = sequencer.addTrack(for: shaker)
    
    callbackInstrument = CallbackInstrument { _, beat, _ in
      DispatchQueue.main.async { [unowned self] in
        data.currentBeat = Int(beat)
        // print(beat)
      }
    }
    
    _ = sequencer.addTrack(for: callbackInstrument)
    updateSequences()
    
    mixer.addInput(reverb)
    mixer.addInput(callbackInstrument)
    
    engine.output = mixer
  }
  
  func updateSequences() {
    guard var track = sequencer.tracks.first else {
      fatalError("track is nil.")
    }
    
    track.length = Double(data.timeSignatureTop)
    track.clear()
    
    track.sequence.add(
      noteNumber: data.downbeatNoteNumber,
      position: 0.0,
      duration: 0.4
    )
    
    let velocity = MIDIVelocity(Int(data.beatNoteVelocity))
    for beat in 1..<data.timeSignatureTop {
      track.sequence.add(
        noteNumber: data.beatNoteNumber,
        velocity: velocity,
        position: Double(beat),
        duration: 0.1
      )
    }
    
    track = sequencer.tracks[1]
    track.length = Double(data.timeSignatureTop)
    track.clear()
    
    for beat in 0..<data.timeSignatureTop {
      track.sequence.add(
        noteNumber: MIDINoteNumber(beat),
        position: Double(beat),
        duration: 0.1
      )
    }
  }
}

struct STKView: View {
  @StateObject var conductor = ShakerConductor()
  
  var body: some View {
    GeometryReader { geometry in
      // // outside (750.0, 381.0)
      // let _ = print("outside", geometry.size)
      let isLandscape = geometry.size.width > geometry.size.height
      
      VStack {
        if isLandscape {
          // 가로 모드 레이아웃
          HStack(spacing: 10) {
            PlayButtonArea
              .frame(width: geometry.size.width / 6)
            TempoSliderArea
            BeatSelectArea
            VelocityArea
          }
        } else {
          // 세로 모드 레이아웃
          HStack {
            PlayButtonArea
            TempoSliderArea
          }
          HStack {
            BeatSelectArea
            VelocityArea
          }
        }
        
        BeatCounterArea
        
        FFTView(conductor.reverb)
      }
      .padding()
    }
    .navigationTitle("STK Demo")
    .onAppear {
        conductor.start()
    }
    .onDisappear {
        conductor.stop()
    }
  }
  
  private var BeatCounterArea: some View {
    HStack(spacing: 10) {
      ForEach(0..<conductor.data.timeSignatureTop, id: \.self) { i in
        let isInCurrentBeat = conductor.data.currentBeat == i
        GeoCircleButton(
          text: "\(i + 1)",
          foregroundColor: isInCurrentBeat ? .red : .primary,
          textColor: isInCurrentBeat ? .white : .defaultBackground) {
            conductor.data.timeSignatureTop = i + 1
          }
      }
      GeoCircleButton(
        text: "+",
        foregroundColor: .primary.opacity(0.6),
        textColor: .defaultBackground) {
          conductor.data.timeSignatureTop += 1
        }
    }
    .padding()
  }
  
  @ViewBuilder func GeoCircleButton(
    text: String,
    foregroundColor: Color,
    textColor: Color,
    onTapGesture: @escaping () -> Void
  ) -> some View {
    ZStack {
      GeometryReader { geometry in
        let size = min(geometry.size.width, geometry.size.height)
        let fontSize = size * 0.5
        
        Circle()
          .foregroundStyle(foregroundColor)
        Text(verbatim: text)
          .font(.system(size: fontSize, weight: .bold))
          .minimumScaleFactor(0.5) // 너무 작을 때 줄어들도록
          .lineLimit(1)
          .foregroundStyle(textColor)
          .frame(width: size, height: size, alignment: .center)
      }
    }
    .aspectRatio(1, contentMode: .fit)
    .onTapGesture(perform: onTapGesture)
  }
  
  private var PlayButtonArea: some View {
    GeometryReader { geometry in
      // // inside (172.0, 30.0)
      // let _ = print("inside", geometry.size)
      Button {
        conductor.data.isPlaying.toggle()
      } label: {
        Text(conductor.data.isPlaying ? "Stop" : "Start")
          .bold()
          .frame(
            width: geometry.size.width * 0.8,
            height: geometry.size.height,
            alignment: .center)
      }
      .tint(.teal)
      .buttonStyle(.borderedProminent)
      .position(
        x: geometry.size.width / 2,
        y: geometry.size.height / 2
      )
    }
    .frame(height: 40)
  }
  
  private var TempoSliderArea: some View {
    VStack {
      Text("Tempo: \(Int(conductor.data.tempo))")
      Slider(
        value: $conductor.data.tempo,
        in: 60.0...240.0) {
          Text("Tempo")
        }
    }
  }
  
  private var BeatSelectArea: some View {
    VStack {
      Stepper {
        Text("Downbeat:")
          .bold()
          .font(.system(size: 12))
        Text(name(noteNumber: conductor.data.downbeatNoteNumber))
          .font(.system(size: 11))
      } onIncrement: {
        conductor.data.downbeatNoteNumber = (conductor.data.downbeatNoteNumber + 1).clamped(to: 0...22)
      } onDecrement: {
        conductor.data.downbeatNoteNumber = (conductor.data.downbeatNoteNumber - 1).clamped(to: 0...22)
      }
      
      Stepper {
        Text("Other beats: ")
          .bold()
          .font(.system(size: 12))
        Text(name(noteNumber: conductor.data.beatNoteNumber))
          .font(.system(size: 11))
      } onIncrement: {
        conductor.data.beatNoteNumber = (conductor.data.beatNoteNumber + 1).clamped(to: 0...22)
      } onDecrement: {
        conductor.data.beatNoteNumber = (conductor.data.beatNoteNumber - 1).clamped(to: 0...22)
      }
    }
  }
  
  private var VelocityArea: some View {
    VStack {
      Text("Velocity")
      Slider(
        value: $conductor.data.beatNoteVelocity,
        in: 0.0...127.0) {
          Text("Velocity")
        }
    }
  }
  
  func name(noteNumber: MIDINoteNumber) -> String {
    let str = "\(ShakerType(rawValue: noteNumber)!)"
    return str.titleCase()
  }
}

#Preview {
  STKView()
}
