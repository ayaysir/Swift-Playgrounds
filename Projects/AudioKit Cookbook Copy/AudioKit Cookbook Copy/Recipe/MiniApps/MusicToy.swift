//
//  MusicToy.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/8/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

// MARK: - Enums

enum Synthesizer {
  case arpeggio, pad, bass
}

enum Instrument {
  case arpeggio, pad, bass, drum
}

enum Sound {
  case square, saw, pad, noisy
}

// MARK: - Structs

struct MusicToyData {
  var isPlaying: Bool = false
  
  var bassSound: Sound = .square
  var padSound: Sound = .square
  var arpeggioSound: Sound = .square
  
  var synthesizer: Synthesizer = .arpeggio
  
  var instrument: Instrument = .arpeggio
  
  var tempo: Float = 120
  
  var arpeggioVolume: Float = 0.8
  var padVolume: Float = 0.8
  var bassVolume: Float = 0.8
  var drumVolume: Float = 0.8
  
  var filterFrequency: Float = 1.0
  
  var length: Int = 4
}

// MARK: - Conductors

class MusicToyConductor: ObservableObject, HasAudioEngine {
  var engine = AudioEngine()
  
  private var sequencer: AppleSequencer!
  private var mixer = Mixer()
  private var arpeggioSynth = MIDISampler(name: "Arpeggio Synth")
  private var padSynth = MIDISampler(name: "Pad Synth")
  private var bassSynth = MIDISampler(name: "Bass Synth")
  private var drumKit = MIDISampler(name: "Drums")
  
  // 무그 래더(Moog Ladder)는 안티 후오빌라이넨(Antti Huovilainen)의 논문
  // "무그 래더 필터의 비선형 디지털 구현"(나폴리 대학교 DaFX04 논문집)에 기술된
  // 연구를 기반으로 한 무그 래더 필터의 새로운 디지털 구현입니다.
  // 이 구현은 원래 아날로그 필터를 더 정확하게 디지털로 표현한 것으로 보입니다.
  private var filter: MoogLadder?
  
  private var bassSound: Sound = .square
  private var padSound: Sound = .square
  private var arpeggioSound: Sound = .square
  private var length = 4
  
  @Published var data = MusicToyData() {
    didSet {
      updateSounds()
    }
  }
  
  private func updateSounds() {
    data.isPlaying ? sequencer.play() : sequencer.stop()
    adjustTempo(data.tempo)
    
    if arpeggioSound != data.arpeggioSound {
      useSound(data.arpeggioSound, synth: .arpeggio)
      arpeggioSound = data.arpeggioSound
    }
    
    if padSound != data.padSound {
      useSound(data.padSound, synth: .pad)
      padSound = data.padSound
    }
    
    if bassSound != data.bassSound {
      useSound(data.bassSound, synth: .bass)
      bassSound = data.bassSound
    }
    
    adjustVolume(data.arpeggioVolume, instrument: .arpeggio)
    adjustVolume(data.padVolume, instrument: .pad)
    adjustVolume(data.bassVolume, instrument: .bass)
    adjustVolume(data.drumVolume, instrument: .drum)
    
    adjustFilterFrequency(data.filterFrequency)
    
    if length != data.length {
      setLength(Double(data.length))
      length = data.length
    }
  }
  
  init() {
    mixer = Mixer(
      arpeggioSynth,
      padSynth,
      bassSynth,
      drumKit
    )
    filter = MoogLadder(mixer)
    filter?.cutoffFrequency = 20000
    engine.output = filter
    
    do {
      useSound(.square, synth: .arpeggio)
      useSound(.saw, synth: .pad)
      useSound(.saw, synth: .bass)
      
      if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/drumSimp", withExtension: "exs") {
        try drumKit.loadInstrument(url: fileURL)
      } else {
        Log("Could not find file: drumSimp.exs")
      }
    } catch  {
      Log("\(#line): \(error)")
    }
    
    do {
      try engine.start()
    } catch  {
      Log("AudioKit did not start!")
    }
    
    guard let demoMIDIURL = Bundle.main.url(forResource: "MIDI Files/Demo", withExtension: "mid") else {
      fatalError("MIDI Files/Demo.mid doesn't exist.")
    }
    
