//
//  MIDITrack.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/7/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SwiftUI

struct MIDITrackDemoView: View {
  @StateObject var viewModel = MIDITrackViewModel()
  @State var fileURL: URL? = Bundle.main.url(forResource: "MIDI Files/Horde3", withExtension: "mid")
  @State var isPlaying = false
  
  var body: some View {
    VStack {
      GeometryReader { geometry in
        ScrollView {
          if let fileURL {
            ForEach(MIDIFile(url: fileURL).tracks.indices, id: \.self) { trackNumber in
              MIDITrackView(
                fileURL: $fileURL,
                trackNumber: trackNumber,
                trackWidth: geometry.size.width,
                trackHeight: 200
              )
              .background(.primary)
              .clipShape(.buttonBorder)
            }
          }
        }
      }
    }
    .padding()
    .navigationTitle("MIDI Track View")
    .onTapGesture {
      isPlaying.toggle()
    }
    .onChange(of: isPlaying) {
      if isPlaying == true {
        viewModel.play()
      } else {
        viewModel.stop()
      }
    }
    .onAppear {
      viewModel.startEngine()
      
      if let fileURL {
        viewModel.loadSequencerFile(fileURL: fileURL)
      }
    }
    .onDisappear {
      viewModel.stop()
      viewModel.stopEngine()
    }
    // MIDITrackView에서 필요
    .environmentObject(viewModel)
  }
}

#Preview {
  MIDITrackDemoView()
}
