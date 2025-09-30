//
//  CourseView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import SwiftUI
import ComposableArchitecture

struct CourseView: View {
  let store: StoreOf<CourseDomain>
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        FragRoundedLabel(
          store.course.category,
          backgroundColor: Category(rawValue: store.course.category)?.bgColor ?? .gray
        )
        Text(verbatim: store.course.titleJa)
          .font(.system(size: 17, weight: .bold))
      }
      .padding(.horizontal, 0)
      .padding(.vertical, 4)
      
      // var effectValueText: String {
      // => CourseDomain으로 이동
      // }
      Text(verbatim: store.effectValueText)
        .font(.system(size: 14, weight: .regular))
      
      Divider()
      
      HStack {
        FragRoundedLabel("方針Lv")
        
        PlusMinusButton(
          store: store.scope(
            state: \.adjustLevelState,
            action: \.adjustLevel
          )
        )
        Spacer()
        FragRoundedLabel("場数pt")
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
        Button(action: {}) {
          Text("詳細")
            .font(.system(size: 14))
            .padding(.horizontal, 10)
            .padding(.vertical, 2.5)
            .background(.gray.opacity(0.3))
            .clipShape(.buttonBorder)
        }
        .buttonStyle(.plain)
      }
    }
    .task {
      store.send(.adjustLevel(.setInitLevel(0)))
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
  @ViewBuilder private func FragRoundedLabel(
    _ text: String,
    backgroundColor: Color = .gray,
    foregroundColor: Color = .white
  ) -> some View {
    Text(verbatim: text)
      .padding(.horizontal, 10)
      .padding(.vertical, 1)
      .background(backgroundColor)
      .foregroundStyle(foregroundColor)
      .bold()
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
  
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
