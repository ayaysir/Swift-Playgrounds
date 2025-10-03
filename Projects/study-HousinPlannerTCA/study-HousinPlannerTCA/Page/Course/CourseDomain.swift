//
//  CourseDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CourseDomain {
  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID
    let course: Course
    var adjustLevelState = AdjustLevelDomain.State()
    var effectValueText: String = ""
    var requireSheetsPointText: String = "---"
    
    @Presents var detailSheetState: DetailSheetDomain.State?
  }
  
  enum Action {
    case adjustLevel(AdjustLevelDomain.Action)
    case refreshLevelPointStatus
    case setDetailSheetView(isPresented: Bool)
    // 프레젠테이션 액션(PresentationAction) 은 시트, 네비게이션, 팝오버 같은 “뷰의 열림/닫힘” 상태를 옵셔널 상태와 액션으로 안전하게 연결하기 위한 특별한 액션 타입
    case detailSheetAct(PresentationAction<DetailSheetDomain.Action>)
    case resetAdjustLevel
    case requestUpdateLevel
    case requestFetchLevel
  }
  
  var body: some ReducerOf<Self> {
    // RootAction.addToCart(하위 액션) 구조를 자동으로 추론하여, 하위 도메인 액션을 연결
    Scope(state: \.adjustLevelState, action: \.adjustLevel) {
      AdjustLevelDomain()
    }
    
    Reduce { state, action in
      let maxLevel = state.course.effects.count
      
      switch action {
      case .adjustLevel(.didTapPlusButton):
        state.adjustLevelState.level = min(state.adjustLevelState.level, maxLevel)
        fallthrough

      case .adjustLevel(.didTapMinusButton):
        state.adjustLevelState.level = max(state.adjustLevelState.level, 0)
        fallthrough
        
      case .adjustLevel:
        updateEffectValueText(state: &state)
        return .send(.requestUpdateLevel)
        
      case .refreshLevelPointStatus:
        // update Text
        updateEffectValueText(state: &state)
        
        // DB update
        return .none
        
      case .setDetailSheetView(let isPresented):
        state.detailSheetState = if isPresented {
          // 여기서 state.adjustLevelState를 전송
          DetailSheetDomain.State(course: state.course, adjustLevelState: state.adjustLevelState)
        } else {
          nil
        }
        return .none
        
      case .detailSheetAct(.presented(.dismiss)):
        state.detailSheetState = nil
        return .none
        
      case .detailSheetAct(.dismiss):
        state.detailSheetState = nil
        return .none
        
      case .detailSheetAct:
        return .none
        
      case .resetAdjustLevel:
        state.adjustLevelState.level = 0
        return .none
        
      case .requestUpdateLevel:
        return .none
        
      case .requestFetchLevel:
        return .none
      }
    }
  }
  
  private func updateEffectValueText(state: inout Self.State) {
    let currentDesc = state.course.descJa
    if let currentEffect = state.course.effects.first(where: { state.adjustLevelState.level == $0.level }) {
      state.effectValueText = currentDesc.replacingOccurrences(of: "xx", with: currentEffect.valueEffect.description)
      state.requireSheetsPointText = "\(currentEffect.pointCumulative)"
    } else {
      state.effectValueText = currentDesc.replacingOccurrences(of: "xx", with: "0")
      state.requireSheetsPointText = "---"
    }
  }
}
