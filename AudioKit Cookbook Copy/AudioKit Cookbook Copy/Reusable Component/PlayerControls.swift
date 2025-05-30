//
//  PlayerControls.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/29/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

struct PlayerControls: View {
  @Environment(\.colorScheme) var colorScheme
  
  var conductor: ProcessesPlayerInput
  
  let sources: [[String]] = globalSourceArray
  
  @State var isPlaying = false
  @State var sourceName = "Drums"
  @State var isShowingSources = false
  @State private var dragOver = false
  
  var body: some View {
    HStack(spacing: 10) {
      SourceSelectButton
      PlayButton
    }
    .frame(
      minWidth: 300,
      idealWidth: 350,
      maxWidth: 360,
      minHeight: 50,
      idealHeight: 50,
      maxHeight: 50,
      alignment: .center
    )
    .padding()
    .sheet(isPresented: $isShowingSources) {
      SourceAudioSheet(playerControls: self)
    }
  }
}

extension PlayerControls {
  private var SourceSelectButton: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [.blue, .accentColor]),
        startPoint: .top,
        endPoint: .bottom
      )
      .cornerRadius(dragOver ? 15.0 : 25.0)
      .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0.0, y: 3)
      
      HStack {
        Image(systemName: dragOver ? "arrow.down.doc" : "music.note.list")
          .foregroundColor(.white)
          .font(.system(size: 14, weight: .semibold, design: .rounded))
        Text("Source Audio: \(sourceName)")
          .foregroundColor(.white)
          .font(.system(size: 14, weight: dragOver ? .heavy : .semibold, design: .rounded))
      }
      .padding()
    }.onTapGesture {
      isShowingSources.toggle()
    }.onDrop(of: [.audio], isTargeted: $dragOver) { providers -> Bool in
        providers.first?.loadItem(forTypeIdentifier: UTType.audio.identifier, options: nil) {item, _ in
          guard let url = item as? URL else { return }
          DispatchQueue.main.sync {
            load(url: url)
            sourceName = url.deletingPathExtension().lastPathComponent
          }
        }
        return true
    }
  }
  
  private var PlayButton: some View {
    Button(action: {
      self.isPlaying ? conductor.player.stop() : conductor.player.play()
      self.isPlaying.toggle()
    }, label: {
      Image(systemName: isPlaying ? "stop.fill" : "play.fill")
    })
    .padding()
    .background(isPlaying ? Color.red : Color.green)
    .foregroundColor(.white)
    .font(.system(size: 14, weight: .semibold, design: .rounded))
    .cornerRadius(25.0)
    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0.0, y: 3)
  }
}

extension PlayerControls {
  func load(filename: String) {
    guard let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/\(filename)")
    else {
      Log("failed to load sample", filename)
      return
    }
    
    load(url: url)
  }
  
  func load(url: URL) {
    conductor.player.stop()
    Log(url)
    
    guard let buffer = try? AVAudioPCMBuffer(url: url) else {
      Log("failed to load sample", url.deletingPathExtension().lastPathComponent)
      return
    }
    conductor.player.file = try? AVAudioFile(forReading: url)
    conductor.player.isLooping = true
    conductor.player.buffer = buffer
    
    if isPlaying {
      conductor.player.play()
    }
  }
}

struct SourceAudioSheet: View {
  @Environment(\.presentationMode) var presentationMode
  
  var playerControls: PlayerControls
  @State var browseFiles = false
  @State var fileURL = URL(fileURLWithPath: "")
  
  var body: some View {
    NavigationView {
      VStack {
        SourceListView
        CustomFileSelectButton
      }
      .onDisappear {
        fileURL.stopAccessingSecurityScopedResource()
      }
      .padding(.vertical, 15)
      .navigationTitle("Source Audio")
#if !os(macOS)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Close") {
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
#endif
    }
  }
}

extension SourceAudioSheet {
  private var SourceListView: some View {
    VStack(spacing: 20) {
      ForEach(playerControls.sources, id: \.self) { source in
        Button {
          playerControls.load(filename: source[1])
          playerControls.sourceName = source[0]
        } label: {
          HStack {
            Text(source[0])
            Spacer()
            if playerControls.sourceName == source[0] {
              Image(systemName: playerControls.isPlaying ? "speaker.3.fill" : "speaker.fill")
            }
          }
          .padding()
        }
      }
    }
  }
  
  private var CustomFileSelectButton: some View {
    Button(action: { browseFiles.toggle() },
           label: {
      Text("Select Custom File")
    })
    .fileImporter(isPresented: $browseFiles, allowedContentTypes: [.audio]) { res in
      do {
        fileURL = try res.get()
        if fileURL.startAccessingSecurityScopedResource() {
          playerControls.load(url: fileURL)
          playerControls.sourceName = fileURL.deletingPathExtension().lastPathComponent
        } else {
          Log("Couldn't load file URL", type: .error)
        }
      } catch {
        Log(error.localizedDescription, type: .error)
      }
    }
  }
}

#Preview {
  @Previewable @StateObject
  var conductor = ChorusConductor()
  PlayerControls(conductor: conductor)
}

#Preview {
  @Previewable @StateObject
  var conductor = ChorusConductor()
  SourceAudioSheet(playerControls: PlayerControls(conductor: conductor))
}
