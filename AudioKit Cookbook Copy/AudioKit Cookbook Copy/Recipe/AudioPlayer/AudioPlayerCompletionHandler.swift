//
//  AudioPlayerCompletionHandler.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/18/25.
//

import AudioKit
import AVFoundation
import SwiftUI
import AudioKitUI

class AudioPlayerCompletionHandlerConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var player = AudioPlayer()
  var sources = GlobalSource.allCases
  var sourceFiles: [GlobalSource : AVAudioFile] = [:]
  var callbackLoop: CallbackLoop!
  var isManualSelection = false
  @Published var currentFileIndex = 0
  @Published var playDuration = 0.0
  @Published var currentTime = 0.0
  
  var currentSource: GlobalSource {
    sources[currentFileIndex]
  }
   
  init() {
    engine.output = player
    
    callbackLoop = CallbackLoop(every: 0.1) {
      self.currentTime = self.player.currentTime
    }
    
    for source in sources {
      if let url = Bundle.main.resourceURL?.appending(path: source.filePath),
         let file = try? AVAudioFile(forReading: url) {
        sourceFiles[source] = file
      }
    }
    
    // 플레이어에서 현재 재생이 끝나면, playNextFile을 컴플리션 핸들러로 지정
    player.completionHandler = playNextFile
  }
  
  
  /// currentIndex를 1 올리고(또는 리셋) startPlaying() 실행
  func playNextFile() {
    guard !isManualSelection else {
      isManualSelection = false
      return
    }
    
    if currentFileIndex < sources.count - 1 {
      currentFileIndex += 1
    } else {
      currentFileIndex = 0
    }
    
    preparePlaying()
  }
  
  /// 현재 currentFileIndex의 url을 재생, playDuration에 duration 할당
  func preparePlaying() {
    guard let file = sourceFiles[currentSource] else {
      return
    }
    
    do {
      try player.load(file: file)
      // player.play()
      
      if let duration = player.file?.duration {
        playDuration = duration
      }
      
      callbackLoop.stop()
      callbackLoop.start()
    } catch {
      Log(error)
    }
  }
  
  func togglePlaying() {
    if player.isPlaying {
      player.pause()
    } else {
      // 중간에 정지된 경우 그 위치에서 다시 시작 (처음부터 시작 안함)
      player.start()
    }
  }
}

struct AudioPlayerCompletionHandlerView: View {
  @StateObject private var conductor = AudioPlayerCompletionHandlerConductor()
  
  var body: some View {
    VStack {
      Text("AudioPlayer Completion Handler")
        .font(.title2)
        .bold()
      Divider()
      Text("This will play one file. Once it completes, it will play another. That's one thing a completion handler can do.")
      Divider()
      PlaylistArea
      Divider()
      PlayerArea
      NodeOutputView(conductor.player)
    }
    .padding()
    .navigationTitle("Audio Player Completion Handler")
    .onAppear {
      conductor.start()
      conductor.preparePlaying()
    }
    .onDisappear {
      conductor.stop()
    }
  }
  
  private var PlayerArea: some View {
    let playLabel = "Playing: " + (conductor.currentSource.name)
    return HStack {
      Button(action: conductor.togglePlaying) {
        Image(systemName: conductor.player.isPlaying ? "pause.fill" : "play.fill")
      }
      VStack(alignment: .leading) {
        ProgressView(
          value: conductor.currentTime,
          total: conductor.playDuration
        ) {
          Text(playLabel)
        }
        
        HStack {
          Text(formatTime(conductor.currentTime))
          Spacer()
          Text(formatTime(conductor.playDuration))
        }
        .font(.caption)
        .foregroundStyle(.secondary)
      }
    }
  }
  
  private var PlaylistArea: some View {
    VStack(alignment: .leading) {
      ForEach(conductor.sources.indices, id: \.self) { i in
        let source = conductor.sources[i]
        let duration = conductor.sourceFiles[source]?.duration ?? 0
        let durationString = formatTime(duration)
        
        HStack {
          Button {
            // 현재 재생중이 아닌 경우 플레이어를 스탑시켜 원상태로 복귀
            // 현재 재생중인 경우 저절로 재생을 계속해서 이어나감
            if !conductor.player.isPlaying {
              conductor.player.stop()
            }
            
            conductor.isManualSelection = true
            conductor.currentFileIndex = i
            conductor.preparePlaying()
          } label: {
            if conductor.currentSource == source {
              Text(source.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
            } else {
              Text(source.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .tint(.primary)
            }
          }
          Spacer()
          // 총 길이 표시
          Text(durationString)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
  }
  
  private func formatTime(_ seconds: Double) -> String {
    let intSeconds = Int(seconds)
    let minutes = intSeconds / 60
    let remainingSeconds = intSeconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }
}

#Preview {
  AudioPlayerCompletionHandlerView()
}
