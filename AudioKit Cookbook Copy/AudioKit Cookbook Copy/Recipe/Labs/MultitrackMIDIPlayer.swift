//
//  MultitrackMIDIPlayer.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/23/25.
//

import Foundation
import AudioKit
import AudioKitEX
import AudioKitUI
import SwiftUI

class MultitrackMIDIPlayerConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let sequencer = AppleSequencer()
  var mixer: Mixer!
  var samplers: [MIDISampler] = []
  
  @Published var fileName = "Orc 3"
  @Published var midiLog = ""
  @Published var isPlaying = false
  
  init() {
    sequencer.loadMIDIFile("MIDI Files/Horde3")
    setTracks()
    setMixerOutput()
  }
  
  func loadMIDIFile(url: URL) {
    if sequencer.isPlaying {
      sequencerStop()
    }
    sequencer.rewind()
    
    fileName = url.lastPathComponent
    sequencer.loadMIDIFile(fromURL: url)
    samplers.removeAll()
    setTracks()
    setMixerOutput()
  }
  
  func setMixerOutput() {
    mixer = Mixer(samplers)
    engine.output = mixer
  }
  
  func setTracks() {
    let tracks = sequencer.tracks
    var textBuffer = ""
    
    textBuffer.append("Tracks Count: \(tracks.count) [Channel, Bank, Preset]\n=========================================\n")
    
    samplers = tracks.enumerated().map { i, track in
      let trackMIDINoteData = track.getMIDINoteData()
      
      let assumedChannel: Int? = if let pcChannel = track.programChangeEvents.first?.channel {
        Int(pcChannel)
      } else if let noteChannel = trackMIDINoteData.first?.channel {
        Int(noteChannel)
      } else {
        nil
      }
      
      let isPercussion: Bool = assumedChannel == 9
      let bank: Int = isPercussion ? 128 : 0
      let preset = track.programChangeEvents.first?.number
      
      let sampler = MIDISampler()
      let presetString = if let preset {
        "\(preset) (\(InstrumentInfo.list[Int(preset)].name))"
      } else {
        "-"
      }
      
      textBuffer.append("""
        Track \(i < 10 ? " " : "")\(i):\t\(assumedChannel.map(String.init) ?? "-")\t\(bank)\t\(presetString)\n
        """)
      
      do {
        try sampler.loadSoundFont(
          "CT8MGM",
          preset: Int(preset ?? 0),
          bank: bank
        )
      } catch {
        print("Error loading sampler \(i): \(error)")
      }
      
      midiLog = textBuffer
      track.setMIDIOutput(sampler.midiIn)
      return sampler
    }
  }
  
  func sequencerPlay() {
    sequencer.play()
    isPlaying = true
  }
  
  func sequencerStop() {
    sequencer.stop()
    isPlaying = false
  }
}

struct MultitrackMIDIPlayerView: View {
  @StateObject private var conductor = MultitrackMIDIPlayerConductor()
  @State private var showFileImporter = false
  
  var body: some View {
    VStack {
      Text(conductor.fileName)
        .font(.title2)
        .bold()
      Divider()
      HStack {
        Button("Load MIDI File...") {
          showFileImporter.toggle()
        }
        .buttonStyle(.bordered)
        Button(conductor.isPlaying ? "STOP" : "PLAY") {
          if conductor.isPlaying {
            conductor.sequencerStop()
          } else {
            conductor.sequencerPlay()
          }
        }
      }
      Divider()
      // TODO: - 트랙 믹서 또는 Mute, Solo
      ScrollView {
        Text(conductor.midiLog)
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.caption2)
          .monospaced()
          .multilineTextAlignment(.leading)
          .padding(.top, 10)
      }
      
    }
    .buttonStyle(.borderedProminent)
    .tint(.teal)
    .padding()
    .navigationTitle("Multitrack MIDI Player")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
    .fileImporter(
      isPresented: $showFileImporter,
      allowedContentTypes: [.midi]) { result in
        conductor.sequencerStop()
        
        do {
          let url = try result.get()
          if url.startAccessingSecurityScopedResource() {
            conductor.loadMIDIFile(url: url)
          }
        } catch {
          print("File Import Error: \(error)")
        }
      }
  }
}

#Preview {
  MultitrackMIDIPlayerView()
}
