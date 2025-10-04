//
//  DraftListView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/3/25.
//

import SwiftUI
import ComposableArchitecture

struct DraftListView: View {
  @Bindable var store: StoreOf<DraftListDomain>
  
  var body: some View {
    VStack {
      HStack {
        Text("Select a Draft")
          .font(.title2)
          .bold()
        
        Button(action: {
          store.send(.showInputSheet)
        }) {
          Label("New Draft", systemImage: "plus")
        }
        Spacer()
        Button(action: {
          // close
          store.send(.didTapClose)
        }) {
          Image(systemName: "xmark")
        }
      }
      
      List {
        // Text("\(store.draftList.count)")
        ForEach(store.draftList) { draftObj in
          Button {
            // 상위 PlannerDomain의 case .selectDraft(let id):를 실행
            store.send(.didSelectDraft(draftObj.id))
          } label: {
            HStack {
              if store.selectedDraftID == draftObj.id {
                Image(systemName: "checkmark")
              }
              Text("\(draftObj.name)")
              Spacer()
              Text("\(draftObj.createdAt.ymdhm)")
                .foregroundStyle(.gray)
                .font(.caption)
            }
          }
          .swipeActions {
            if store.selectedDraftID != draftObj.id {
              Button(role: .cancel) {
                store.send(.showRemoveAlert(draftObj.id))
              } label: {
                Label("Delete", systemImage: "trash")
                  .tint(Color.red)
              }
            }
          }
        }
      }
      .listStyle(.plain)
    }
    .padding()
    .alert(
      store: store.scope(
        state: \.$removeAlert,
        action: \.removeAlertAct
      )
    )
    .sheet(
      store: store.scope(
        state: \.$inputSheetSt,
        action: \.inputSheetAct
      )
    ) { store in
      InputSheetView(
        store: store,
        mode: .newDraftName
      )
    }
  }
}

#Preview {
  NavigationStack {
    DraftListView(
      store: .init(
        initialState: DraftListDomain.State(selectedDraftID: UUID()),
        reducer: { DraftListDomain() }
      )
    )
  }
}
