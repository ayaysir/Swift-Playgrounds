//
//  ContentView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/28/25.
//

import SwiftUI

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
  var body: some View {
    Form {
      Section(header: Text("Categories")) {
        // 접었다 펼 수 있는 영역을 만듭니다..
        DisclosureGroup("Mini Apps", isExpanded: .constant(true)) {
          Link("Arpeggiator")
          Link("Audio 3D")
          Link("Drums")
          Link("Drum Sequencer")
          Link("Drum Synthesizers")
          Link("Graphic Equalizer")
          Link("Instrument EXS")
          Link("Instrument SFZ")
          Link("MIDI Monitor")
          Link("MIDI Track Demo View")
          Link("Music Toy")
        }
      }
    }
    .navigationTitle("AudioKit Cookbook")
  }
  
  typealias V = AnyView
  let viewDict: [String: Lazy<V>] = [
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
  ]
}

extension ListView {
  func Link(_ title: String) -> some View {
    NavigationLink(title, destination: viewDict[title])
  }
}

#Preview {
  ContentView()
}
