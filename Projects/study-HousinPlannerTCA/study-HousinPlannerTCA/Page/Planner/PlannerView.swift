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
    VStack(spacing: 10) {
      AreaHeaderPanel
      AreaCategorySegments
      AreaCourses
    }
    .task {
      store.send(.fetchCourses)
    }
    
  }
}

extension PlannerView {
  @ViewBuilder private var AreaHeaderPanel: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Draft Name")
          .font(.title3)
          .bold()
        Spacer()
        VStack(alignment: .trailing) {
          CommonFrags.RoundedLabel("場数pt", verticalPadding: 0)
            .font(.system(size: 12))
          Text("987654/1000000")
            .font(.system(size: 13))
        }
        AreaButtons
      }
      HStack {
        ForEach(Category.allCases, id: \.self) { category in
          VStack(spacing: 0) {
            CommonFrags.RoundedLabel(
              category.rawValue,
              backgroundColor: category.bgColor
            )
            .font(.system(size: 13))
            Text("24/35")
              .font(.system(size: 13))
          }
          .frame(maxWidth: .infinity) // 🔑 균등 배분
        }
      }
    }
    .frame(height: 80)
    .padding(.horizontal, 10)
    .padding(.vertical, 0)
  }
  
  @ViewBuilder private var AreaCategorySegments: some View {
    Picker("Select a Category", selection: $store.category.sending(\.categoryChanged)) {
      ForEach(Category.allCases, id: \.self) { category in
        Text(category.rawValue)
          .tag(category)
      }
    }
    .pickerStyle(.segmented)
    .padding(.horizontal, 10)
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
    .padding(.top, 0)
  }
  
  @ViewBuilder private var AreaButtons: some View {
    HStack(spacing: 2) {
      Button(action: {}) {
        // Select a draft...
        Image(systemName: "doc.on.doc")
          .frame(width: 5)
      }
      Button(action: {}) {
        Image(systemName: "translate")
          .frame(width: 5)
      }
      Button(action: {}) {
        Image(systemName: "plus.forwardslash.minus")
          .frame(width: 5)
      }
      Button(action: {}) {
        Image(systemName: "trash")
          .frame(width: 5)
      }
    }
    .buttonStyle(.bordered)
    .font(.system(size: 10))
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
