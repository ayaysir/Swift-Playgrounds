//
//  CartCell.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//


import SwiftUI
import ComposableArchitecture

struct CartCell: View {
  let store: StoreOf<CartItemDomain>
  
  var body: some View {
    WithPerceptionTracking {
      VStack {
        Text("CartCell")
      }
    }
  }
}

#Preview(traits: .fixedLayout(width: 300, height: 300)) {
  let store = Store(
    initialState: CartItemDomain.State(
      id: UUID(),
      cartItem: CartItem.sample.first!
    ),
    reducer: { CartItemDomain() }
  )
  CartCell(store: store)
}
