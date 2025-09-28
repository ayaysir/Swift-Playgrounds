//
//  PlusMinusButton.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/29/25.
//

import SwiftUI
import ComposableArchitecture

struct PlusMinusButton: View {
  let store: StoreOf<AdjustLevelDomain>
  
  var body: some View {
    HStack {
      Button(action: { store.send(.didTapMinusButton) }) {
        CommonFrags.StyledButtonLabel(
          "-",
          backgroundColor: .gray.opacity(0.5),
          foregroundColor: .primary,
          size: .init(width: 5, height: 5)
        )
      }
      
      Text(store.level.description)
        .font(.system(size: 14))
        .frame(width: 16)
        // .padding(5)
      
      Button(action: { store.send(.didTapPlusButton) }) {
        CommonFrags.StyledButtonLabel(
          "+",
          size: .init(width: 5, height: 5)
        )
      }
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  PlusMinusButton(
    store: .init(
      initialState: AdjustLevelDomain.State(),
      reducer: { AdjustLevelDomain() }
    )
  )
}
