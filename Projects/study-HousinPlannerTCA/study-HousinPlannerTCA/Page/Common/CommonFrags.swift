//
//  CommonFrags.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/29/25.
//

import SwiftUI

struct CommonFrags {
  private init() {}
  internal static func StyledButtonLabel(
    _ verbatimText: String,
    backgroundColor: Color = .pink,
    foregroundColor: Color = .white,
    size: CGSize = .init(width: 10, height: 10)
  ) -> some View {
    Text(verbatim: verbatimText)
      .frame(width: size.width, height: size.height) // 순서 중요: .background 전에
      .padding(10) // 버튼 안쪽으로 보이는 패딩
      .background(backgroundColor)
      .foregroundColor(foregroundColor)
      .clipShape(.buttonBorder)
  }
}
