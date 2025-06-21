//
//  BaseTapDemo.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/21/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Speech
import SwiftUI

class SpeechRecognitionTap: BaseTap {
  var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  var analyzer: SFSpeechRecognizer?
  var reconitionTask: SFSpeechRecognitionTask?
  
  func setupRecognition(locale: Locale) {
    analyzer = SFSpeechRecognizer(locale: locale)
    print("Locale: \(locale)")
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    guard let recognitionRequest else {
      fatalError("Unable to create recognition request")
    }
    
    recognitionRequest.shouldReportPartialResults = true
  }
  
  func stopRecognition() {
    recognitionRequest = nil
    reconitionTask = nil
    analyzer = nil
  }
  
  override func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
    if let recognitionRequest {
      recognitionRequest.append(buffer)
    }
  }
}

class BaseTapForSpeechRecognitionConductor: ObservableObject,HasAudioEngine {
  @Published var textString = ""
  let engine = AudioEngine()
  var srTap: SpeechRecognitionTap
  let mic: AudioEngine.InputNode?
  var outputMixer: Mixer
  var silencer: Fader
  
  private var recognitionTask: SFSpeechRecognitionTask?
  
  enum LanguageCode: String {
    case ko = "ko-KR"
    case en = "en-US"
    case ja = "ja-JP"
  }
  
  @Published var languageCode: LanguageCode = .en {
    didSet {
      setLanguage(code: languageCode.rawValue)
    }
  }
  
  init() {
    mic = engine.input
    
    guard let mic else {
      fatalError("Microphone not available")
    }
    
    outputMixer = Mixer(mic)
    srTap = SpeechRecognitionTap(
      mic,
      bufferSize: 4096,
      callbackQueue: .main
    )
    silencer = Fader(outputMixer, gain: 0)
    engine.output = silencer
    
    do {
      try engine.start()
    } catch {
      print(error)
    }
    
    srTap.start()
    // srTap.setupRecognition()
    setLanguage(code: languageCode.rawValue)
  }
  
  func setLanguage(code: String) {
    srTap.stopRecognition()
    srTap.stop()
    engine.stop()
    try? engine.start()
    srTap.start()
    
    srTap.setupRecognition(locale: Locale(identifier: code))
    
    textString = "Languaged changed: \(code)"
    
    guard let recognitionRequest = srTap.recognitionRequest else {
      fatalError("Recognition request not available")
    }
    
    if let analyzer = srTap.analyzer {
      recognitionTask = analyzer.recognitionTask(with: recognitionRequest) { result, err in
        // var isFinal = false
        if let result {
          // A Boolean value that indicates whether speech recognition is complete and whether the transcriptions are final.
          // isFinal = result.isFinal
          DispatchQueue.main.async {
            self.textString = result.bestTranscription.formattedString
          }
        }
        
        // if err != nil || isFinal {
        //   // self.engine.stop()
        //   self.srTap.stopRecognition()
        //   self.srTap.stop()
        //   
        // }
      }
    }
  }
}

struct BaseTapForSpeechRecognitionView: View {
  @StateObject private var conductor = BaseTapForSpeechRecognitionConductor()
  
  var body: some View {
    VStack {
      HStack {
        Text("Start talking in:")
          .font(.title2)
          .bold()
        Picker("Language", selection: $conductor.languageCode) {
          Text("English")
            .tag(BaseTapForSpeechRecognitionConductor.LanguageCode.en)
          Text("Korean")
            .tag(BaseTapForSpeechRecognitionConductor.LanguageCode.ko)
          Text("Japanese")
            .tag(BaseTapForSpeechRecognitionConductor.LanguageCode.ja)
        }
      }
      ScrollViewReader { proxy in
        ScrollView {
          Text(conductor.textString)
            .font(.system(size: 12))
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
            .id("bottom")
        }
        .frame(maxHeight: .infinity) // 가능한 공간 모두 차지
        .onChange(of: conductor.textString) {
          withAnimation {
            proxy.scrollTo("bottom", anchor: .bottom)
          }
        }
      }
      FFTView(conductor.outputMixer)
        .frame(height: 200)
    }
    .navigationTitle("Base Tap for Speech Recognition")
    .padding()
    .onDisappear {
      conductor.mic?.stop()
      conductor.outputMixer.stop()
      conductor.silencer.stop()
      conductor.srTap.stop()
      conductor.stop()
    }
  }
}

#Preview {
  BaseTapForSpeechRecognitionView()
}
