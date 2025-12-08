//
//  SwiftUI.View+.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 12/7/25.
//

import SwiftUI

extension View {
  func responsiveLayout<Portrait: View, Landscape: View>(
    @ViewBuilder portrait: () -> Portrait,
    @ViewBuilder landscape: () -> Landscape
  ) -> some View {
    let portraitView = portrait()
    let landscapeView = landscape()

    return GeometryReader { geo in
      let isLandscape = geo.size.width > geo.size.height

      Group {
        if isLandscape {
          landscapeView
        } else {
          portraitView
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
