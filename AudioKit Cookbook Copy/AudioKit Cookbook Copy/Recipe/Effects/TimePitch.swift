//
//  TimePitch.swift
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

// With TimePitch you can easily change the pitch and speed of a player-generated sound.  It does not work on live input or generated signals.

struct TimePitchData {
  var rate: AUValue = 2.0
  var pitch: AUValue = -400
}

class TimePitchConductor: BasicEffectConductor<TimePitch> {
  init() {
    super.init(source: .strings, isUseDryWetMixer: false) { input in
      let timePitch = TimePitch(input) // from AudioKit
      timePitch.rate = 2.0
      timePitch.pitch = -400
      return timePitch
    }
  }
  
  @Published var data = TimePitchData() {
    didSet {
      // When AudioKit uses an Apple AVAudioUnit, like the case here, the values can't be ramped
      effect.rate = data.rate
      effect.pitch = data.pitch
    }
  }
}

struct TimePitchView: View {
  @StateObject private var conductor = TimePitchConductor()
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        CookbookKnob(
          text: "Rate (재생 속도)",
          parameter: $conductor.data.rate,
          range: 0.3125...5,
          units: "Generic"
        )
        CookbookKnob(
          text: "Pitch",
          parameter: $conductor.data.pitch,
          range: -2400...2400,
          units: "Cents"
        )
      }
      NodeOutputView(conductor.effect)
    }
    .padding()
    .navigationTitle("Time / Pitch")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  TimePitchView()
}
