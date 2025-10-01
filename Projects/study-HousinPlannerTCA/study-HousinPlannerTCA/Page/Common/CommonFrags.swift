//
//  CommonFrags.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/29/25.
//

import SwiftUI

struct CommonFrags {
  private init() {}
  
  static func StyledButtonLabel(
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
  
  @ViewBuilder static func RoundedLabel(
    _ text: String,
    backgroundColor: Color = .gray,
    foregroundColor: Color = .white,
    horizontalPadding: CGFloat = 10,
    verticalPadding: CGFloat = 1
  ) -> some View {
    Text(verbatim: text)
      .padding(.horizontal, horizontalPadding)
      .padding(.vertical, verticalPadding)
      .background(backgroundColor)
      .foregroundStyle(foregroundColor)
      .bold()
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
  
  @ViewBuilder static func RoundedButton(
    _ verbatimText: String,
    action: (() -> Void)? = nil
  ) -> some View {
    Button(action: { action?() }) {
      Text(verbatim: verbatimText)
        .font(.system(size: 13))
        .padding(.horizontal, 10)
        .padding(.vertical, 2.5)
        .background(.gray.opacity(0.3))
        .clipShape(.buttonBorder)
    }
    .buttonStyle(.plain)
  }

}
