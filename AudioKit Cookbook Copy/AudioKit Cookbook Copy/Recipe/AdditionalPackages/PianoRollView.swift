//
//  PianoRollView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/20/25.
//

import PianoRoll
import SwiftUI

struct PianoRollView: View {
  @State var model = PianoRollModel(
    notes: [
      PianoRollNote(start: 1, length: 2, pitch: 3),
      PianoRollNote(start: 5, length: 1, pitch: 4),
    ],
    // 그리드의 개수?
    length: 128, // Duration in steps
    height: 48 // The number of pitches representable
  )
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Tap inside of the scrolling grid to set a note.")
      ScrollView([.horizontal, .vertical], showsIndicators: true) {
        PianoRoll(
          model: $model,
          noteColor: .teal,
          noteLineOpacity: 0.5,
          gridColor: .primary,
          // Size of a grid cell
          gridSize: CGSize(width: 100, height: 10),
          layout: .horizontal
        )
      }
    }
    .foregroundStyle(.primary)
    .navigationTitle("Piano Roll Demo")
  }
}

#Preview {
  PianoRollView()
}
