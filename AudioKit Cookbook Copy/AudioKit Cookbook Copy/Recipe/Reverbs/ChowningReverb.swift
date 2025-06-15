//
//  ChowningReverb.swift
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

class ChowningReverbConductor: BasicEffectConductor<ChowningReverb> {
  init() {
    super.init(source: .drums) { input in
      ChowningReverb(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   ChowningReverb의 파라미터 목록:
   Balance | 1.0 | 0.0...1.0
   */
}

struct ChowningReverbView: View {
  @StateObject private var conductor = ChowningReverbConductor()
  
  var body: some View {
    BasicEffectView<ChowningReverb>(
      navTitle: "Chowning Reverb",
      conductor: conductor,
      isShowDrywetBalanceParameter: false
    )
  }
}

#Preview {
  ChowningReverbView()
}