    sequencer = AppleSequencer(fromURL: demoMIDIURL)
    sequencer.enableLooping()
    sequencer.tracks[1].setMIDIOutput(arpeggioSynth.midiIn)
    sequencer.tracks[2].setMIDIOutput(bassSynth.midiIn)
    sequencer.tracks[3].setMIDIOutput(padSynth.midiIn)
    sequencer.tracks[4].setMIDIOutput(drumKit.midiIn)
  }
  
  /// 주어진 정규화된 값을 실제 필터 컷오프 주파수 범위(30Hz ~ 20kHz)에 맞게 변환하여 `MoogLadder` 필터에 적용합니다.
  ///
  /// - Parameter frequency: 0.0~1.0 사이의 정규화된 값으로, 로그 스케일(taper=3)을 적용하여 컷오프 주파수를 조절합니다.
  /// - Note: 필터가 존재하는 경우에만 작동하며, `denormalized(to:taper:)`를 사용하여 비선형적으로 주파수를 매핑합니다.
  func adjustFilterFrequency(_ frequency: Float) {
    filter?.cutoffFrequency = frequency.denormalized(to: 30...20000, taper: 3)
  }
  
  func adjustVolume(_ volume: AUValue, instrument: Instrument) {
    switch instrument {
    case .arpeggio:
      arpeggioSynth.volume = volume
    case .pad:
      padSynth.volume = volume
    case .bass:
      bassSynth.volume = volume
    case .drum:
      drumKit.volume = volume
    }
  }
  
  func adjustTempo(_ tempo: Float) {
    sequencer?.setTempo(Double(tempo))
  }
  
  func rewindSequence() {
    sequencer.rewind()
  }
  
  func setLength(_ length: Double) {
    guard round(sequencer.length.beats) != round(4.0 * length) else {
      return
    }
    
    sequencer.setLength(Duration(beats: 16))
    
    for track in sequencer.tracks {
      track.resetToInit()
    }
    
    sequencer.setLength(Duration(beats: length))
    sequencer.setLoopInfo(Duration(beats: length), loopCount: 0)
    sequencer.rewind()
  }
  
  func useSound(_ sound: Sound, synth: Synthesizer) {
    let fileName = switch sound {
    case .square:
      "sqrTone1"
    case .saw:
      "sawPiano1"
    case .pad:
      "sawPad1"
    case .noisy:
      "noisyRez"
    }
    
    let path = "Sounds/Sampler Instruments/\(fileName)"
    
    do {
      if let fileURL = Bundle.main.url(forResource: path, withExtension: "exs") {
        switch synth {
        case .arpeggio:
          try arpeggioSynth.loadInstrument(url: fileURL)
        case .pad:
          try padSynth.loadInstrument(url: fileURL)
        case .bass:
          try bassSynth.loadInstrument(url: fileURL)
        }
      } else {
        Log("Could not find file: \(path).exs")
      }
    } catch {
      Log("Could not load instrument: \(error.localizedDescription)")
    }
  }
}

// MARK: - Views

struct MusicToyView: View {
  @StateObject private var conductor = MusicToyConductor()
  
  var body: some View {
    VStack {
      HStack(spacing: 20) {
        Spacer()
        Image(systemName: "backward")
          .onTapGesture(perform: conductor.rewindSequence)
        Spacer()
        Image(systemName: conductor.data.isPlaying ? "stop" : "play")
          .onTapGesture { conductor.data.isPlaying.toggle() }
        Spacer()
        Text("Bars (박)")
        Picker("Bars", selection: $conductor.data.length) {
          Text("1").tag(1)
          Text("2").tag(2)
          Text("4").tag(4)
          Text("8").tag(8)
          Text("16").tag(16)
        }
        .pickerStyle(.segmented)
      }
      
      HStack {
        CookbookKnob(
          text: "Tempo",
          parameter: $conductor.data.tempo,
          range: 20...300
        )
        .padding(5)
        CookbookKnob(
          text: "Filter Frequency",
          parameter: $conductor.data.filterFrequency,
          range: 0...1
        )
        .padding(5)
      }
      
      HStack {
        Text("Arpeggio")
        Picker("Arpeggio", selection: $conductor.data.arpeggioSound) {
          Text("Square").tag(Sound.square)
          Text("Saw").tag(Sound.saw)
          Text("Noise").tag(Sound.noisy)
          Text("(Pad)").tag(Sound.pad)
        }.pickerStyle(SegmentedPickerStyle())
      }
      
      HStack {
        Text("Chords")
        Picker("Chords", selection: $conductor.data.padSound) {
          Text("Square").tag(Sound.square)
          Text("Saw").tag(Sound.saw)
          Text("Pad").tag(Sound.pad)
          Text("(Noise)").tag(Sound.noisy)
        }.pickerStyle(SegmentedPickerStyle())
      }
      
      HStack {
        Text("Bass")
        Picker("Bass", selection: $conductor.data.bassSound) {
          Text("Square").tag(Sound.square)
          Text("Saw").tag(Sound.saw)
          Text("(Noise)").tag(Sound.noisy)
          Text("(Pad)").tag(Sound.pad)
        }.pickerStyle(SegmentedPickerStyle())
      }
      
      HStack {
        CookbookKnob(
          text: "Drums Volume",
          parameter: $conductor.data.drumVolume,
          range: 0.5...1
        )
        .padding(5)
        CookbookKnob(
          text: "Arpeggio Volume",
          parameter: $conductor.data.arpeggioVolume,
          range: 0.5...1
        )
        .padding(5)
        CookbookKnob(
          text: "Chord Volume",
          parameter: $conductor.data.padVolume,
          range: 0.5...1
        )
        .padding(5)
        CookbookKnob(
          text: "Bass Volume",
          parameter: $conductor.data.bassVolume,
          range: 0.5...1
        )
        .padding(5)
      }
    }
    .padding()
    .navigationTitle("Music Toy")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

// MARK: - Previews

#Preview {
  MusicToyView()
}
