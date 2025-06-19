//
//  ContentView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/28/25.
//

import SwiftUI

typealias V = AnyView
typealias ViewDict = [String: Lazy<V>]

struct ContentView: View {
  var body: some View {
    NavigationSplitView {
      ListView()
    } detail: {
      Text("detail")
    }
    .navigationSplitViewStyle(.automatic)
  }
}

struct ListView: View {
  @State private var expandMiniApps = false
  @State private var expandOperations = false
  @State private var expandPhysicalModels = false
  @State private var expandEffects = false
  @State private var expandDistortions = false
  @State private var expandReverbs = false
  @State private var expandOscillators = false
  @State private var expandAudioPlayers = false
  @State private var expandLabs = false
  
  var body: some View {
    Form {
      Section(header: Text("Categories")) {
        // 접었다 펼 수 있는 영역을 만듭니다..
        DisclosureGroup("Mini Apps", isExpanded: $expandMiniApps) {
          ForEach(ViewDicts.miniApps.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.miniApps)
          }
        }
        
        DisclosureGroup("Operations", isExpanded: $expandOperations) {
          ForEach(ViewDicts.operations.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.operations)
          }
        }
        
        DisclosureGroup("Physical Models", isExpanded: $expandPhysicalModels) {
          ForEach(ViewDicts.physicalModels.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.physicalModels)
          }
          // Text("More at STKAudioKit").onTapGesture {
          //   if let url = URL(string: "https://www.audiokit.io/STKAudioKit/") {
          //     UIApplication.shared.open(url)
          //   }
          // }
        }
        
        DisclosureGroup("Effects", isExpanded: $expandEffects) {
          ForEach(ViewDicts.effects.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.effects)
          }
        }
        
        DisclosureGroup("Distortions", isExpanded: $expandDistortions) {
          ForEach(ViewDicts.distortions.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.distortions)
          }
        }
        
        DisclosureGroup("Reverbs", isExpanded: $expandReverbs) {
          ForEach(ViewDicts.reverbs.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.reverbs)
          }
        }
        
        NavigationLink("Filters", destination: FiltersView())
        
        DisclosureGroup("Oscillators", isExpanded: $expandOscillators) {
          ForEach(ViewDicts.oscillators.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.oscillators)
          }
        }
        
        DisclosureGroup("Audio Players", isExpanded: $expandAudioPlayers) {
          ForEach(ViewDicts.audioPlayers.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.audioPlayers)
          }
        }
        
        DisclosureGroup("Additional Packages", isExpanded: .constant(true)) {
          ForEach(ViewDicts.additionalPackages.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.additionalPackages)
          }
        }
        
        DisclosureGroup("Labs", isExpanded: $expandLabs) {
          ForEach(ViewDicts.labs.keys.sorted(), id: \.self) { title in
            Link(title, viewDict: ViewDicts.labs)
          }
        }
      }
    }
    .navigationTitle("AudioKit Cookbook")
    .navigationBarTitleDisplayMode(.inline)
  }
}

extension ListView {
  func Link(_ title: String, viewDict: ViewDict) -> some View {
    NavigationLink(title, destination: viewDict[title])
  }
}

struct ViewDicts {
  private init() {}
  
  // MARK: - View Dictionaries
  
  static let additionalPackages: ViewDict = [
    "Controls": Lazy(V(ControlsView())),
    "Flow": Lazy(V(FlowView())),
    "Keyboard": Lazy(V(KeyboardView())),
  ]
  
  static let audioPlayers: ViewDict = [
    "Audio Player Completion Handler": Lazy(V(AudioPlayerCompletionHandlerView())),
    "MultiSegment Player": Lazy(V(MultiSegmentPlayerView())),
    "Playlist": Lazy(V(PlaylistView())),
  ]
  
  static let oscillators: ViewDict = [
    "Amplitude Envelope": Lazy(V(AmplitudeEnvelopeView())),
    "Dynamic Oscillator": Lazy(V(DynamicOscillatorView())),
    "FM Oscillator": Lazy(V(FMOscillatorView())),
    "Morphing Oscillator": Lazy(V(MorphingOscillatorView())),
    "Oscillator": Lazy(V(OscillatorView())),
    "Phase Distortion Oscillator": Lazy(V(PhaseDistortionOscillatorView())),
    "PWM Oscillator": Lazy(V(PWMOscillatorView())),
  ]
  
