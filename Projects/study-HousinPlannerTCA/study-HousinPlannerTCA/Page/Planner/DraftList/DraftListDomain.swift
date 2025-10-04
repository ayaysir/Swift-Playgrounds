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
    var selectedDraftID: UUID
    var draftList: [DraftObject] = []
    @Presents var inputSheetSt: InputSheetDomain.State?
    @Presents var removeAlert: AlertState<Action.RemoveAlert>?
  }
  
  enum Action {
    case fetchDraftList
    case didTapClose
    case createNewDraft
    case didSelectDraft(UUID)
    case showRemoveAlert(UUID)
    case requestRemoveDraft(UUID)
    
    case inputSheetAct(PresentationAction<InputSheetDomain.Action>)
    case showInputSheet
    
    case removeAlertAct(PresentationAction<RemoveAlert>)
    
    @CasePathable
    enum RemoveAlert: Equatable {
      case didCancel
      case didRemove(UUID)
    }
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchDraftList:
        state.draftList = []
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
        
      case .showRemoveAlert(let draftID):
        state.removeAlert = .confirmationAlert(draftID: draftID)
        return .none
        
      case .requestRemoveDraft:
        return .none
        
      case .removeAlertAct(.presented(let alertAction)):
        return switchAlertAction(state: &state, alertAction: alertAction)
        
      case .removeAlertAct:
        return .none
      }
    }
    .ifLet(\.$inputSheetSt, action: \.inputSheetAct) {
      InputSheetDomain()
    }
  }
  
  private func switchAlertAction(
    state: inout Self.State,
    alertAction: Action.RemoveAlert
  ) -> Effect<Action> {
    switch alertAction {
    case .didCancel:
      state.removeAlert = nil
      return .none
    case .didRemove(let draftID):
      state.removeAlert = nil
      // print("Remove:", draftID)
      return .send(.requestRemoveDraft(draftID))
    }
  }
}

// `Action` 타입이 `CartListDomain.Action.Alert`인 경우
extension AlertState where Action == DraftListDomain.Action.RemoveAlert {
  static func confirmationAlert(draftID: UUID) -> AlertState {
    AlertState {
      TextState("Confirm your remove request")
    } actions: {
      ButtonState(action: .didRemove(draftID)) {
        TextState("Remove")
      }
      ButtonState(role: .cancel, action: .didCancel) {
        TextState("Cancel")
      }
    } message: {
      TextState("Do you want to remove \(draftID)?")
    }
  }
}
