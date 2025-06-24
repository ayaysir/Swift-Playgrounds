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

extension UserProfile {
  var fullName: String {
    "\(firstName) \(lastName)"
  }
}

extension UserProfile: Decodable {
  private enum ProfileKeys: String, CodingKey {
    case id
    case email
    case name // 중첩 오브젝트 파싱
    // name에 속해있는 하위 오브젝트
    case firstname
    case lastname
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ProfileKeys.self)
    self.id = try container.decode(Int.self, forKey: .id)
    self.email = try container.decode(String.self, forKey: .email)
    
    let nameContainer = try container.nestedContainer(
      keyedBy: ProfileKeys.self,
      forKey: .name
    )
    self.firstName = try nameContainer.decode(String.self, forKey: .firstname)
    self.lastName = try nameContainer.decode(String.self, forKey: .lastname)
    
    /*
     JSON 예상:
     {
       "id": 123,
       "email": "user@example.com",
       "name": {
         "firstname": "John",
         "lastname": "Doe"
       }
     }
     */
  }
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