  static let reverbs: ViewDict = [
    "Apple Reverb": Lazy(V(ReverbView())),
    "Chowning Reverb": Lazy(V(ChowningReverbView())),
    "Comb Filter Reverb": Lazy(V(CombFilterReverbView())),
    "Costello Reverb": Lazy(V(CostelloReverbView())),
    "Flat Frequency Response Reverb": Lazy(V(FlatFrequencyResponseReverbView())),
    "Zita Reverb": Lazy(V(ZitaReverbView())),
  ]
  
  static let distortions: ViewDict = [
    "Apple Distortion": Lazy(V(AppleDistortionView())),
    "BitCrusher": Lazy(V(BitCrusherView())),
    "Clipper": Lazy(V(ClipperView())),
    "Decimator": Lazy(V(DecimatorView())),
    "Ring Modulator": Lazy(V(RingModulatorView())),
    "Tanh Distortion": Lazy(V(TanhDistortionView())),
  ]
  
  static let miniApps: ViewDict = [
    "Arpeggiator": Lazy(V(ArpeggiatorView())),
    "Audio 3D": Lazy(V(AudioKit3DView())),
    "Drums": Lazy(V(DrumsView())),
    "Drum Sequencer": Lazy(V(DrumSequencerView())),
    "Drum Synthesizers": Lazy(V(DrumSynthesizersView())),
    "Graphic Equalizer": Lazy(V(GraphicEqualizerView())),
    "Instrument EXS": Lazy(V(InstrumentEXSView())),
    "Instrument SFZ": Lazy(V(InstrumentSFZView())),
    "MIDI Monitor": Lazy(V(MIDIMonitorView())),
    "MIDI Track Demo View": Lazy(V(MIDITrackDemoView())),
    "Music Toy": Lazy(V(MusicToyView())),
    "Noise Generators": Lazy(V(NoiseGeneratorsView())),
    "Recorder": Lazy(V(RecorderView())),
    "Telephone": Lazy(V(TelephoneView())),
    "Tuner": Lazy(V(TunerView())),
    "VocalTract": Lazy(V(VocalTractView())),
  ]
  
  static let operations: ViewDict = [
    "Crossing Signal": Lazy(V(CrossingSignalView())),
    "Drone Operation": Lazy(V(DroneOperationView())),
    "Instrument Operation": Lazy(V(InstrumentOperationView())),
    "Phasor Operation": Lazy(V(PhasorOperationView())),
    "Pitch Shift Operation": Lazy(V(PitchShiftOperationView())),
    "Segment Operation": Lazy(V(SegmentOperationView())),
    "Smooth Delay Operation": Lazy(V(SmoothDelayOperationView())),
    "Stereo Delay Operation": Lazy(V(StereoDelayOperationView())),
    "Stereo Operation": Lazy(V(StereoOperationView())),
    "Variable Delay Operation": Lazy(V(VariableDelayOperationView())),
    "Vocal Tract Operation": Lazy(V(VocalTractOperationView())),
  ]
  
  static let physicalModels: ViewDict = [
    "Plucked String": Lazy(V(PluckedStringView())),
    "STK Ensemble": Lazy(V(STKEnsembleView())),
  ]
  
  static let effects: ViewDict = [
    "Auto Panner": Lazy(V(AutoPannerView())),
    "Auto Wah": Lazy(V(AutoWahView())),
    "Balancer": Lazy(V(BalancerView())),
    "Chorus": Lazy(V(ChorusView())),
    "Compressor": Lazy(V(CompressorView())),
    "Convolution": Lazy(V(ConvolutionView())),
    "Delay": Lazy(V(DelayView())),
    "Dynamic Range Compressor": Lazy(V(DynamicRangeCompressorView())),
    "Expander": Lazy(V(ExpanderView())),
    "Flanger": Lazy(V(FlangerView())),
    "Multi Tap Delay": Lazy(V(MultiTapDelayView())),
    "Panner": Lazy(V(PannerView())),
    "Peak Limiter": Lazy(V(PeakLimiterView())),
    "Phase Lock Vocoder": Lazy(V(PhaseLockedVocoderView())),
    "Phaser": Lazy(V(PhaserView())),
    "Pitch Shifter": Lazy(V(PitchShifterView())),
    "Playback Speed": Lazy(V(PlaybackSpeedView())),
    "Stereo Delay": Lazy(V(StereoDelayView())),
    "String Resonator": Lazy(V(StringResonatorView())),
    "Time Pitch": Lazy(V(TimePitchView())),
    "Transient Shaper": Lazy(V(TransientShaperView())),
    "Tremolo": Lazy(V(TremoloView())),
    "Variable Delay": Lazy(V(VariableDelayView())),
  ]
  
  static let labs: ViewDict = [
    "Gyro": Lazy(V(GyroShaderUIDemoView())),
  ]
}

#Preview {
  ContentView()
}
