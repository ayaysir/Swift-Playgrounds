//
//  PlusMinusButton.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//

import SwiftUI
import ComposableArchitecture

struct PlusMinusButton: View {
  let store: StoreOf<AddToCartDomain>
  
  var body: some View {
    WithPerceptionTracking {
      HStack {
        Button {
          store.send(.didTapMinusButton)
        } label: {
          CommonViews.StyledButtonLabel("-")
        }
        
        // Int를 스트링화 하기 위해 .description 붙임
        Text(store.count.description)
          .padding(5)
        
        Button {
          store.send(.didTapPlusButton)
        } label: {
          CommonViews.StyledButtonLabel("+")
        }
      }
      .buttonStyle(.plain) // 이거 없으면 List로 감싸져 있을때 버튼 한번만 클릭하면 그 후로는 인식안됨
      // https://www.hackingwithswift.com/forums/swiftui/buttons-not-working-inside-list-view/15096
    }
  }
  
  /*
   **“카운트가 0 밑으로 내려가지 않도록 막는 로직”**은
   ➡ 반드시 AddToCartDomain에 만들어야 합니다.
   
   ✅ 이유: TCA에서는 “상태 변경 로직은 도메인(Reducer)에 있어야 한다”
   
   View (PlusMinusButton)
   - 버튼 UI와 사용자 인터랙션을 보여줌
   Domain (AddToCartDomain)
   - 상태(count)를 변경하는 권한을 가짐
   
   ✅ 결론

   ✔️ “count는 0 미만이 되면 안 된다”는 규칙은 비즈니스 로직이므로
   AddToCartDomain의 리듀서에서 조건 검사를 통해 처리하는 것이 맞습니다.

   View는 오직 “버튼을 누르면 액션을 보낸다”까지만 책임져야 합니다.

   */
}
#Preview {
  let store = Store(
    initialState: AddToCartDomain.State(),
    reducer: { AddToCartDomain() }
  )
  List {
    PlusMinusButton(store: store)
  }
}
