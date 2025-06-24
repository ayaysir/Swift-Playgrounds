//
//  UserProfile.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//

import Foundation

struct UserProfile: Equatable {
  let id: Int
  let email: String
  let firstName: String
  let lastName: String
}

extension UserProfile: Decodable {
  private enum ProfileKeys: String, CodingKey {
    case id
    case email
    case name
    case firstname
    case lastname
  }
  
  // ..
}

extension UserProfile {
  static var sample: UserProfile {
    .init(
      id: 1,
      email: "hello@demo.com",
      firstName: "Pedro",
      lastName: "Rojas"
    )
  }
  
  static var `default`: UserProfile {
    .init(
      id: 0,
      email: "",
      firstName: "",
      lastName: ""
    )
  }
}
