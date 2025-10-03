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
    @Presents var removeAlert: AlertState<Action.Alert>?
    
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
    
    // PresentationAction은 알림(alert) 등 일시적 상태를 처리할 때 쓰는 구조
    // SwiftUI의 .alert(...)과 연동될 수 있음
    case removeAlertAct(PresentationAction<Alert>)
    
    @CasePathable
    enum Alert {
      case didConfirmRemoveAll
      case didCancel
    }
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
        // 작업 수행 전에 경고창 (removeAlert)을 띄워 물어보기
        /*
         AlertState<Action>
          - SwiftUI의 Alert를 상태(state)로 표현한 타입
          - 제네릭 Action을 받는데, Alert 버튼을 눌렀을 때 상위 도메인에 전달할 액션 타입을 지정합니다.
          - 즉, Alert을 도메인 안에서 안전하게 관리할 수 있게
         
         TextState
          - Alert 제목, 메시지, 버튼 라벨 등을 문자열 대신 표현하는 타입
          - TextState("초기화") → SwiftUI의 Text("초기화") 같은 역할
          - 로컬라이징, 다국어, 동적 변환 등을 지원하기 위해 TextState로 래핑
         */
        state.removeAlert = AlertState {
          TextState("모든 사용자 설정 레벨을 초기화하시겠습니까?")
        } actions: {
          ButtonState(role: .destructive, action: .didConfirmRemoveAll) {
            TextState("초기화")
          }
          ButtonState(role: .cancel, action: .didCancel) {
            TextState("취소")
          }
        } message: {
          TextState("이 작업은 되돌릴 수 없습니다.")
        }
        return .none
      case .removeAlertAct(.presented(let alertAction)):
        return switchAlertAction(state: &state, alertAction: alertAction)
      case .removeAlertAct:
        return .none
      }
    }
    .forEach(\.courses, action: \.courseAct) {
      CourseDomain()
    }
    .ifLet(\.$inputSheetSt, action: \.inputSheetAct) {
      InputSheetDomain()
    }
    .ifLet(\.$removeAlert, action: \.removeAlertAct)
  }
  
  private func switchAlertAction(
    state: inout Self.State,
    alertAction: Action.Alert
  ) -> Effect<Action> {
    switch alertAction {
    case .didConfirmRemoveAll:
      // 모든 course에 resetAdjustLevel 액션을 안전하게 전달
      return .merge(
        state.courses.map { course in
          .run { send in
            // 각 course에 resetAdjustLevel 액션 전달
            // IdentifiedActionOf<CourseDomain>)의 .element 사용 (init 아님)
            await send(.courseAct(.element(id: course.id, action: .resetAdjustLevel)))
          }
        }
      )
    case .didCancel:
      state.removeAlert = nil
      return .none
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
