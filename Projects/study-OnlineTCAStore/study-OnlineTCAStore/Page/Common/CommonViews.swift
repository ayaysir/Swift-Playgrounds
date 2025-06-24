//
//  CommonViews.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//

import SwiftUI

struct CommonViews {
  private init() {}
  internal static func StyledButtonLabel(_ verbatimText: String) -> some View {
    Text(verbatim: verbatimText)
      .padding(10)
      .background(.teal)
      .foregroundColor(.white)
      .clipShape(.buttonBorder)
  }
}
