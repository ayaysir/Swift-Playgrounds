//
//  WaveFormView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/20/25.
//

import Foundation
import AudioKit
import AVFoundation
import SwiftUI
import Waveform

class WaveformConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  @Published var samples: SampleBuffer!
  
  init() {
    player.buffer = Cookbook.sourceBuffer(source: .piano)
    player.isLooping = true
    
    createSampleBuffer()
    engine.output = player
  }
  
  func createSampleBuffer() {
    guard let playerBuffer = player.buffer else {
      return
    }
    
    self.samples = SampleBuffer(samples: playerBuffer.toFloatChannelData()![0])
  }
}

struct WaveformView: View {
  @StateObject var conductor = WaveformConductor()
  @State private var start = 0.0
  @State private var length = 1.0
  
  let formatter = NumberFormatter()
  
  var body: some View {
    let sampleRangeLength = Double(conductor.samples.count - 1)
    
    VStack {
      Text("start: \(start), length: \(length), end: \(start + length)")
        .monospaced()
        .font(.system(size: 12))
      
      PlayerControlsII(conductor: conductor, source: .piano) {
        conductor.createSampleBuffer()
      }
      
      ZStack {
        Waveform(samples: conductor.samples)
          .foregroundColor(.pink)
        MinimapView(start: $start, length: $length)
      }
      .padding(.leading, 0)
      .padding(.trailing, 20)
      .frame(height: 100)
      
      Waveform(
        samples: conductor.samples,
        start: Int(start * sampleRangeLength),
        length: Int(length * sampleRangeLength)
      )
      .foregroundColor(.teal)
    }
    .padding()
    .navigationTitle("Waveform Demo")
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
  }
}

struct MinimapView: View {
  @Binding var start: Double
  @Binding var length: Double
  
  @GestureState var initialStart: Double?
  @GestureState var initialLength: Double?
  
  let indicatorSize: CGFloat = 10.0
  
  var body: some View {
    GeometryReader { geometry in
      RoundedRectangle(cornerRadius: indicatorSize)
        .frame(width: length * geometry.size.width)
        .offset(x: start * geometry.size.width)
        .opacity(0.1)
        .gesture(
          dragGesture(of: .selectedArea, geometryProxy: geometry)
        )
      
      // 우측 핸들
      HStack(spacing: 0) {
        // leading padding
        Rectangle()
          .fill(.clear)
          .frame(width: indicatorSize)
          .contentShape(Rectangle())
        RoundedRectangle(cornerRadius: indicatorSize)
          .frame(width: indicatorSize)
          .padding(.vertical, indicatorSize)
          .contentShape(Rectangle())
          .opacity(0.3)
        Rectangle()
          .fill(.clear)
          .frame(width: indicatorSize * 3)
          .contentShape(Rectangle())
      }
      .offset(x: (start + length) * geometry.size.width)
      .gesture(
        dragGesture(of: .handle, geometryProxy: geometry)
      )
      
    }
  }
  
  enum DragMode {
    case selectedArea, handle
  }
  
  func dragGesture(
    of mode: DragMode,
    geometryProxy geometry: GeometryProxy
  ) -> some Gesture {
    let bindingVariable = mode == .selectedArea ? $initialStart : $initialLength
    
    return DragGesture()
      .updating(bindingVariable) { _, ioState, _ in
          if ioState == nil {
            ioState = mode == .selectedArea ? start : length
          }
        }
      .onChanged { drag in
        switch mode {
        case .selectedArea:
          if let initialStart {
            start = (initialStart + drag.translation.width / geometry.size.width)
              .clamped(to: 0...(1 - length))
          }
        case .handle:
          if let initialLength {
            length = (initialLength + drag.translation.width / geometry.size.width)
              .clamped(to: 0...(1 - start))
          }
        }
      }
  }
}

#Preview {
  WaveformView()
}
