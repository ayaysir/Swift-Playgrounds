//
//  VariableDelay.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/12/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class VariableDelayConductor: BasicEffectConductor<VariableDelay> {
  init() {
    super.init(source: .strings) { input in
      VariableDelay(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   VariableDelay의 파라미터 목록:
   Delay time | 0.0 | 0.0...10.0
   Feedback | 0.0 | 0.0...1.0
   */
}

struct VariableDelayView: View {
  @StateObject private var conductor = VariableDelayConductor()
  
  var body: some View {
    BasicEffectView<VariableDelay>(
      navTitle: "Variable Delay",
      conductor: conductor
    )
  }
}

#Preview {
  VariableDelayView()
}
