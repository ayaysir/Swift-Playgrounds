//
//  ContentView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/28/25.
//

import SwiftUI

typealias V = AnyView
typealias ViewDict = [String: Lazy<V>]

struct ContentView: View {
  var body: some View {
    NavigationSplitView {
      ListView()
    } detail: {
      Text("detail")
    }
    .navigationSplitViewStyle(.automatic)
  }
}

struct ListView: View {
  @State private var expandMiniApps = false
  
  var body: some View {
    Form {
      Section(header: Text("Categories")) {
        // 접었다 펼 수 있는 영역을 만듭니다..
        DisclosureGroup("Mini Apps", isExpanded: $expandMiniApps) {
          ForEach(ViewDicts.miniApps.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.miniApps)
          }
        }
        
        DisclosureGroup("Operations", isExpanded: .constant(true)) {
          ForEach(ViewDicts.operations.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.operations)
          }
        }
      }
    }
    .navigationTitle("AudioKit Cookbook")
  }
}

extension ListView {
  func Link(_ title: String, viewDict: ViewDict) -> some View {
    NavigationLink(title, destination: viewDict[title])
  }
}

struct ViewDicts {
  private init() {}
  
  // MARK: - View Dictionaries
  
  static let miniApps: ViewDict = [
    "Arpeggiator": Lazy(V(ArpeggiatorView())),
    "Audio 3D": Lazy(V(AudioKit3DView())),
    "Drums": Lazy(V(DrumsView())),
    "Drum Sequencer": Lazy(V(DrumSequencerView())),
    "Drum Synthesizers": Lazy(V(DrumSynthesizersView())),
    "Graphic Equalizer": Lazy(V(GraphicEqualizerView())),
    "Instrument EXS": Lazy(V(InstrumentEXSView())),
    "Instrument SFZ": Lazy(V(InstrumentSFZView())),
    "MIDI Monitor": Lazy(V(MIDIMonitorView())),
    "MIDI Track Demo View": Lazy(V(MIDITrackDemoView())),
    "Music Toy": Lazy(V(MusicToyView())),
    "Noise Generators": Lazy(V(NoiseGeneratorsView())),
    "Recorder": Lazy(V(RecorderView())),
    "Telephone": Lazy(V(TelephoneView())),
    "Tuner": Lazy(V(TunerView())),
    "VocalTract": Lazy(V(VocalTractView())),
  ]
  
  static let operations: ViewDict = [
    "Crossing Signal": Lazy(V(CrossingSignalView())),
    "Drone Operation": Lazy(V(DroneOperationView())),
    "Instrument Operation": Lazy(V(InstrumentOperationView())),
    "Phasor Operation": Lazy(V(PhasorOperationView())),
    "Pitch Shift Operation": Lazy(V(PitchShiftOperationView())),
  ]
}

#Preview {
  ContentView()
}
