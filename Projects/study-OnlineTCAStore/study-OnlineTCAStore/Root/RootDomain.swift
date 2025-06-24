//
//  RootDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootDomain {
  @ObservableState
  struct State: Equatable {
    var selectedTab = Tab.products
    var productListState = ProductListDomain.State()
    var profileState = ProfileDomain.State()
  }
  
  enum Tab {
    case products
    case profile
  }
  
  enum Action: Equatable {
    case tabSelected(Tab)
    case productList(ProductListDomain.Action)
    case profile(ProfileDomain.Action)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .productList:
        return .none
      case .tabSelected(let tab): // 탭을 선택하면
        state.selectedTab = tab // 상태의 selectedTab을 해당 탭으로 할당
        return .none // 반환되는 effect 없음
      case .profile:
        return .none
      }
    }
    
    /*
     - Scope(state:action:)는 상위 도메인에서 하위 도메인을 연결할 때 사용하는 DSL
     - **도메인 분리(domain composition)**와 관련
     
     * state: \.productListState
       => RootDomain.State에서 **하위 상태**를 꺼내는 경로 (KeyPath)
       => var productListState = ProductListDomain.State()를 호출
     
     * action: \.productList
       => RootDomain.Action에서 **하위 액션**을 꺼내는 경로 (CasePath)
       => case productList(ProductListDomain.Action) 를 호출
     
     => “RootDomain에서 productListState라는 하위 상태와 productList(액션)이라는 하위 액션을
     ProductListDomain이라는 하위 리듀서와 연결하라”는 뜻입니다.
     
     => 상위 상태의 일부를 하위 상태로 전달, 상위 액션의 일부를 하위 액션으로 분기
     => 하위 리듀서(ProductListDomain)가 해당 액션을 처리,
     => 하위 리듀서가 상태를 변경하면, 상위 상태 내의 부분 상태가 자동으로 갱신
     
     •  하위 도메인에 productListState와 productList 액션만 전달됨
     •  하위 도메인은 그 안에서 독립적으로 상태를 변경
     •  상위 도메인의 나머지 상태나 액션은 알 필요 없음
     */
    Scope(state: \.productListState, action: \.productList) {
      ProductListDomain() // @Reducer ProductListDomain 구조체 인스턴스 생성
    }
    
    Scope(state:  \.profileState, action: \.profile) {
      ProfileDomain()
    }
  }
}
