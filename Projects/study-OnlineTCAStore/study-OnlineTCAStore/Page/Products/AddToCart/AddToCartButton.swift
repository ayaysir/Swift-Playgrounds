//
//  AddToCartButton.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//

import SwiftUI
import ComposableArchitecture

struct AddToCartButton: View {
  let store: StoreOf<AddToCartDomain>
  
  var body: some View {
    WithPerceptionTracking {
      if store.count > 0 {
        PlusMinusButton(store: store)
      } else {
        Button {
          store.send(.didTapPlusButton)
        } label: {
          CommonViews.StyledButtonLabel("Add To Cart")
        }
        .buttonStyle(.plain) // 이거 없으면 List로 감싸져 있을때 버튼 한번만 클릭하면 그 후로는 인식안됨
      }
    }
  }
}

#Preview {
  let store = Store(
    initialState: AddToCartDomain.State(),
    reducer: { AddToCartDomain() }
  )
  AddToCartButton(store: store)
}
