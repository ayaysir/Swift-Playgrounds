//
//  Tremolo.swift
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

class TremoloConductor: BasicEffectConductor<Tremolo> {
  init() {
    super.init(source: .strings) { input in
      Tremolo(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   Tremolo의 파라미터 목록:
   Frequency | 10.0 | 0.0...100.0
   Depth | 1.0 | 0.0...1.0
   */
}

struct TremoloView: View {
  @StateObject private var conductor = TremoloConductor()
  
  var body: some View {
    BasicEffectView<Tremolo>(
      navTitle: "Tremolo",
      conductor: conductor
    )
  }
}

#Preview {
  TremoloView()
}
