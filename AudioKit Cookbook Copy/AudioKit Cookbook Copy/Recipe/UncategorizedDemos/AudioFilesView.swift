//
//  AudioFilesView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/21/25.
//

import AudioKit
import AudioKitUI
import SwiftUI

class AudioFilesConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let player = AudioPlayer()
  
  init() {
    engine.output = player
  }
  
  func loadURL(_ url: URL) {
    player.stop()
    
    do {
      try player.load(url: url)
      player.start()
    } catch {
      Log("Loading \(url) failed: \(error)")
    }
  }
}

struct AudioFilesView: View {
  @State private var conductor = AudioFilesConductor()
  @State private var currentSource: GlobalSource?
  @State private var showFileImporter = false
  
  var body: some View {
    ScrollView {
      VStack {
        if case .custom = currentSource {
          Text("Custom: \(currentSource?.fileName ?? "-")")
        } else {
          Text("Custom: select a file")
        }
        
        if case .custom = currentSource,
           let url = currentSource?.url {
          AudioFileWaveform(url: url, color: .pink)
            .frame(height: 100)
            .background(Color.black)
            .onTapGesture {
              if conductor.player.isPlaying {
                conductor.player.pause()
              } else if case .custom = currentSource {
                conductor.player.start()
              }
            }
        } else {
          Rectangle()
            .frame(height: 100)
            .overlay {
              Text("눌러서 파일 선택...")
                .foregroundStyle(.pink)
            }
            .onTapGesture {
              showFileImporter.toggle()
            }
        }
        
        ForEach(GlobalSource.allCases, id: \.self) { source in
          Text("\(source.fileName)")
          if let url = source.url {
            AudioFileWaveform(url: url)
              .frame(height: 100)
              .background(Color.black)
              .onTapGesture {
                playStopSource(source)
              }
          }
        }
      }
    }
    .padding()
    .navigationTitle("Audio Files")
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
    .fileImporter(
      isPresented: $showFileImporter,
      allowedContentTypes: [.audio]) { result in
        do {
          let fileURL = try result.get()
          if fileURL.startAccessingSecurityScopedResource() {
            currentSource = .custom(fileURL)
            conductor.player.stop()
            conductor.loadURL(fileURL)
          }
        } catch {
          Log("FileImporter failed: \(error)")
        }
      }
  }
  
  private func playStopSource(_ source: GlobalSource) {
    if currentSource == source {
      conductor.player.stop()
      currentSource = nil
      return
    }
    
    conductor.loadURL(source.url!)
    currentSource = source
  }
}

#Preview {
  AudioFilesView()
}
