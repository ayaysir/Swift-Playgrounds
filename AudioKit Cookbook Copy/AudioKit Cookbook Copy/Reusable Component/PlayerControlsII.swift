//
//  PlayerControlsII.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/30/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

struct PlayerControlsII: View {
  @Environment(\.colorScheme) var colorScheme
  var conductor: ProcessesPlayerInput
  @State var browseFiles = false
  @State var fileURL = URL(fileURLWithPath: "")
  
  let columnsCount: Int = 3
  let columnsMargin: CGFloat = 5
  
  // 화면을 그리드형식으로 꽉채워줌
  var columns: [GridItem] {
    (1...columnsCount).map { _ in GridItem(.flexible(), spacing: columnsMargin) }
  }
  
  @State var isPlaying = false
  @State var source: GlobalSource = .drums
  @State var isShowingSources = false
  @State private var dragOver = false
  @State var bufferChangeHandler: (() -> Void)? = nil
  
  var body: some View {
    HStack(spacing: 10) {
      SourceListView
      PlayButton
    }
  }
}

extension PlayerControlsII {
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

  private var SourceListView: some View {
    VStack(spacing: 20) {
      LazyVGrid(columns: columns, spacing: columnsMargin * 2) {
        // 기본 제공 소스들
        ForEach(GlobalSource.allCases) { source in
          DefaultSourceButton(current: source)
        }
        SelectCustomFileButton
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  @ViewBuilder func DefaultSourceButton(current currentSource: GlobalSource) -> some View {
    Button {
      load(filename: currentSource.fileName)
      self.source = currentSource
    } label: {
      HStack(spacing: 0) {
        Text(currentSource.name)
          .font(.system(size: 10))
        Spacer()
        if self.source.name == currentSource.name {
          Image(systemName: isPlaying ? "speaker.3.fill" : "speaker.fill")
            .font(.system(size: 10))
        }
      }
    }
    .frame(height: 20)
    .buttonStyle(.bordered)
    .tint(Color.teal)
  }
  
  private var SelectCustomFileButton: some View {
    Button {
      browseFiles.toggle()
    } label: {
      HStack(spacing: 0) {
        if case .custom = source {
          Text(source.name)
            .font(.system(size: 10))
          Spacer()
          Image(systemName: isPlaying ? "speaker.3.fill" : "speaker.fill")
            .font(.system(size: 10))
        } else {
          Text("Select Custom File")
            .font(.system(size: 10))
          Spacer()
        }
      }
    }
    .frame(height: 20)
    .buttonStyle(.bordered)
    .tint(Color.pink)
    .fileImporter(isPresented: $browseFiles, allowedContentTypes: [.audio]) { res in
      do {
        fileURL = try res.get()
        if fileURL.startAccessingSecurityScopedResource() {
          load(url: fileURL)
          source = .custom(fileURL)
        } else {
          Log("Couldn't load file URL", type: .error)
        }
      } catch {
        Log(error.localizedDescription, type: .error)
      }
    }
  }
}

extension PlayerControlsII {
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
    
    // guard let buffer = try? AVAudioPCMBuffer(url: url) else {
    //   Log("failed to load sample", url.deletingPathExtension().lastPathComponent)
    //   return
    // }
    
    guard let buffer = Cookbook.fullLengthBuffer(url: url) else {
      Log("failed to load sample", url.deletingPathExtension().lastPathComponent)
      return
    }
    
    // conductor.player.file = try? AVAudioFile(forReading: url)
    conductor.player.file = nil
    conductor.player.isLooping = true
    conductor.player.buffer = buffer
    
    Log("buffer length:", buffer.frameLength)
    Log("buffer duration:", Double(buffer.frameLength) / buffer.format.sampleRate)
    
    if isPlaying {
      conductor.player.play()
    }
    
    bufferChangeHandler?()
  }
}

#Preview {
  ChorusView()
}
