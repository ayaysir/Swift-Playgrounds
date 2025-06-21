//
//  Table.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/21/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

class TablesConductor: ObservableObject {
  let square,
      triangle,
      sine,
      sineHarmonic,
      custom: AudioKit.Table
  
  @Published var fileTable: AudioKit.Table? = nil
  
  init() {
    // count: Size of the table (multiple of 2)
    square = .init(.square, count: 128)
    triangle = .init(.triangle, count: 128)
    sine = .init(.sine, count: 256)
    
    // sineHarmonic
    let harmonicOvertoneAmplitudes: [Float] = [
      0.0, 0.0, 0.016, 0.301
    ]
    // phase: 위상 오프셋으로, 시작 지점을 오른쪽으로 75%만큼 이동
    sineHarmonic = .init(.harmonic(harmonicOvertoneAmplitudes), phase: 0.75)
    
    // Custom
    custom = Table(.sine, count: 256)
    for i in custom.indices {
      custom[i] += Float.random(in: -0.5...0.5) + Float(i) / 2048.0
    }
    
    // init()은 비동기 함수가 될 수 없기 때문에 await를 직접 쓸 수 없습니다. 하지만 초기화 중에 비동기 작업(예: 오디오 파일 로드)을 시작하고 싶을 경우에는:
    Task { @MainActor in
      await loadFileTable()
    }
  }
  
  @MainActor
  func loadFileTable() async {
    /*
     오디오 파일 비동기 로드
     - 사운드파일(fileTable)을 init()에서 즉시 try!로 로드하던 방식을 제거
     - 대신 Task { ... }로 파일을 비동기 로드 → UI 초기화 지연 방지
     */
    do {
      let url = GlobalSource.piano.url!
      let file = try AVAudioFile(forReading: url)
      fileTable = Table(file: file)
    } catch {
      print("Failed to load fileTable: \(error)")
    }
  }
}

struct TablesDataView: UIViewRepresentable {
  typealias UIViewType = TableView
  var table: AudioKit.Table
  
  func makeUIView(context: Context) -> TableView {
    let view = TableView(table)
    view.backgroundColor = .black
    return view
  }
  
  func updateUIView(_ uiView: TableView, context: Context) {}
}

struct TableRecipeView: View {
  @StateObject private var conductor = TablesConductor()
  
  var body: some View {
    VStack {
      Text("Square")
      TablesDataView(table: conductor.square)
      Text("Triangle")
      TablesDataView(table: conductor.triangle)
      Text("Sine")
      TablesDataView(table: conductor.sine)
      Text("Sine Harmonic")
      TablesDataView(table: conductor.sineHarmonic)
      Text("File")
      if let fileTable = conductor.fileTable {
        TablesDataView(table: fileTable)
      } else {
        Rectangle()
          .overlay(Text("Loading file data...").foregroundStyle(.red))
      }
      Text("Custom Data")
      TablesDataView(table: conductor.custom)
    }
    .padding()
    .navigationTitle("Tables")
    // .task {
    //   await conductor.loadFileTable()
    // }
  }
}

#Preview {
  TableRecipeView()
}
