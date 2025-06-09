//
//  PhaseLockedVocoderConductor.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/9/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import Controls
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class PhaseLockedVocoderConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let player = AudioPlayer()
  var phaseLockedVocoder: PhaseLockedVocoder!
  
  init() {
    setup()
  }
  
  private func setup(source: GlobalSource = .drums) {
    guard let url = Bundle.main.resourceURL?.appending(path: source.filePath),
          let file = try? AVAudioFile(forReading: url)
    else {
      fatalError("url/file is nil.")
    }
    
    phaseLockedVocoder = PhaseLockedVocoder(file: file)
    phaseLockedVocoder.amplitude = 1
    phaseLockedVocoder.pitchRatio = 1
    phaseLockedVocoder.start()
    engine.output = phaseLockedVocoder
  }
  
  @Published var source: GlobalSource = .drums {
    didSet { setup(source: source) }
  }
  
  @Published var position: AUValue = 0.0 {
    didSet { phaseLockedVocoder.position = position }
  }
  
  @Published var pitchRatio: AUValue = 1.0 {
    didSet { phaseLockedVocoder.pitchRatio = pitchRatio }
  }

  @Published var amplitude: AUValue = 1.0 {
    didSet { phaseLockedVocoder.amplitude = amplitude }
  }
}

struct PhaseLockedVocoderView: View {
  @StateObject private var conductor = PhaseLockedVocoderConductor()
  @State private var forceRefresh = 0
  
  var body: some View {
    VStack {
      SourcePicker
      Text("Position: \(conductor.position)")
      Ribbon(position: $conductor.position)
        .cornerRadius(10)
        .frame(height: 50)
      AdjustSlides
      NodeOutputView(conductor.phaseLockedVocoder)
        .id(forceRefresh)
    }
    .padding()
    .navigationTitle("Phase Locked Vocoder")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
    .onChange(of: conductor.source) {
      forceRefresh += 1
    }
  }
}

extension PhaseLockedVocoderView {
  private var SourcePicker: some View {
    Picker(
      "Change source",
      selection: $conductor.source) {
        ForEach(GlobalSource.allCases) { source in
          Text("\(source.name)")
            .tag(source)
        }
      }
  }
  
  private var AdjustSlides: some View {
    VStack(spacing: 12) {
      // 🎚 Pitch Ratio Slider
      HStack {
        Text("Pitch Ratio: \(String(format: "%.2f", conductor.pitchRatio))")
        Spacer()
      }
      Slider(value: $conductor.pitchRatio, in: 0.25...4.0, step: 0.01)

      // 📢 Amplitude Slider
      HStack {
        Text("Amplitude: \(String(format: "%.2f", conductor.amplitude))")
        Spacer()
      }
      Slider(value: $conductor.amplitude, in: 0.0...1.0, step: 0.01)
    }
  }
}

#Preview {
  PhaseLockedVocoderView()
}
