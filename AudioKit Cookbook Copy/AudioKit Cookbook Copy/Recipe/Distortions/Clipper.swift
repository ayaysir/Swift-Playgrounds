//
//  Clipper.swift
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

class ClipperConductor: BasicEffectConductor<Clipper> {
  init() {
    super.init(source: .guitar) { input in
      Clipper(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   Clipper의 파라미터 목록:
   Threshold | 1.0 | 0.0...1.0
   */
}

struct ClipperView: View {
  @StateObject private var conductor = ClipperConductor()
  
  var body: some View {
    BasicEffectView<Clipper>(
      navTitle: "Clipper",
      conductor: conductor
    )
  }
}

#Preview {
  ClipperView()
}
