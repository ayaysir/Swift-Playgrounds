//
//  VocalTract.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/14/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Combine
import SoundpipeAudioKit
import SwiftUI
import Controls

class VocalTractConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  
  @Published var isPlaying: Bool = false {
    didSet {
      isPlaying ? voc.start() : voc.stop()
    }
  }
  
  /**
   SoundAudioPipeKit에 있음. Neil Thapen의 Pink Trombone 알고리즘을 기반으로,
   이 코드는 성도(聲道, vocal tract)의 성문 펄스 파형(glottal pulse wave)에 대한 물리적 모델을 구현합니다.
   
   성도 모델은 고전적인 **Kelly-Lochbaum 분절 원통형 1차원 웨이브가이드 모델(segmented cylindrical 1d waveguide model)**을 기반으로 하며,
   성문 펄스 파형은 **LF 성문 펄스 모델(LF glottal pulse model)**입니다.
   
   - ✅ **성도 (Vocal Tract, 聲道)**
   - 정의: 인간의 발성 기관 중, 성문부터 입술까지의 공기 통로를 의미합니다.
   - 구성: 인두(pharynx), 구강(oral cavity), 비강(nasal cavity) 등 포함.
   - 역할: 이 통로의 형태와 크기를 조절함으로써 소리의 공명을 변화시켜 다양한 **말소리(모음, 자음)**를 만들어냅니다.
   - 예: 입을 크게 벌리거나 혀 위치를 바꾸면 음색이 달라지는 이유.
   - ✅ **성문 펄스 파형 (Glottal Pulse Wave)***
   - 정의: **성대(glottis)**가 주기적으로 열리고 닫히며 발생시키는 기초적인 소리 파형입니다.
   - 역할: 이 파형이 바로 음성의 원천적인 진동이며, 이후 성도에서 공명을 거쳐 실제 말소리로 바뀝니다.
   - 예시: 남자의 저음 목소리는 느린 주기로 성대가 열리고 닫히면서 낮은 주파수의 성문 펄스가 발생하는 것.
   */
  @Published var voc = VocalTract()
  
  init() {
    engine.output = voc
  }
}

struct VocalTractView: View {
  @StateObject var conductor = VocalTractConductor()
  @State private var refreshID = UUID()
  
  var body: some View {
    VStack {
      Button(conductor.isPlaying ? "STOP" : "START") {
        conductor.isPlaying.toggle()
      }
      .frame(height: 50)
      
      ZStack {
        Button("Randomize") {
          // glottal frequency: 성문 주파수
          conductor.voc.frequency = AUValue.random(in: 1...2000)
          // 혀 위치
          conductor.voc.tonguePosition = AUValue.random(in: 0...1)
          // 혀 직경
          conductor.voc.tongueDiameter = AUValue.random(in: 0...1)
          // vocal tenseness: 음성 긴장
          conductor.voc.tenseness = AUValue.random(in: 0...1)
          // 비음
          conductor.voc.nasality = AUValue.random(in: 0...1)
          // conductor.voc.parameters.forEach { param in
          //   print(param.def.name, param.value)
          // }
          
          /*
           Binding 지원 안하는 뷰의 강제 리프레시
           1. 뷰에 .id(UUID)를 추가
           2. 데이터가 바뀔 때마다 refreshID = UUID()를 실행하여 강제 리프레시
           */
          refreshID = .init()
        }
        // .disabled(!conductor.isPlaying)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray)
        .foregroundStyle(.black)
        .clipShape(.buttonBorder)
      }
      .padding()
      
      HStack {
        ForEach(conductor.voc.parameters) {
          ParameterRow(param: $0)
        }
      }
      .frame(height: 150)
      .padding(.horizontal, 20)
      .id(refreshID)
      
      NodeOutputView(conductor.voc)
        .frame(height: 200)
    }
    .navigationTitle("Vocal Tract (성도)")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  VocalTractView()
}
