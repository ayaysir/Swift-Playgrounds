//
//  TransientShaper.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/11/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class TransientShaperConductor: BasicEffectConductor<TransientShaper> {
  init() {
    super.init(source: .drums) { input in
      TransientShaper(input) // from DunneAudioKit
    }
  }
  
  /*
   TransientShaper의 파라미터 목록:
   Input | 0.0 | -60.0...30.0
   Attack | 0.0 | -40.0...40.0
   Release | 0.0 | -40.0...40.0
   Output | 0.0 | -60.0...30.0
   */
}

struct TransientShaperView: View {
  @StateObject private var conductor = TransientShaperConductor()
  
  var body: some View {
    BasicEffectView<TransientShaper>(
      navTitle: "Transient Shaper",
      conductor: conductor
    )
  }
}

#Preview {
  TransientShaperView()
}
