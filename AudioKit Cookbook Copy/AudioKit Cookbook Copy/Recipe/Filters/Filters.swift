//
//  Filters.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/15/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class FiltersConductor: ObservableObject, ProcessesPlayerInput {
  let engine = AudioEngine()
  let player = AudioPlayer()
  var dryWetMixer: DryWetMixer!
  let buffer: AVAudioPCMBuffer
  let defaultSource: GlobalSource = .drums
  
  @Published var params: [NodeParameter] = []
  var filter: (any Node)? = nil {
    didSet {
      params = filter?.parameters ?? []
    }
  }
  
  init(filterName: String = "BandPassButterworthFilter") {
    buffer = Cookbook.sourceBuffer(source: defaultSource)
    player.buffer = buffer
    player.isLooping = true
    
    changeFilter(filterName: filterName)
  }
  
  func changeFilter(filterName: String) {
    guard let factory = FILTERS[filterName] else {
      fatalError("Unknown filter name: \(filterName)")
    }
    
    self.filter = factory()
    dryWetMixer = DryWetMixer(player, self.filter!)
    dryWetMixer.balance = 1.0
    engine.output = dryWetMixer
    
    self.filter!.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
  
  lazy var FILTERS: [String: () -> Node] = {
    return [
      "BandPassButterworthFilter": { BandPassButterworthFilter(self.player) },
      "BandRejectButterworthFilter": { BandRejectButterworthFilter(self.player) },
      "EqualizerFilter": { EqualizerFilter(self.player) },
      "FormantFilter": { FormantFilter(self.player) },
      "HighPassButterworthFilter": { HighPassButterworthFilter(self.player) },
      "HighPassFilter": { HighPassFilter(self.player) },
      "HighShelfFilter": { HighShelfFilter(self.player) },
      "HighShelfParametricEqualizerFilter": { HighShelfParametricEqualizerFilter(self.player) },
      "KorgLowPassFilter": { KorgLowPassFilter(self.player) },
      "LowPassButterworthFilter": { LowPassButterworthFilter(self.player) },
      "LowPassFilter": { LowPassFilter(self.player) },
      "LowShelfFilter": { LowShelfFilter(self.player) },
      "LowShelfParametricEqualizerFilter": { LowShelfParametricEqualizerFilter(self.player) },
      "ModalResonanceFilter": { ModalResonanceFilter(self.player) },
      "MoogLadder": { MoogLadder(self.player) },
      "PeakingParametricEqualizerFilter": { PeakingParametricEqualizerFilter(self.player) },
      "ResonantFilter": { ResonantFilter(self.player) },
      "ThreePoleLowpassFilter": { ThreePoleLowpassFilter(self.player) },
      "ToneComplementFilter": { ToneComplementFilter(self.player) },
      "ToneFilter": { ToneFilter(self.player) }
    ]
  }()
  
  var filterNames: [String] {
    Array(FILTERS.keys.sorted())
  }
}

struct FiltersView: View {
  @StateObject private var conductor = FiltersConductor()
  @State private var segmentIndex = 0
  @State private var navTitle = "Filters"
  @State private var forceRefresh = 0

  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      HStack {
        ForEach(conductor.params) {
          ParameterRow(param: $0)
        }
        ParameterRow(param: conductor.dryWetMixer.parameters[0])
      }
      .frame(maxHeight: 150)
      
      Picker("Tab", selection: $segmentIndex) {
        Text("Visualizer")
          .tag(0)
        Text("Filters")
          .tag(1)
      }
      .pickerStyle(.segmented)
      
