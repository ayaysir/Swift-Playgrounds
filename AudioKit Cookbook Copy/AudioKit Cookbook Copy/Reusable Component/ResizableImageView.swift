//
//  ResizableImageView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/31/25.
//

import SwiftUI

struct ResizableImageView: View {
  let image: Image

  @State private var currentScale: CGFloat = 1.0
  @GestureState private var gestureScale: CGFloat = 1.0

  @State private var currentOffset: CGSize = .zero
  @GestureState private var gestureOffset: CGSize = .zero

  var body: some View {
    image
      .resizable()
      .scaledToFit()
      .scaleEffect(currentScale * gestureScale)
      .offset(x: currentOffset.width + gestureOffset.width,
              y: currentOffset.height + gestureOffset.height)
      .gesture(
        SimultaneousGesture(
          MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
              state = value
            }
            .onEnded { value in
              currentScale *= value
            },
          DragGesture()
            .updating($gestureOffset) { value, state, _ in
              state = value.translation
            }
            .onEnded { value in
              currentOffset.width += value.translation.width
              currentOffset.height += value.translation.height
            }
        )
      )
      .animation(.easeInOut(duration: 0.2), value: currentScale)
  }
}
