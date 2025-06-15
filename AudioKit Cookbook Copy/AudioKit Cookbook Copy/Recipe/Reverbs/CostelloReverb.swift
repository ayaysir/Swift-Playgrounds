//
//  CostelloReverb.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/15/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class CostelloReverbConductor: BasicEffectConductor<CostelloReverb> {
  init() {
    super.init(source: .drums) { input in
      CostelloReverb(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   CostelloReverb의 파라미터 목록:
   Feedback | 0.6 | 0.0...1.0
   Cutoff Frequency | 4000.0 | 12.0...20000.0
   Balance | 1.0 | 0.0...1.0
   */
}

struct CostelloReverbView: View {
  @StateObject private var conductor = CostelloReverbConductor()
  
  var body: some View {
    BasicEffectView<CostelloReverb>(
      navTitle: "Costello Reverb",
      conductor: conductor,
      isShowDrywetBalanceParameter: false
    )
  }
}

#Preview {
  CostelloReverbView()
}
