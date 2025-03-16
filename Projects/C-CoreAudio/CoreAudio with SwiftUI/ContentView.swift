//
//  ContentView.swift
//  CoreAudio with SwiftUI
//
//  Created by 윤범태 on 3/16/25.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
  @Environment(\.scenePhase) var phase
  @StateObject var manager: AudioManager = .init()
  @State private var isOn = false
  
  var body: some View {
    VStack {
      Button {
        isOn.toggle()
      } label: {
        Image(systemName: "speaker.wave.3.fill")
          .imageScale(.large)
          .foregroundStyle(.tint)
        Text("Generate Sine Wave")
      }
    }
    .padding()
    .onAppear {
      manager.audioSessionInitialize()
    }
    .onChange(of: isOn) {
      if isOn {
        manager.startAudioQueue()
      } else {
        manager.stopAudioQueue()
      }
    }
    .onChange(of: phase) {
      switch phase {
      case .background, .inactive:
        manager.chnageFrequency(to: BACKGROUND_FREQ)
      case .active:
        manager.chnageFrequency(to: FOREGROUND_FREQ)
      @unknown default:
        return
      }
    }
    .onReceive(manager.publisher) { notification in
      manager.handleInterruption(notification: notification)
    }
  }
}


#Preview {
  ContentView()
}
