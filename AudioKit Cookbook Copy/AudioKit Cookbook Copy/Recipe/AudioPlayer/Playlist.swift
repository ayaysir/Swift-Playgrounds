//
//  Playlist.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/18/25.
//

import AudioKit
import AudioKitUI
import SwiftUI
import UniformTypeIdentifiers

class PlaylistConductor: ObservableObject, HasAudioEngine {
  struct AudioFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
  }
  
  let supportedAudioFormats = [
    "aac", "adts", "ac3", "aif",
    "aiff", "aifc", "caf", "mp3",
    "mp4", "m4a", "snd", "au", "sd2",
    "wav",
  ]
  
  let engine = AudioEngine()
  let player = AudioPlayer()
  var audioFiles = [AudioFile]()
  
  /// The audio file that is currently playing. Its value is set  to `nil` when the playback ends.
  /// For a player with more features you may want to track the player state separately.
  @Published var loadedFile: AudioFile?
  
  init() {
    engine.output = player
    player.completionHandler = playbackCompletionHandler
  }
  
  /// Sets 'loadedFile' to `nil` when an audio file finishes playing. It is a callback
  /// assigned to the 'completionHandler' property of our player instance.
  private func playbackCompletionHandler() {
    loadedFile = nil
  }
  
  /// Empties our 'audioFiles' array before populating it with all supported files from the provided folder.
  func getAudioFiles(in folderURL: URL) {
    audioFiles = []
    let fileManager = FileManager.default
    
    do {
      let urls = try fileManager.contentsOfDirectory(
        at: folderURL,
        includingPropertiesForKeys: nil
      )
      
      for url in urls where supportedAudioFormats.contains(url.pathExtension) {
        audioFiles.append(
          AudioFile(
            url: url,
            name: url.deletingPathExtension().lastPathComponent
          )
        )
      }
    } catch {
      Log(error.localizedDescription, type: .error)
    }
  }
  
  /// Tries to play the given audio file if there is no file currently playing. If there is a
  /// file playing it will stop the playback.
  func togglePlayback(of audioFile: AudioFile) {
    if loadedFile == nil {
      loadStartPlayback(of: audioFile)
    } else if loadedFile == audioFile {
      player.stop()
      loadedFile = nil
    } else {
      player.stop()
      loadStartPlayback(of: audioFile)
    }
  }
  
  private func loadStartPlayback(of audioFile: AudioFile) {
    do {
      try player.load(url: audioFile.url)
      player.play(from: 10)
      loadedFile = audioFile
    } catch {
      Log(error.localizedDescription, type: .error)
    }
  }
}

struct PlaylistView: View {
  @StateObject var conductor = PlaylistConductor()
  @State var showingFileImporter = false
  @State var folderURL = URL(fileURLWithPath: "")
  
  var body: some View {
    VStack {
      ZStack {
        if conductor.player.isPlaying {
          NodeRollingView(
            conductor.player,
            color: .pink,
            backgroundColor: .defaultBackground
          )
          .transition(.opacity)
        } else {
          Text("사용방법: 아래 버튼을 클릭한 후 오디오 파일이 들어있는 폴더에서 [열기]를 누릅니다. 재생할 수 있는 파일의 목록이 표시되며 클릭하면 재생됩니다.")
            .transition(.opacity)
        }
      }
      .frame(height: 100)
      .animation(
        .easeInOut(duration: 0.4),
        value: conductor.player.isPlaying
      )
      
      Button("Select Playlist Folder") {
        showingFileImporter = true
      }
      .buttonStyle(.bordered)
      .padding()
      Divider()
      FileListArea
    }
    .padding()
    .onAppear {
      conductor.start()
    }
    .onDisappear() {
      conductor.stop()
      folderURL.stopAccessingSecurityScopedResource()
    }
    .fileImporter(
      isPresented: $showingFileImporter,
      allowedContentTypes: [.folder]) { result in
        do {
          folderURL = try result.get()
          if folderURL.startAccessingSecurityScopedResource() {
            conductor.getAudioFiles(in: folderURL)
          } else {
            Log("Couldn't load folder", type: .error)
          }
        } catch {
          Log(error.localizedDescription, type: .error)
        }
      }
  }
  
  private var FileListArea: some View {
    List {
      if isPreview {
        ButtonPreviewArea
      }
      ForEach(conductor.audioFiles, id: \.self) { audioFile in
        Button {
          conductor.togglePlayback(of: audioFile)
        } label: {
          HStack {
            Text(audioFile.name)
            Spacer()
            if conductor.loadedFile == audioFile {
              Image(systemName: "play.fill")
            }
          }
        }
      }
    }
    .listStyle(.plain)
  }
  
  private var ButtonPreviewArea: some View {
    Button {} label: {
      HStack {
        Text("TestFile.mp3")
        Spacer()
        Image(systemName: "play.fill")
      }
    }
  }
}

#Preview {
  PlaylistView()
}
