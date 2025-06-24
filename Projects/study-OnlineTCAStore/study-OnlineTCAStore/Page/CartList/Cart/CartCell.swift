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
        HStack {
          let url = URL(string: store.cartItem.product.imageString)!
          AsyncImage(url: url) { imageView in
            imageView
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 100, height: 100)
          } placeholder: {
            ProgressView()
              .frame(width: 100, height: 100)
          }
          Spacer()
          VStack(alignment: .leading) {
            Text(store.cartItem.product.title)
              .font(.title2)
              .fontWeight(.semibold)
              .lineLimit(3)
              .minimumScaleFactor(0.5)
            Text("$\(store.cartItem.product.price.description)")
              .fontWeight(.medium)
          }
        }
        HStack {
          Group {
            Text("Quantity: ")
            +
            Text(store.cartItem.quantity.description)
              .bold()
          }
          .font(.system(size: 25))
          Spacer()
          Button {
            store.send(.deleteCartItem(product: store.cartItem.product))
          } label: {
            Image(systemName: "trash.fill")
              .foregroundStyle(.red)
              .padding()
          }
          .buttonStyle(.plain)
        }
      }
      .padding([.bottom, .top], 10)
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
  List {
    CartCell(store: store)
  }
}
