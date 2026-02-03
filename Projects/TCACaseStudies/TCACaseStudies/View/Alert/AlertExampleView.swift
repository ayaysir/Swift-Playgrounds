//
//  AlertExampleView.swift
//  TCACaseStudies
//
//  Created by 윤범태 on 2/3/26.
//

import SwiftUI
import ComposableArchitecture

struct AlertExampleView: View {
  @Bindable var store: StoreOf<AlertExampleDomain>
  
  var body: some View {
    VStack {
      Button(action: {
        store.send(.alertButtonTapped)
      }) {
        Label("얼럿창 띄우기", systemImage: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
      }
    }
    .padding()
    .alert(store: store.scope(state: \.$alert, action: \.alert))
  }
}

#Preview {
  AlertExampleView(
    store: Store(
      initialState: AlertExampleDomain.State(),
      reducer: {
        AlertExampleDomain()
      })
  )
}
