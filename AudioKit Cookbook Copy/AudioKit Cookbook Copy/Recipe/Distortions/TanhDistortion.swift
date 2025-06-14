//
//  TanhDistortion.swift
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

class TanhDistortionConductor: BasicEffectConductor<TanhDistortion> {
  init() {
    super.init(source: .drums) { input in
      TanhDistortion(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   TanhDistortion의 파라미터 목록:
   Pregain | 2.0 | 0.0...10.0
   Postgain | 0.5 | 0.0...10.0
   Positive Shape Parameter | 0.0 | -10.0...10.0
   Negative Shape Parameter | 0.0 | -10.0...10.0
   */
}

struct TanhDistortionView: View {
  @StateObject private var conductor = TanhDistortionConductor()
  
  var body: some View {
    VStack {
      Text("⚠️ 주의: 값을 너무 크게 설정하면 깨진 소음이 발생할 수 있습니다.")
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(.red)
      BasicEffectView<TanhDistortion>(
        navTitle: "Tanh Distortion",
        conductor: conductor
      )
    }
  }
}

#Preview {
  TanhDistortionView()
}
