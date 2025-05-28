//
//  AutoPanner.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/28/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class AutoPannerConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  
  let panner: AutoPanner
  var mixer: Mixer
  
  init() {
    buffer = Cookbook.sourceBuffer(source: "Piano")
    player.buffer = buffer
    player.isLooping = true
    
    panner = AutoPanner(player)
    dryWetMixer = DryWetMixer(player, panner)
    
    mixer = Mixer(dryWetMixer)
    engine.output = mixer
    /*
     Panner의 파라미터 값:
     
     Frequency | 10.0 | 0.0...100.0
     Depth | 1.0 | 0.0...1.0
     */
    
    panner.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
  
  @Published var pan: AUValue = 0 {
    didSet { mixer.pan = pan }
  }
}


/**
 `AutoPanner`는 **오디오 신호의 위치를 자동으로 좌우로 이동(Panning)** 시키는 효과(이펙트)입니다. 음악에서 흔히 말하는 “스테레오 공간에서의 움직임”을 만들 수 있게 해주는 도구로, **리듬감이나 공간감을 더해주는 데 유용**합니다.

 ---

 ## 🎛️ `AutoPanner`의 역할

 * 입력된 오디오를 **좌우 스피커로 시간에 따라 자동 이동**시킴
 * 예: 좌→우→좌→우 식으로 반복되면서 사운드가 **흔들리거나 회전하는 듯한 공간감**을 형성
 * 흔히 **Ambient, Electronic, Lo-Fi** 음악에서 활용됨

 ---

 ## 🧾 주요 파라미터 설명

 | 파라미터 이름     | 기본값    | 범위              | 설명                                                               |
 | ----------- | ------ | --------------- | ---------------------------------------------------------------- |
 | `frequency` | `10.0` | `0.0 ... 100.0` | **초당 몇 번 좌우 이동(pan)** 할지를 의미하는 속도 (단위: Hz)<br>값이 클수록 빠르게 움직임     |
 | `depth`     | `1.0`  | `0.0 ... 1.0`   | **좌우 이동의 범위(강도)**<br>`0`은 전혀 이동하지 않고, `1.0`은 완전히 왼쪽과 오른쪽으로 반복 이동 |

 ---

 ## 📊 예시

 * `frequency = 0.5`, `depth = 1.0` → 좌우로 천천히 크게 이동 (느린 스윙 느낌)
 * `frequency = 10`, `depth = 0.3` → 빠르게 미세하게 이동 (가벼운 진동 느낌)
 * `frequency = 0`, `depth = 1.0` → 움직이지 않음 (panning 비활성)

 ---

 ## 🎧 시청각적 효과

 * 🎵 **좌우 스피커를 활용하여 청자에게 움직임을 주는 것**
 * 🧠 **정적인 음원에 생동감 부여**
 * 🎚️ 다이내믹 믹싱 시 **공간 분리 및 집중도 향상**

 ---

 즉, `AutoPanner`는 **오디오에 '공간적 움직임'을 부여하는 간단하면서도 강력한 이펙트**이며, `frequency`와 `depth`는 **속도와 강도**를 조절하는 핵심 요소입니다.

 */
struct AutoPannerView: View {
  @StateObject private var conductor = AutoPannerConductor()
  
  var body: some View {
    VStack {
      PlayerControls(conductor: conductor, sourceName: "Piano")
      HStack {
        ForEach(conductor.panner.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
        CookbookKnob(
          text: "Mixer Pan",
          parameter: $conductor.pan,
          range: -1.0...1.0,
          units: "L/R"
        )
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.panner,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("Auto Panner")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  AutoPannerView()
}
