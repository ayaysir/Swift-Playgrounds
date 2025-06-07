//
//  MultiTapDelay.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/7/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class MultiTapDelayConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .femaleVoice
  
  private var delays = [VariableDelay]()
  private var faders = [Fader]()
  
  // 슬라이더로 조절할 수 있는 값
  @Published var times: [AUValue] = [0.1, 0.2, 0.4]
  @Published var gains: [AUValue] = [0.5, 2.0, 0.5]

  init() {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    engine.output = multiTapDelay(
      player,
      times: times,
      gains: gains
    )
  }
  
  func multiTapDelay(
    _ input: Node,
    times: [AUValue],
    gains: [AUValue]
  ) -> Mixer {
    let mix = Mixer(input)
    
    for (i, (time, gain)) in zip(times, gains).enumerated() {
      delays.append(VariableDelay(input, time: time))
      faders.append(Fader(delays[i], gain: gain))
      mix.addInput(faders[i])
    }
    
    return mix
  }
  
  func updateDelays() {
    for i in delays.indices {
      if i < times.count {
        delays[i].time = times[i]
      }
      if i < gains.count {
        faders[i].gain = gains[i]
      }
    }
  }
}

struct MultiTapDelayView: View {
  @StateObject private var conductor = MultiTapDelayConductor()
  
  var body: some View {
    ScrollView{
      VStack {
        PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
        ForEach(0..<3, id: \.self) { i in
          VStack {
            Text("Delay \(i + 1)")
              .font(.headline)
            
            HStack {
              Text("Time: \(conductor.times[i], specifier: "%.2f")s")
              Slider(value: $conductor.times[i], in: 0...1)
            }
            
            HStack {
              Text("Gain: \(conductor.gains[i], specifier: "%.2f")")
              Slider(value: $conductor.gains[i], in: 0...2)
            }
          }
          .padding(.bottom)
        }

        Divider()
        Text("""
        A multi-tap delay is a delay line where multiple 'taps' or outputs are taken from a delay buffer at different points, and the taps are then summed with the original. Multi-tap delays are great for creating rhythmic delay patterns, but they can also be used to create sound fields of such density that they start to take on some of the qualities we'd more usually associate with reverb.

        - Geoff Smith, Sound on Sound
        """)
        Divider()
        Text("""
        멀티탭 딜레이(Multi-tap delay)는 하나의 딜레이 버퍼에서 여러 지점(‘탭’)에서 출력을 추출하고, 그 탭들을 원래의 신호와 합쳐서 출력하는 딜레이 방식입니다.
        멀티탭 딜레이는 리듬감 있는 딜레이 패턴을 만드는 데 매우 유용하지만, 탭을 충분히 조밀하게 배치하면 리버브(reverb)와 유사한 성질을 갖는 사운드 필드(sound field)를 만들어낼 수도 있습니다.

        – 제프 스미스, Sound on Sound
        """)
        Divider()
      }
    }
    .padding()
    .navigationTitle("Multi Tap Delay")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
    .onChange(of: conductor.times) {
      conductor.updateDelays()
    }
    .onChange(of: conductor.gains) {
      conductor.updateDelays()
    }
  }
}

#Preview {
  MultiTapDelayView()
}
