//
//  Untitled.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/14/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

//: Decimation is a type of digital distortion like bit crushing,
//: 데시메이션은 비트 크러싱과 같은 디지털 왜곡의 한 유형입니다.
//: but instead of directly stating what bit depth and sample rate you want,
//: 하지만 원하는 비트 심도와 샘플 속도를 직접 지정하는 대신,
//: it is done through setting "decimation" and "rounding" parameters.
//: "데시메이션" 및 "반올림" 매개변수를 설정하여 수행됩니다.

class DecimatorConductor: BasicEffectConductor<Decimator> {
  init() {
    super.init(source: .drums) { input in
      Decimator(input) // from AudioKit
    }
  }
  
  /*
   Decimator의 파라미터 목록:
   Decimation | 50.0 | 0.0...100.0
   Rounding | 0.0 | 0.0...100.0
   Final Mix | 50.0 | 0.0...100.0
   */
}

struct DecimatorView: View {
  @StateObject private var conductor = DecimatorConductor()
  
  var body: some View {
    BasicEffectView<Decimator>(
      navTitle: "Decimator",
      conductor: conductor
    )
  }
}

#Preview {
  DecimatorView()
}
