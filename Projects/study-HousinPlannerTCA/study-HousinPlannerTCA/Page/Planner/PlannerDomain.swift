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
    
    // @PresentationState는 TCA 1.3+에서 alert, sheet, fullScreenCover 같은 뷰 전환 상태를 표현하기 위한 속성 래퍼
    @Presents var inputSheetSt: InputSheetDomain.State?
    
    // 저장소(DB 등)와도 연동되어야 할 값들
    var userSetTotalCount: Int = 333
  }

  enum Action {
    case categoryChanged(Category)
    case fetchCourses
    case fetchCoursesResponse(TaskResult<[Course]>)
    case courseAct(IdentifiedActionOf<CourseDomain>)
    
    // case setUserTotalCount(Int)
    case inputSheetAct(PresentationAction<InputSheetDomain.Action>)
    case showInputSheet
    
    case resetAllCourseLevel
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
      case .inputSheetAct(.presented(.didTapCancel)):
        /*
         Sheet나 Navigation 같은 “Presentation 상태”는 상위 도메인(호출한 쪽) 에서 관리합니다.
         ⸻
         원칙
           •  @Presents var inputSheet: InputSheetDomain.State?
         → 이 값이 nil이 되면 SwiftUI 시트는 닫힙니다.
           •  따라서 “닫는다” 라는 행위는 PlannerDomain 이 inputSheet = nil 로 만들어야 합니다.
           •  하위 도메인(InputSheetDomain)에서는 단순히 “취소 눌렀다”, “확인 눌렀다” 같은 의도만 액션으로 보냅니다.
         */
        state.inputSheetSt = nil
        return .none
      case .inputSheetAct(.presented(.didTapConfirm)):
        if let text = state.inputSheetSt?.inputText,
           let value = Int(text) {
          state.userSetTotalCount = value
        }
        state.inputSheetSt = nil
        return .none
      case .inputSheetAct:
        return .none
      
      case .showInputSheet:
        state.inputSheetSt = InputSheetDomain.State()
        return .none
      case .resetAllCourseLevel:
        // 모든 course에 resetAdjustLevel 액션을 안전하게 전달 (TCA 1.3+)
        return .merge(
          state.courses.map { course in
            .run { send in
              // 각 course에 resetAdjustLevel 액션 전달
              // IdentifiedActionOf<CourseDomain>)의 .element 사용 (init 아님)
              await send(.courseAct(.element(id: course.id, action: .resetAdjustLevel)))
            }
          }
        )
      }
    }
    .forEach(\.courses, action: \.courseAct) {
      CourseDomain()
    }
    .ifLet(\.$inputSheetSt, action: \.inputSheetAct) {
      InputSheetDomain()
    }
  }
  
}

extension PlannerDomain.State {
  // var filteredCourses: IdentifiedArrayOf<CourseDomain.State> {
  //   courses.filter {
  //     $0.course.category == category.rawValue
  //   }
  // }
  
  // 🔑 카테고리별 총 effect 개수
  var totalEffectCountByCategory: [Category: Int] {
    Dictionary(
      grouping: courses,
      by: { Category(rawValue: $0.course.category)! }
    ).mapValues { courseStates in
      courseStates.reduce(0) {
        $0 + $1.course.effects.count
      }
    }
  }
  
  var selectedCountByCategory: [Category: Int] {
    Dictionary(
      grouping: courses,
      by: { Category(rawValue: $0.course.category)! }
    ).mapValues { courseStates in
      courseStates.reduce(0) {
        $0 + $1.adjustLevelState.level
      }
    }
  }
  
  var selectedEffectsTotalPoint: Int {
    courses.reduce(0) { result, state in
      let currentLevel = state.adjustLevelState.level
      let eachPoint = state.course.effects.first {
        currentLevel == $0.level
      }?.pointCumulative ?? 0
      return result + eachPoint
    }
  }
}
