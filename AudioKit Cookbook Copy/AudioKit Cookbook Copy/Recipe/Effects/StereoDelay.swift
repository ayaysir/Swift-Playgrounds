//
//  StereoDelay.swift
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

class StereoDelayConductor: BasicEffectConductor<StereoDelay> {
  init() {
    super.init(source: .strings) { input in
      StereoDelay(input) // DunneAudioKit
    }
  }
  
  /*
   StereoDelay의 파라미터 목록:
   
   Delay time (Seconds) | 0.0 | 0.0...2.0
   Feedback (%) | 0.0 | 0.0...1.0
   Dry-Wet Mix | 0.5 | 0.0...1.0
   Ping-Pong Mode | 0.0 | 0.0...1.0
   */
}

struct StereoDelayView: View {
  @StateObject private var conductor = StereoDelayConductor()
  
  var body: some View {
    BasicEffectView<StereoDelay>(
      navTitle: "Stereo Delay",
      conductor: conductor
    )
  }
}

#Preview {
  StereoDelayView()
}
