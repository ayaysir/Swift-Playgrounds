//
//  ProductCell.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//


import SwiftUI
import ComposableArchitecture

struct ProductCell: View {
  let store: StoreOf<ProductDomain>
  
  var body: some View {
    WithPerceptionTracking {
      let imageURL = URL(string: store.product.imageString)
      VStack {
        AsyncImage(url: imageURL) { imageView in
          imageView
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 300)
        } placeholder: {
          ProgressView()
            .frame(height: 300)
        }
        
        VStack(alignment: .leading) {
          Text(store.product.title)
            .font(.headline)
          Text(store.product.description)
            .font(.caption)
          Divider()
          HStack {
            Text("$\(store.product.price.description)")
              .font(.system(size: 25, weight: .medium))
            Spacer()
            AddToCartButton(
              store: store.scope(
                state: \.addToCartState,
                action: \.addToCart
              )
            )
          }
        }
      }
      .padding(20)
    }
  }
}

#Preview(traits: .fixedLayout(width: 300, height: 300)) {
  List {
    ProductCell(
      store: Store(
        initialState: ProductDomain.State(
          id: UUID(),
          product: Product.sample[0]
        ),
        reducer: { ProductDomain() }
      )
    )
  }
}

/*
 레이아웃
 매크로 표기
 자동 크기 조절
 .sizeThatFitsLayout
 고정 크기
 .fixedLayout(width: 300, height: 500)
 다크 모드
 .darkMode
 다국어
 .locale(.init(identifier: "ko"))
 기기 시뮬레이션
 .device("iPhone SE (3rd generation)")

 복수 적용도 가능합니다:
 #Preview(traits: [.fixedLayout(width: 300, height: 300), .darkMode]) {
   MyView()
 }
 */
