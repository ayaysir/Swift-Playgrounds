//
//  StringResonator.swift
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

class StringResonatorConductor: BasicEffectConductor<StringResonator> {
  init() {
    super.init(source: .strings) { input in
      StringResonator(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   StringResonator의 파라미터 목록:
   Fundamental Frequency | 100.0 | 12.0...10000.0
   Feedback | 0.95 | 0.0...1.0
   */
}

struct StringResonatorView: View {
  @StateObject private var conductor = StringResonatorConductor()
  
  var body: some View {
    BasicEffectView<StringResonator>(
      navTitle: "String Resonator",
      conductor: conductor
    )
  }
}

#Preview {
  StringResonatorView()
}
