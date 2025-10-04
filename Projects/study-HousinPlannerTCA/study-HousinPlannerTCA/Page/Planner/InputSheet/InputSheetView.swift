//
//  InputSheetView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/3/25.
//

import SwiftUI
import ComposableArchitecture

struct InputSheetView: View {
  @Bindable var store: StoreOf<InputSheetDomain>
  var mode: InputSheetMode = .userSetTotalCount
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        VStack(spacing: 20) {
          Text(mode.sheetTitle)
            .font(.headline)
          
          TextField(mode.placeholder, text: viewStore.binding(
            get: \.inputText,
            send: { .textChanged($0) }
          ))
          .keyboardType(mode.keyboardType)
          .textFieldStyle(.roundedBorder)
          .padding()
          
          HStack {
            Button("취소") {
              viewStore.send(.didTapCancel)
            }
            .buttonStyle(.bordered)
            
            Button("확인") {
              viewStore.send(.didTapConfirm)
            }
            .buttonStyle(.borderedProminent)
          }
        }
        .padding()
        .navigationTitle(mode.sheetTitle)
      }
    }
  }
}

#Preview {
  InputSheetView(
    store: Store(
      initialState: InputSheetDomain.State(),
      reducer: { InputSheetDomain() }
    )
  )
}
