//
//  DraftListDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/4/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DraftListDomain {
  @ObservableState
  struct State: Equatable {
    var draftList: [DraftObject] = []
    @Presents var inputSheetSt: InputSheetDomain.State?
  }
  
  enum Action {
    case fetchDraftList
    case didTapClose
    case createNewDraft
    case didSelectDraft(UUID)
    
    case inputSheetAct(PresentationAction<InputSheetDomain.Action>)
    case showInputSheet
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchDraftList:
        let fetched = RealmService.shared.fetchAllDraftObjects()
        state.draftList = fetched
        return .none
        
      case .createNewDraft:
        // RealmService.shared.createDraftObject(name: "")
        return .none
        
      case .didTapClose:
        // 상위 도메인이 처리
        return .none
        
      case .didSelectDraft:
        return .none
        
      // MARK: - InputSheetAction 구현
      
      case .showInputSheet:
        state.inputSheetSt = InputSheetDomain.State()
        return .none
        
      case .inputSheetAct(.presented(.didTapCancel)):
        state.inputSheetSt = nil
        return .none
        
      case .inputSheetAct(.presented(.didTapConfirm)):
        if let inputSheetSt = state.inputSheetSt {
          let name = inputSheetSt.inputText.isEmpty ? "Draft \(Date.now)" : inputSheetSt.inputText
          _ = RealmService.shared.createDraftObject(name: name)
          state.inputSheetSt = nil
            
          return .send(.fetchDraftList)
        }
        
        state.inputSheetSt = nil
        return .none
        
      case .inputSheetAct:
        return .none
      }
    }
    .ifLet(\.$inputSheetSt, action: \.inputSheetAct) {
      InputSheetDomain()
    }
  }
}
