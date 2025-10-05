//
//  PlannerDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/30/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PlannerDomain {
  @ObservableState
  struct State: Equatable {
    var category: Category = .idol
    var courses: IdentifiedArrayOf<CourseDomain.State> = []
    var locale: PlannerLocale = .ja
    
    // @PresentationState는 TCA 1.3+에서 alert, sheet, fullScreenCover 같은 뷰 전환 상태를 표현하기 위한 속성 래퍼
    @Presents var inputSheetSt: InputSheetDomain.State?
    @Presents var removeAlert: AlertState<Action.Alert>?
    @Presents var draftListSheetSt: DraftListDomain.State?
    
    // 저장소(DB 등)와도 연동되어야 할 값들
    var userSetTotalCount: Int = 333
    var currentDraftID: UUID?
    var currentDraftName = "Draft"
  }

  enum Action {
    case categoryChanged(Category)
    case fetchCourses
    case fetchCoursesResponse(TaskResult<[Course]>)
    case courseAct(IdentifiedActionOf<CourseDomain>)
    
    case selectDraftWithUserPoint(UUID, Int)
    case selectDraft(UUID)
    case initDraft
    
    // case setUserTotalCount(Int)
    case inputSheetAct(PresentationAction<InputSheetDomain.Action>)
    case showInputSheet
    
    case draftListSheetAct(PresentationAction<DraftListDomain.Action>)
    case showDraftListSheet
    
    case resetAllCourseLevel
    
    case changeLocale(PlannerLocale)
    case toggleNextLocale
    
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
  @Dependency(\.apiClient.updateUserSetTotalCount) var updateUserSetTotalCount
  @Dependency(\.uuid) var uuid

  var body: some ReducerOf<Self> {
    Reduce {
      state,
      action in
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
            CourseDomain.State(id: self.uuid(), course: $0, locale: state.locale)
          }
        )
        
        return .none
        
      case .fetchCoursesResponse(.failure(let error)):
        print("fetchProductsResponse Error: \(error)")
        print("Error getting courses, try again later.")
        
        return .none
        
      case .courseAct(.element(id: let courseDomainID, action: .requestUpdateLevel)):
        // 주의: courseDomainID는 도메인의 UUID이고 DB에 저장되는 ID는 CourseDomain.course.id(String) 임
        // print(courseDomainID, state.courses.first(where: { $0.id == courseDomainID })?.course.id)
        if let courseState = state.courses.first(where: { $0.id == courseDomainID }),
           let draftID = state.currentDraftID {
          let courseID = courseState.course.id
          let level = courseState.adjustLevelState.level
          RealmService.shared.updateCourseLevelState(draftID: draftID, courseID: courseID, level: level)
        }
        return .none
        
      case .courseAct(.element(id: let courseDomainID, action: .requestFetchLevel)):
        // 주의: courseDomainID는 도메인의 UUID이고 DB에 저장되는 ID는 CourseDomain.course.id(String) 임
        return fetchUserCourseLevel(&state, courseDomainID: courseDomainID)
        
      case .courseAct:
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
          
          if let currentDraftID = state.currentDraftID {
            RealmService.shared.updateUserSetTotalCount(draftID: currentDraftID, newValue: value)
          }
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
        
      case .selectDraftWithUserPoint(let id, let point):
        state.currentDraftID = id
        state.userSetTotalCount = point
        return .none
        
      case .selectDraft(let id):
        let point = RealmService.shared.fetchDraftObject(by: id)?.userSetTotalCount ?? 0
        return .send(.selectDraftWithUserPoint(id, point))
        
      case .initDraft:
        // TODO: - 앱 설치 직후: 생성된 드래프트, 그 이후: 최근 작업한 드래프트를 열기
        if let firstDraft = RealmService.shared.fetchAllDraftObjects().first {
          return readDraftData(&state, draftID: firstDraft.id)
        }
        return .none
        
      case .showDraftListSheet:
        if let currentDraftID = state.currentDraftID {
          state.draftListSheetSt = DraftListDomain.State(selectedDraftID: currentDraftID)
          // 하위 도메인 액션을 즉시 실행 (ifLet 연결되었는지 확인)
          return .send(.draftListSheetAct(.presented(.fetchDraftList)))
        }
        
        return .none
        
      case .draftListSheetAct(.presented(.didTapClose)),
          .draftListSheetAct(.dismiss):
        state.draftListSheetSt = nil
        return .none
        
      case .draftListSheetAct(.presented(.didSelectDraft(let draftID))):
        if state.draftListSheetSt != nil {
          state.draftListSheetSt = nil
        }
        return readDraftData(&state, draftID: draftID)
        
      case .draftListSheetAct(.presented(.requestRemoveDraft(let draftID))):
        // print("PlannerDomain rmoveRqst:", draftID)
        // 그냥 삭제작업을 실행하려고 하면 *** Terminating app due to uncaught exception 'RLMException', reason: 'Object has been deleted or invalidated.' 에러 발생
        // 먼저 draftList에서 삭제 대상 오브젝트를 제거 후, 시간차를 두고 삭제 작업 실행 (동시에 할 경우 여전히 에러)

        if let targetIndex = state.draftListSheetSt?.draftList.firstIndex(where: { $0.id == draftID }) {
          state.draftListSheetSt?.draftList.remove(at: targetIndex)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // print("delete")
            RealmService.shared.deleteDraftObject(draftID: draftID)
          }
        }
        
        // state.draftListSheetSt?.draftList = RealmService.shared.fetchAllDraftObjects()
        return .none
        
      case .draftListSheetAct:
        return .none
        
      case .changeLocale(let locale):
        state.locale = locale
        // 하위 도메인의 액션(courseAct)에 있는 .receiveLocaleChanged(locale) 를 실행 (모든 하위 도메인에 적용)
        let effects = state.courses.map { course -> Effect<Action> in
          return .send(
            .courseAct(
              .element(id: course.id, action: .receiveLocaleChanged(locale))
            )
          )
        }
        return .merge(effects)
        
      case .toggleNextLocale:
        let allLocales = PlannerLocale.allCases
        if let currentIndex = allLocales.firstIndex(of: state.locale) {
          let nextIndex = (currentIndex + 1) % allLocales.count
          return .send(.changeLocale(allLocales[nextIndex]))
        }
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
    .ifLet(\.$draftListSheetSt, action: \.draftListSheetAct) {
      DraftListDomain()
    }

    /*
      .onChange(of: {$0}) { oldValue, newValue in
        Reduce { _, _ in
          print("$0", oldValue, newValue)
          return .none
        } // https://maramincho.tistory.com/126
      }
      .onChange(of: \.userSetTotalCount) { oldValue, newValue in
        Reduce { state, _ in
          // userSetTotalCount가 변경되면 DB에 저장
     
          return .none
        }
      }
      .onChange(of: \.courses) { oldValue, newValue in
        Reduce { state, _ in
          // courses가 변경되면 DB에 저장
          return .none
        }
      }
     */
  }
  
  private func switchAlertAction(
    state: inout Self.State,
    alertAction: Action.Alert
  ) -> Effect<Action> {
    switch alertAction {
    case .didConfirmRemoveAll:
      // 모든 course에 resetAdjustLevel 액션을 안전하게 전달
      let currentDraftID = state.currentDraftID
      return .merge(
        state.courses.map { course in
          .run { send in
            // 각 course에 resetAdjustLevel 액션 전달
            // IdentifiedActionOf<CourseDomain>)의 .element 사용 (init 아님)
            await send(.courseAct(.element(id: course.id, action: .resetAdjustLevel)))
            await MainActor.run {
              if let currentDraftID {
                RealmService.shared.clearCourseLevelStates(draftID: currentDraftID)
              }
            }
          }
        }
      )
    case .didCancel:
      state.removeAlert = nil
      return .none
    }
  }
  
  private func fetchUserCourseLevel(
    _ state: inout Self.State,
    courseDomainID: UUID
  ) -> Effect<Action> {
    if let courseState = state.courses.first(where: { $0.id == courseDomainID }),
       let draftID = state.currentDraftID,
       let fetchedLevel = fetchUserCourseState(courseState: courseState, draftID: draftID)?.currentLevel {
      return .send(
        .courseAct(
          .element(id: courseDomainID, action: .adjustLevel(.setInitLevel(fetchedLevel)))
        )
      )
    }
    
    return .none
  }
  
  private func fetchUserCourseState(courseState: CourseDomain.State, draftID: UUID) -> CourseLevelState? {
    let courseID = courseState.course.id
    return RealmService.shared.fetchCourseLevelState(draftID: draftID, courseID: courseID)
  }
  
  private func readDraftData(_ state: inout Self.State, draftID: UUID) -> Effect<Action> {
    // print("draft: \(draftID)")
    
    let draftObj = RealmService.shared.fetchDraftObject(by: draftID)
    state.currentDraftID = draftID
    state.userSetTotalCount = draftObj?.userSetTotalCount ?? 0
    state.currentDraftName = draftObj?.name ?? "Unknown Draft"
    
    let courses = state.courses   // ✅ 값 복사
    /*
     코스 도메인을 순회하며
     .courseAct(
       .element(id: courseDomainID, action: .adjustLevel(.setInitLevel(fetchedLevel)))
     )
     */
    // [Effect<PlannerDomain.Action>]
    let mergedActions = courses.compactMap { course -> Effect<Action>? in
      let fetchedLevel = fetchUserCourseState(courseState: course, draftID: draftID)?.currentLevel
      
      // 하위 도메인 CourseDomain에 액션 보내기
      return .send(
        .courseAct(
          .element(
            id: course.id,
            action: .adjustLevel(.setInitLevel(fetchedLevel ?? 0))
          )
        )
      )
    }
    
    return .merge(mergedActions)
  }
}


extension PlannerDomain.State {
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
  
  var needPtText: String {
    switch locale {
    case .ja: "場数pt"
    case .ko: "장수pt"
    }
  }
}
