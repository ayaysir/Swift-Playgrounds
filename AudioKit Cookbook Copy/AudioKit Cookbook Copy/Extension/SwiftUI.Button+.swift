//
//  SwiftUI.Button+.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/15/25.
//

import SwiftUI

enum TagButtonStyle {
  case prominent
  case bordered
}

extension Button {
  @ViewBuilder
  func tagStyle(_ style: TagButtonStyle) -> some View {
    switch style {
    case .prominent:
      self.buttonStyle(BorderedProminentButtonStyle())
    case .bordered:
      self.buttonStyle(BorderedButtonStyle())
    }
  }
}