      TabView(selection: $segmentIndex) {
        DryWetMixView(
          dry: conductor.player,
          wet: conductor.filter!,
          mix: conductor.dryWetMixer
        )
        .id(forceRefresh)
        .tag(0)
        
        FilterListArea
          .tag(1)
      }
      .tabViewStyle(.page)
    }
    .padding(10)
    .navigationTitle(navTitle.spacedCamelCase)
    .onAppear {
      conductor.start()
      navTitle = "BandPassButterworthFilter"
    }
    .onDisappear {
      conductor.stop()
    }
  }
  
  private var FilterListArea: some View {
    ScrollView {
      ForEach(conductor.filterNames, id: \.self) { key in
        Button {
          conductor.changeFilter(filterName: key)
          navTitle = key
          forceRefresh += 1
          
          if conductor.player.isPlaying {
            conductor.player.stop()
            conductor.player.start()
          }
        } label: {
          Text("\(key.spacedCamelCase)")
            .frame(height: 15)
            .frame(maxWidth: .infinity)
        }
        .tagStyle(navTitle == key ? .prominent : .bordered)
        .tint(.gray)
      }
      Rectangle()
        .fill(.clear)
        .frame(height: 30)
    }
  }
}

#Preview {
  FiltersView()
}

/*
 파라미터
 
 AudioKit
 
 "HighPassFilter"
 Cutoff Frequency | 6900.0 | 10.0...22050.0
 Resonance | 0.0 | -20.0...40.0
 
 "HighShelfFilter"
 Cut Off Frequency | 10000.0 | 10000.0...22050.0
 Gain | 0.0 | -40.0...40.0
 
 "LowPassFilter":
 Cutoff Frequency | 6900.0 | 10.0...21829.5
 Resonance | 0.0 | -20.0...40.0
 
 "LowShelfFilter":
 Cutoff Frequency | 80.0 | 10.0...200.0
 Gain | 0.0 | -40.0...40.0
 
 =======
 
 SoundpipeAudioKit
 
 "BandPassButterworthFilter":
 Center Frequency | 2000.0 | 12.0...20000.0
 Bandwidth | 100.0 | 0.0...20000.0
 
 "BandRejectButterworthFilter":
 Center Frequency | 3000.0 | 12.0...20000.0
 Bandwidth | 2000.0 | 0.0...20000.0
 
 "EqualizerFilter":
 Center Frequency | 1000.0 | 12.0...20000.0
 Bandwidth | 100.0 | 0.0...20000.0
 Gain | 1.0 | 0.0...20.0
 
 "FormantFilter":
 Center Frequency | 1000.0 | 12.0...20000.0
 Attack duration | 0.007 | 0.0...0.1
 Decay duration | 0.04 | 0.0...0.1
 
 "HighPassButterworthFilter":
 Cutoff Frequency | 500.0 | 12.0...20000.0

 "HighShelfParametricEqualizerFilter":
 Corner Frequency | 1000.0 | 12.0...20000.0
 Gain | 1.0 | 0.0...10.0
 Q | 0.707 | 0.0...2.0
 
 "KorgLowPassFilter":
 Filter cutoff | 1000.0 | 0.0...22050.0
 Resonance | 1.0 | 0.0...2.0
 Saturation | 0.0 | 0.0...10.0
 
 "LowPassButterworthFilter":
 Cutoff Frequency | 1000.0 | 12.0...20000.0

 "LowShelfParametricEqualizerFilter":
 Corner Frequency | 1000.0 | 12.0...20000.0
 Gain | 1.0 | 0.0...10.0
 Q | 0.707 | 0.0...2.0
 
 "ModalResonanceFilter":
 Resonant Frequency | 500.0 | 12.0...20000.0
 Quality Factor | 50.0 | 0.0...100.0
 
 "MoogLadder":
 Cutoff Frequency | 1000.0 | 12.0...20000.0
 Resonance | 0.5 | 0.0...2.0
 
 "PeakingParametricEqualizerFilter":
 Center Frequency | 1000.0 | 12.0...20000.0
 Gain | 1.0 | 0.0...10.0
 Q | 0.707 | 0.0...2.0
 
 "ResonantFilter":
 Frequency | 4000.0 | 100.0...20000.0
 Bandwidth of the filter. | 1000.0 | 0.0...10000.0
 
 "ThreePoleLowpassFilter":
 Distortion | 0.5 | 0.0...2.0
 Cutoff Frequency | 1500.0 | 12.0...20000.0
 Resonance | 0.5 | 0.0...2.0
 
 "ToneComplementFilter":
 Half-Power Point | 1000.0 | 12.0...20000.0
 
 "ToneFilter":
 Half-Power Point | 1000.0 | 12.0...20000.0
 */
