//
//  CourseView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import SwiftUI
import ComposableArchitecture

struct CourseView: View {
  @Bindable var store: StoreOf<CourseDomain>
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        CommonFrags.RoundedLabel(
          store.course.category,
          backgroundColor: Category(rawValue: store.course.category)?.bgColor ?? .gray
        )
        Text(verbatim: store.course.titleJa)
          .font(.system(size: 16.5, weight: .bold))
      }
      .padding(.horizontal, 0)
      .padding(.vertical, 4)
      
      // var effectValueText: String {
      // => CourseDomain으로 이동
      // }
      Text(verbatim: store.effectValueText)
        .font(.system(size: 13.5, weight: .regular))
      
      Divider()
      
      HStack {
        CommonFrags.RoundedLabel("方針Lv")
          .font(.system(size: 13))
        
        PlusMinusButton(
          store: store.scope(
            state: \.adjustLevelState,
            action: \.adjustLevel
          )
        )
        Spacer()
        CommonFrags.RoundedLabel("必要場数pt")
          .font(.system(size: 13))
        Text(verbatim: store.requireSheetsPointText)
          .font(.system(size: 13))
          .frame(minWidth: 40)
          .multilineTextAlignment(.trailing)
      }
      
      HStack {
        FragProgressBar(
          accomplishedCount: store.adjustLevelState.level,
          totalCount: store.course.effects.count
        )
        Spacer()
        CommonFrags.RoundedButton("詳細") {
          store.send(.setDetailSheetView(isPresented: true))
        }
      }
    }
    .task {
      // 세그먼트를 옮겨도 값이 초기화되지 않도록 삭제
      // store.send(.adjustLevel(.setInitLevel(0)))
      store.send(.refreshPointText)
    }
    .sheet(item: $store.scope(state: \.detailSheetState, action: \.detailSheetAct)) { store in
      DetailSheetView(store: store)
    }
  }
  
  private func parseJson() async throws {
    do {
      let apiClient = APIClient.liveValue
      let courses = try await apiClient.fetchCourses()
      
      for course in courses {
        print("코스: \(course.titleKo) / 효과 개수: \(course.effects.count)")
      }
    } catch {
      print("❌ 실패:", error)
    }
  }
}

extension CourseView {  
  @ViewBuilder private func FragProgressBar(accomplishedCount: Int, totalCount: Int) -> some View {
    HStack {
      let remainingCount = totalCount - accomplishedCount
      ForEach(0..<accomplishedCount, id: \.self) { count in
        Text("P")
          .foregroundStyle(.orange)
          .fontWeight(.heavy)
      }
      ForEach(0..<remainingCount, id: \.self) { count in
        Text("P")
          .foregroundStyle(.black.opacity(0.5))
          .fontWeight(.heavy)
      }
    }
  }
}

#Preview {
  List {
    ForEach(0..<2) { i in
      Section {
        CourseView(
          store: Store(
            initialState: CourseDomain.State(
              id: UUID(),
              course: .samples[i]
            ),
            reducer: { CourseDomain() }
          )
        )
      }
    }
  }
}

#Preview {
  List {
    CourseView(
      store: Store(
        initialState: CourseDomain.State(
          id: UUID(),
          course: .samples[2]
        ),
        reducer: { CourseDomain() }
      )
    )
  }
}
