import SwiftUI
import ComposableArchitecture

struct InputSheetView: View {
  let store: StoreOf<InputSheetDomain>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        VStack(spacing: 20) {
          Text("총 숫자를 입력하세요")
            .font(.headline)
          
          TextField("숫자 입력", text: viewStore.binding(
            get: \.inputText,
            send: { .textChanged($0) }
          ))
          .keyboardType(.numberPad)
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
        .navigationTitle("총 숫자 설정")
      }
    }
  }
}