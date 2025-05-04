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
        }
      }
    }
    .navigationTitle("AudioKit Cookbook")
  }
  
  let viewDict: [String: Lazy<AnyView>] = [
    "Arpeggiator": Lazy(AnyView(ArpeggiatorView())),
    "Audio 3D": Lazy(AnyView(AudioKit3DView())),
    "Drums": Lazy(AnyView(DrumsView())),
    "Drum Sequencer": Lazy(AnyView(DrumSequencerView())),
    "Drum Synthesizers": Lazy(AnyView(DrumSynthesizersView())),
    "Graphic Equalizer": Lazy(AnyView(GraphicEqualizerView())),
    "Instrument EXS": Lazy(AnyView(InstrumentEXSView()))
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
