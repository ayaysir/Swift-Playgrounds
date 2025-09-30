//
//  PlannerDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/30/25.
//

import ComposableArchitecture

@Reducer
struct PlannerDomain {
  @ObservableState
  struct State: Equatable {
    var category: Category = .idol
    var courses: IdentifiedArrayOf<CourseDomain.State> = []
    
    var filteredCourses: IdentifiedArrayOf<CourseDomain.State> {
      courses.filter {
        $0.course.category == category.rawValue
      }
    }
  }

  enum Action {
    case categoryChanged(Category)
    case fetchCourses
    case fetchCoursesResponse(TaskResult<[Course]>)
    case courseAct(IdentifiedActionOf<CourseDomain>)
  }
  
  @Dependency(\.apiClient.fetchCourses) var fetchCourses
  @Dependency(\.uuid) var uuid

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .categoryChanged(newCategory):
        state.category = newCategory
        return .none
      case .fetchCourses:
        return .run { send in
          await send(.fetchCoursesResponse(TaskResult {
            try await self.fetchCourses()
          }))
        }
      case .fetchCoursesResponse(.success(let courses)):
        state.courses = IdentifiedArrayOf(
          uniqueElements: courses.map {
            CourseDomain.State(id: self.uuid(), course: $0)
          }
        )
        
        return .none
      case .fetchCoursesResponse(.failure(let error)):
        print("fetchProductsResponse Error: \(error)")
        print("Error getting courses, try again later.")
        
        return .none
      case .courseAct(_):
        return .none
      }
    }
    .forEach(\.courses, action: \.courseAct) {
      CourseDomain()
    }
  }
}
