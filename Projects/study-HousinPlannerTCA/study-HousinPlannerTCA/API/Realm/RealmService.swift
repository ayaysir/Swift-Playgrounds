//
//  RealmService.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/3/25.
//

import Foundation
import RealmSwift

final class RealmService {
  private init() {}
  static let shared = RealmService()
  
  let realm = try! Realm()
  
  // MARK: - Update
  
  func updateUserSetTotalCount(draftID: UUID, newValue: Int) {
    guard let draftObject = fetchDraftObject(by: draftID) else {
      return
    }
    
    do {
      try realm.write {
        draftObject.updatedAt = Date()
        draftObject.userSetTotalCount = newValue
      }
    } catch {
      print("Realm write error: \(error)")
    }
  }
  
  func updateCourseLevelState(draftID: UUID, courseID: String, level: Int) {
    guard let draftObject = fetchDraftObject(by: draftID) else {
      return
    }
    
    do {
      try realm.write {
        if let courseLevelState = draftObject.courseLevelStates.first(where: { $0.courseId == courseID }) {
          courseLevelState.currentLevel = level
          // print("courseLevelState: Updated")
        } else {
          // 새로운 CourseLevelState 추가
          let newCourseLevelState = CourseLevelState()
          newCourseLevelState.courseId = courseID
          newCourseLevelState.currentLevel = level
          draftObject.courseLevelStates.append(newCourseLevelState)
          // print("courseLevelState: created")
        }
        
        draftObject.updatedAt = Date()
        
        // let temp = draftObject.courseLevelStates.first(where: { $0.courseId == courseID })
        // print("Update courseLevelState success: \(temp?.currentLevel ?? -999)")
      }
    } catch {
      print("Realm write error: \(error)")
    }
  }
  
  /// Clear all CourseLevelStates in a Draft
  func clearCourseLevelStates(draftID: UUID) {
    guard let draftObject = fetchDraftObject(by: draftID) else {
      return
    }
    
    do {
      try realm.write {
        realm.delete(draftObject.courseLevelStates)
        draftObject.courseLevelStates.removeAll()
        draftObject.updatedAt = Date()
      }
    } catch {
      print("Realm write error: \(error)")
    }
  }
  
  // MARK: - Create, Read, Delete
 
  /// Create a new Draft
  func createDraftObject(name: String) -> DraftObject {
    let draftObject = DraftObject()
    draftObject.name = name
    draftObject.userSetTotalCount = 0
    
    do {
      try realm.write {
        realm.add(draftObject)
      }
    } catch {
      print("Realm write error: \(error)")
    }
    
    return draftObject
  }
  
  /// Fetch a Draft by id, return DraftObject
  func fetchDraftObject(by draftID: UUID) -> DraftObject? {
    realm.object(ofType: DraftObject.self, forPrimaryKey: draftID)
  }
  
  /// Fetch all Drafts
  func fetchAllDraftObjects() -> [DraftObject] {
    Array(realm.objects(DraftObject.self))
  }
  
  /// Fetch Specific CourseLvelState
  func fetchCourseLevelState(draftID: UUID, courseID: String) -> CourseLevelState? {
    guard let draftObject = fetchDraftObject(by: draftID) else {
      return nil
    }
    // print("courseID:\(courseID)", draftObject.courseLevelStates)
    return draftObject.courseLevelStates.first(where: { $0.courseId == courseID })
  }
  
  /// Delete a Draft by id
  func deleteDraftObject(draftID: UUID) {
    guard let draftObject = fetchDraftObject(by: draftID) else { return }
    do {
      try realm.write {
        realm.delete(draftObject)
      }
    } catch {
      print("Realm delete error: \(error)")
    }
  }
}
