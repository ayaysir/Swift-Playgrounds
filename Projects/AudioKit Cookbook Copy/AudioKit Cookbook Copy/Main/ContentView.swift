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
          NavigationLink("Arpeggiator") { ArpeggiatorView() }
          NavigationLink("Audio 3D") { AudioKit3DView() }
          NavigationLink("Drums") { DrumsView() }
          NavigationLink("Drum Sequencer") { DrumSequencerView() }
          NavigationLink("Drum Synthesizers") { DrumSynthesizersView() }
          NavigationLink("Graphic Equalizer") { GraphicEqualizerView() }
        }
      }
    }
    .navigationTitle("AudioKit Cookbook")
  }
}

#Preview {
  ContentView()
}
