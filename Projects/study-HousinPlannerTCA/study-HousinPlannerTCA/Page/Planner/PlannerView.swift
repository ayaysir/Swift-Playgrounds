//
//  PlannerView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/30/25.
//

import SwiftUI
import ComposableArchitecture

struct PlannerView: View {
  @Bindable var store: StoreOf<PlannerDomain>
  
  var body: some View {
    VStack {
      AreaCategorySegments
      AreaCourses
    }
    .task {
      store.send(.fetchCourses)
    }
  }
}

extension PlannerView {
  @ViewBuilder private var AreaCategorySegments: some View {
    Picker("Select a Category", selection: $store.category.sending(\.categoryChanged)) {
      ForEach(Category.allCases, id: \.self) { category in
        Text(category.rawValue)
          .tag(category)
      }
    }
    .pickerStyle(.segmented)
  }
  
  @ViewBuilder private var AreaCourses: some View {
    List {
      ForEach(
        store.scope(state: \.filteredCourses, action: \.courseAct),
        id: \.id
      ) { store in
        Section {
          CourseView(store: store)
            .id(store.id)
        }
      }
    }
  }
}

#Preview {
  PlannerView(
    store: Store(
      initialState: PlannerDomain.State(),
      reducer: { PlannerDomain() }
    )
  )
}
