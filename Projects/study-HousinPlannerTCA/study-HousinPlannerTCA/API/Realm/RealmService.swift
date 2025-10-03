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
  
  // MARK: - Draft CRUD (Create, Read, Delete)
 
  /// Create a new Draft
  func createDraft(name: String) -> Draft {
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
    
    return Draft(from: draftObject)
  }
  
  /// Fetch a Draft by id, return DraftObject
  private func fetchDraftObject(by draftID: UUID) -> DraftObject? {
    realm.object(ofType: DraftObject.self, forPrimaryKey: draftID)
  }
  
  func fetchDraft(by draftID: UUID) -> Draft? {
    guard let draftObject = fetchDraftObject(by: draftID) else { return nil }
    return Draft(from: draftObject)
  }
  
  /// Fetch all Drafts
  func fetchAllDrafts() -> [Draft] {
    realm.objects(DraftObject.self).map {
      Draft(from: $0)
    }
  }
  
  /// Delete a Draft by id
  func deleteDraft(draftID: UUID) {
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
