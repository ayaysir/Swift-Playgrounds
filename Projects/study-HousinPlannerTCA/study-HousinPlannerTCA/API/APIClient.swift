//
//  APIClient.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import Foundation
import ComposableArchitecture
import DependenciesMacros

extension DependencyValues {
  var apiClient: APIClient {
    get { self[APIClient.self] }
    set { self[APIClient.self] = newValue }
  }
}

// APIClient라는 의존성을 정의하고, @Dependency(\.apiClient)처럼 도메인 내부에서 선언 없이 주입 받아 사용할 수 있게 합니다.
// DependencyClient: DependencyKey 자동 생성, DependencyValues[APIClient.self 자동 등록, 테스트 시 .withDependencies { }에서 모킹 가능

@DependencyClient
struct APIClient {
  // @Sendable: 클로저가 안전하게 여러 스레드에서 실행될 수 있음을 보장하는 특성
  var fetchCourses: @Sendable () async throws -> [Course]
  var updateUserSetTotalCount: (UUID, Int) -> Void
  // var createDraft: (_ name: String) throws -> Draft
  // var fetchAllDrafts: () throws -> [Draft]
  // var deleteDraft: (_ id: UUID) throws -> Void
  
  struct Failure: Error, Equatable {}
}

extension APIClient: TestDependencyKey {
  static let testValue = Self()
}

// This is the "live" fact dependency that reaches into the outside world to fetch the data from network.
// 이는 네트워크에서 데이터를 가져오기 위해 외부 세계에 접근하는 "실시간" 팩트 종속성입니다.
// Typically this live implementation of the dependency would live in its own module so that the
// 일반적으로 종속성의 이 실시간 구현은 자체 모듈에 존재하므로
// main feature doesn't need to compile it.
// 주요 기능에서 컴파일할 필요가 없습니다.

extension APIClient: DependencyKey {
  static let liveValue = Self(
    fetchCourses: {
      do {
        guard let coursesURL = Bundle.main.url(forResource: "Courses", withExtension: "json") else {
          throw APIClient.Failure()
        }
        let coursesData = try Data(contentsOf: coursesURL)
        var courses = try JSONDecoder().decode([Course].self, from: coursesData)
        
        guard let effectsURL = Bundle.main.url(forResource: "CourseEffects", withExtension: "json") else {
          throw APIClient.Failure()
        }
        let effectsData = try Data(contentsOf: effectsURL)
        let courseEffects = try JSONDecoder().decode([CourseEffect].self, from: effectsData)
        
        for index in courses.indices {
          let matchedEffects = courseEffects.filter { $0.courseId == courses[index].id }
          courses[index].effects = matchedEffects
        }
        
        return courses
      } catch {
        print(error)
        throw APIClient.Failure()
      }
    },
    updateUserSetTotalCount: { draftID, totalPoint in
      RealmService.shared.updateUserSetTotalCount(draftID: draftID, newValue: totalPoint)
    }
    // createDraft: { name in
    //   RealmService.shared.createDraft(name: name)
    // },
    // fetchAllDrafts: {
    //   []
    // },
    // deleteDraft: { id in
    //   RealmService.shared.deleteDraft(draftID: id)
    // }
  )
}
