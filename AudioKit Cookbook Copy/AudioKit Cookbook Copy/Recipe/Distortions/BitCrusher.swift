//
//  BitCrusher.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/13/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class BitCrusherConductor: BasicEffectConductor<BitCrusher> {
  init() {
    super.init(source: .guitar) { input in
      BitCrusher(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   BitCrusher의 파라미터 목록:
   Bit Depth | 8.0 | 1.0...24.0
   Sample Rate | 10000.0 | 0.0...20000.0
   */
}

struct BitCrusherView: View {
  @StateObject private var conductor = BitCrusherConductor()
  
  var body: some View {
    BasicEffectView<BitCrusher>(
      navTitle: "Bit Crusher",
      conductor: conductor
    )
  }
}

#Preview {
  BitCrusherView()
}
