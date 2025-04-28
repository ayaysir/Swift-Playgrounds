//
//  SplashView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/28/25.
//

import SwiftUI

struct SplashView: View {
  @State private var isContentReady = false
  
  var body: some View {
    ZStack {
      if isContentReady {
        ContentView()
      } else {
        VStack(spacing: 0) {
#if os(macOS)
          let baseWidth = NSApp.mainWindow?.contentView?.bounds.width ?? 320
          let baseHeight = NSApp.mainWindow?.contentView?.bounds.width ?? 320
          let iconWidth: CGFloat = baseWidth * 0.8
          let iconHeight: CGFloat = baseHeight * 0.8
#else
          let iconWidth: CGFloat = 256
          let iconHeight: CGFloat = 256
#endif
          Image(.audiokitIcon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: iconWidth, height: iconHeight)
          Image(.audiokitLogo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 217, height: 120)
        }
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        withAnimation(.easeInOut(duration: 1.0)) {
          isContentReady.toggle()
        }
      }
    }
  }
}

#Preview {
  SplashView()
}
