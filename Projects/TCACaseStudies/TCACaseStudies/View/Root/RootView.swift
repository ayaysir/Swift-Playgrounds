//
//  RootView.swift
//  TCACaseStudies
//
//  Created by 윤범태 on 2/4/26.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
  @Bindable var store: StoreOf<RootDomain>
  
  var body: some View {
    TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
      Tab("Alert", systemImage: "exclamationmark.triangle.fill", value: .alertExample) {
        AlertExampleView(store: store.scope(state: \.alertExample, action: \.alertExample))
      }
      
    }
  }
}

#Preview {
  RootView(
    store: Store(
      initialState: RootDomain.State(),
      reducer: { RootDomain() }
    )
  )
}
