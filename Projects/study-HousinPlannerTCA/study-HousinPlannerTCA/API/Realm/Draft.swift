//
//  Draft.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/3/25.
//

import Foundation
import RealmSwift

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
  @Persisted var courseId: String = ""
  @Persisted var currentLevel: Int = 0
}
