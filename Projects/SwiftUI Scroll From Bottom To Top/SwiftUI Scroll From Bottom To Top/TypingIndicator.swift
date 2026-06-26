//
//  TypingIndicator.swift
//  SwiftUI Scroll From Bottom To Top
//
//  Created by 윤범태 on 5/30/26.
//

import SwiftUI

struct TypingIndicator: View {
  @State private var phase: Int = 0
  let dots = 3
  
  var body: some View {
    HStack(spacing: 6) {
      ForEach(0..<dots, id: \.self) { i in
        Circle()
          .fill(Color.secondary)
          .frame(width: 8, height: 8)
          .opacity(phase == i ? 1 : 0.3)
          .animation(.easeInOut(duration: 0.35).repeatForever().delay(Double(i) * 0.12), value: phase)
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .onAppear {
      // 무한 순환
      Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { _ in
        phase = (phase + 1) % dots
      }
    }
  }
}
