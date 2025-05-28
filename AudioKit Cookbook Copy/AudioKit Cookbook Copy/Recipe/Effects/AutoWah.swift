//
//  AutoWah.swift
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

class AutoWahConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  let dryWetMixer: DryWetMixer
  let buffer: AVAudioPCMBuffer
  
  let autoWah: AutoWah
  
  init() {
    buffer = Cookbook.sourceBuffer(source: "Guitar")
    player.buffer = buffer
    player.isLooping = true
    
    autoWah = AutoWah(player)
    dryWetMixer = DryWetMixer(player, autoWah)
    engine.output = dryWetMixer
    
    /*
     AutoWah의 파라미터 값:
     
     Wah Amount | 0.0 | 0.0...1.0
     Dry/Wet Mix | 1.0 | 0.0...1.0
     Overall level | 0.1 | 0.0...1.0
     */
    
    autoWah.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

/**
 `AutoWah`는 기타 이펙트로 유명한 **"와우(Wah)" 필터 효과를 자동화(Auto)한 오디오 효과**입니다. 원래는 연주자가 페달로 조작하는 Wah 필터를 **입력 신호의 강도에 따라 자동으로 작동**하게 한 것이 `AutoWah`입니다.

 ---

 ## 🎛️ AutoWah의 역할

 * **"와우 와우" 소리 같은 음색 변화**를 만들어냅니다.
 * \*\*밴드패스 필터(bandpass filter)\*\*의 중심 주파수를 입력 음의 세기(amplitude)에 따라 자동으로 움직이게 합니다.
 * 즉, **세게 연주할수록 고음이 강조되고, 약하게 연주할수록 저음 중심**으로 필터링됩니다.
 * 기타, 베이스, 신스 등에서 많이 사용되며 **펑키한 느낌**, **말하는 듯한 소리**를 연출할 때 유용합니다.

 ---

 ## 🧾 파라미터 설명

 | 이름              | 기본값   | 범위          | 설명                                                                    |
 | --------------- | ----- | ----------- | --------------------------------------------------------------------- |
 | `Wah Amount`    | `0.0` | `0.0...1.0` | Wah 필터의 **효과 강도**<br>값이 클수록 필터 이동폭이 커져 **더 극적인 wah 효과** 발생            |
 | `Dry/Wet Mix`   | `1.0` | `0.0...1.0` | 원본 소리와 Wah 효과가 적용된 소리의 **혼합 비율**<br>`1.0`은 100% Wah만 출력, `0.5`면 반반 믹스 |
 | `Overall level` | `0.1` | `0.0...1.0` | 최종 출력의 **볼륨 조절** (전체 게인)<br>Wah 효과로 음량이 낮아질 수 있으므로 보정용                |

 ---

 ## 🎧 예시 활용

 ```swift
 autoWah.$parameter1.ramp(to: 0.8, duration: 0.1) // Wah Amount
 autoWah.$parameter2.ramp(to: 1.0, duration: 0.1) // Dry/Wet Mix
 autoWah.$parameter3.ramp(to: 0.3, duration: 0.1) // Overall Level
 ```

 * Wah 효과를 강하게 주되, 볼륨은 보정해주는 설정

 ---

 결론적으로, `AutoWah`는 연주의 강도에 따라 자동으로 음색이 변하는 **반응형 필터 효과**이며, 위 세 가지 파라미터를 통해 **효과의 강도, 혼합도, 최종 볼륨**을 유연하게 조절할 수 있습니다.

 */
struct AutoWahView: View {
  @StateObject private var conductor = AutoWahConductor()
  
  var body: some View {
    VStack {
      PlayerControls(conductor: conductor, sourceName: "Guitar")
      HStack {
        ForEach(conductor.autoWah.parameters) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      DryWetMixView(
        dry: conductor.player,
        wet: conductor.autoWah,
        mix: conductor.dryWetMixer
      )
    }
    .padding()
    .navigationTitle("AutoWah")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  AutoWahView()
}
