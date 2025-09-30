//
//  CourseEffect.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import Foundation

struct CourseEffect: Equatable, Identifiable {
  let id: String
  let courseId: String
  let level: Int
  let valueEffect: Int
  let pointEach: Int
  let pointCumulative: Int
}

extension CourseEffect: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case courseId = "course_id"
    case level = "level"
    case valueEffect = "value_effect"
    case pointEach = "point_each"
    case pointCumulative = "point_cumulative"
  }
  
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    // 숫자든 문자열이든 String으로 변환
    if let intId = try? container.decode(Int.self, forKey: .id) {
      id = String(intId)
    } else {
      id = try container.decode(String.self, forKey: .id)
    }
    self.courseId = try container.decode(String.self, forKey: .courseId)
    self.level = try container.decode(Int.self, forKey: .level)
    self.valueEffect = try container.decode(Int.self, forKey: .valueEffect)
    self.pointEach = try container.decode(Int.self, forKey: .pointEach)
    self.pointCumulative = try container.decode(Int.self, forKey: .pointCumulative)
  }
}

extension CourseEffect {
  static var samples: [CourseEffect] {
    [
      .init(
        id: "1",
        courseId: "test1",
        level: 1,
        valueEffect: 8,
        pointEach: 20000,
        pointCumulative: 20000
      ),
      .init(
        id: "2",
        courseId: "test1",
        level: 2,
        valueEffect: 16,
        pointEach: 100000,
        pointCumulative: 120000
      ),
      .init(
        id: "3",
        courseId: "test1b",
        level: 1,
        valueEffect: 20,
        pointEach: 5000,
        pointCumulative: 5000
      ),
      .init(
        id: "4",
        courseId: "test1b",
        level: 2,
        valueEffect: 50,
        pointEach: 2000,
        pointCumulative: 7000
      ),
      .init(
        id: "5",
        courseId: "test2",
        level: 1,
        valueEffect: -1,
        pointEach: 6000,
        pointCumulative: 6000
      ),
    ]
  }
}
