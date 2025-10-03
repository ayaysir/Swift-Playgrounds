//
//  Draft.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/3/25.
//

import Foundation
import RealmSwift

struct Draft: Identifiable {
  let id: UUID
  var name: String
  var userSetTotalCount: Int
  var createdAt: Date
  var updatedAt: Date
  var courseLevelStates: [UUID : Int]
  
  // DraftObject -> Draft
  init(from object: DraftObject) {
    self.id = object.id
    self.name = object.name
    self.userSetTotalCount = object.userSetTotalCount
    self.createdAt = object.createdAt
    self.updatedAt = object.updatedAt
    self.courseLevelStates = Dictionary(
      uniqueKeysWithValues: object.courseLevelStates.map {
        ($0.courseId, $0.currentLevel)
      }
    )
  }
}

final class DraftObject: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: UUID = UUID()
  @Persisted var name: String = ""
  @Persisted var userSetTotalCount: Int = 0
  @Persisted var createdAt: Date = Date()
  @Persisted var updatedAt: Date = Date()
  @Persisted var courseLevelStates: RealmSwift.List<CourseLevelState> = .init()
  
  // @Persisted var plannerStateData: Data // PlannerDomain.State를 JSON으로 저장
  // @Persisted var planner: PlannerObject?  // Realm 오브젝트 직접 참조
}

final class CourseLevelState: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: UUID = UUID()
  @Persisted var courseId: UUID = UUID()
  @Persisted var currentLevel: Int = 0
}

// final class PlannerObject: Object, ObjectKeyIdentifiable {
//   @Persisted(primaryKey: true) var id: UUID = UUID()
//   // @Persisted var category: String = ""
//   @Persisted var userSetTotalCount: Int = 0
//   @Persisted var courses = RealmSwift.List<CourseObject>()
// }
// 
// final class CourseObject: Object, ObjectKeyIdentifiable {
//   @Persisted(primaryKey: true) var id: UUID = UUID()
//   @Persisted var name: String = ""
//   @Persisted var currentLevel: Int = 0
//   // @Persisted var effects = RealmSwift.List<EffectObject>()
// }

// 이건 저장 안해도 됨
// final class EffectObject: Object, ObjectKeyIdentifiable {
//   @Persisted var level: Int = 0
//   @Persisted var pointEach: Int = 0
//   @Persisted var pointCumulative: Int = 0
// }
