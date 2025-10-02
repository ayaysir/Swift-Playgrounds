import ComposableArchitecture
import SwiftUI

@Reducer
struct InputSheetDomain {
  @ObservableState
  struct State: Equatable {
    var inputText: String = ""   // 사용자 입력 문자열
  }

  enum Action: Equatable {
    case textChanged(String)
    case didTapConfirm
    case didTapCancel
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .textChanged(text):
        state.inputText = text
        return .none
        
      case .didTapConfirm:
        // 확인 버튼 눌렀을 때 상위 도메인(PlannerDomain)에서 처리
        return .none
        
      case .didTapCancel:
        // 취소 버튼 눌렀을 때 단순 dismiss
        return .none
      }
    }
  }
}