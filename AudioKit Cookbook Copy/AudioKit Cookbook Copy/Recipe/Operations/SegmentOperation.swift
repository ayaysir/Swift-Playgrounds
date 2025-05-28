//
//  SegmentOperation.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/21/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class SegmentOperationConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  
  @Published var isRunning = false {
    didSet {
      isRunning ? generator.start() : generator.stop()
    }
  }
  
  @Published var interval: AUValue = 0.5 {
    didSet {
      // interval (초) → Hz 변환: 1초에 몇 번 발생할지
      generator.parameter1 = 1.0 / interval
    }
  }
  
  @Published var waveform: AUValue = 0 {
    didSet {
      generator.parameter2 = waveform
    }
  }
  
  @Published var currentHz: AUValue = 0
  
  let generator = OperationGenerator { params in
    let updateRate = params[0]
    let wavefromSelector = params[1]
    
    // Vary the starting frequency and duration randomly
    // 300Hz부터 2300Hz 사이의 주파수를 무작위로 선택
    // Operation.randomNumberPulse() : 0 ~ 1 랜덤 생성
    let start = Operation.randomNumberPulse() * 2000 + 300
    let duration = Operation.randomNumberPulse()
    let frequency = Operation.lineSegment(
      trigger: Operation.metronome(frequency: updateRate),
      start: start,
      end: 0,
      duration: duration
    )
    
    // Decrease the amplitude exponentially
    let amplitude = Operation.exponentialSegment(
      trigger: Operation.metronome(frequency: updateRate),
      start: 0.3,
      end: 0.01,
      duration: 1.0
    )
    
    // 조건에 따라 파형 선택 (0이면 sine, 1이면 square)
    let sine = Operation.sineWave(frequency: frequency, amplitude: amplitude)
    let square = Operation.square(frequency: frequency) * amplitude
    
    // selector == 0이면 sine만 나오고, == 1이면 square만 나옴
    let mix = sine * (1 - wavefromSelector) + square * wavefromSelector
    return mix
  }
  
  init() {
    let delay = Delay(generator)
    generator.parameter1 = 2
    generator.parameter2 = 0
    // Add some effects for good fun
    delay.time = 0.125
    delay.feedback = 0.8
    let reverb = Reverb(delay)
    reverb.loadFactoryPreset(.largeHall)
    engine.output = reverb
  }
}

struct SegmentOperationView: View {
  @StateObject private var conductor = SegmentOperationConductor()
  
  var body: some View {
    VStack {
      Text(verbatim: #"Creating segments that vary parameters in operations linearly or exponentially over a certain duration."#)
      Divider()
      Text(verbatim: #"특정 기간 동안 작업의 매개변수를 선형적 또는 기하급수적으로 변경하는 세그먼트를 만듭니다."#)
      Divider()
      Button(conductor.isRunning ? "STOP" : "START") {
        conductor.isRunning.toggle()
      }
      Divider()
      HStack {
        Text("Interval: \(String(format: "%.1f", conductor.interval)) sec")
          .font(.subheadline)
        Slider(
          value: $conductor.interval,
          in: 0.1...2.0,
          step: 0.1
        ) {
          Text("Interval")
        }
      }
      HStack {
        Text("Waveform")
          .font(.headline)

        Picker("Waveform", selection: $conductor.waveform) {
          Text("Sine").tag(AUValue(0))
          Text("Square").tag(AUValue(1))
        }
        .pickerStyle(.segmented)
      }
      
      NodeOutputView(conductor.generator)
    }
    .padding()
    .navigationTitle("Segment Operation")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  SegmentOperationView()
}
