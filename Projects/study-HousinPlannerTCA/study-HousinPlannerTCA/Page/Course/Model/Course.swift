//
//  Course.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import Foundation

struct Course: Equatable, Identifiable {
  let id: String
  let category: String
  let subcategory: String
  let titleJa: String
  let descJa: String
  let titleKo: String
  let descKo: String
  let effects: [CourseEffect]
}

extension Course: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case category = "category"
    case subcategory = "subcategory"
    case titleJa = "title_ja"
    case descJa = "desc_ja"
    case titleKo = "title_ko"
    case descKo = "desc_ko"
    case effects = "effects"
  }
  
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.category = try container.decode(String.self, forKey: .category)
    self.subcategory = try container.decode(String.self, forKey: .subcategory)
    self.titleJa = try container.decode(String.self, forKey: .titleJa)
    self.descJa = try container.decode(String.self, forKey: .descJa)
    self.titleKo = try container.decode(String.self, forKey: .titleKo)
    self.descKo = try container.decode(String.self, forKey: .descKo)
    self.effects = try container.decode([CourseEffect].self, forKey: .effects)
  }
}

extension Course {
  static var samples: [Course] = [
    .init(
      id: "test1",
      category: "idol",
      subcategory: "",
      titleJa: "キュートアイドル獲得ファンアップ",
      descJa: "キュートアイドルのアイドルが獲得するファン数がxxアップ",
      titleKo: "큐트 아이돌 팬 획득 증가",
      descKo: "큐트 아이돌이 획득하는 팬 수가 xx 증가",
      effects: [.samples[0], .samples[1]]
    ),
    .init(
      id: "test1b",
      category: "idol",
      subcategory: "",
      titleJa: "特技レベルアップ確率アップ",
      descJa: "レッスン時の特技レベルアップ確率がxxアップ",
      titleKo: "특기 레벨업 확률 증가",
      descKo: "레슨 시 특기 레벨업 확률이 xx 증가",
      effects: [.samples[2], .samples[3]]
    ),
    .init(
      id: "test2",
      category: "sales",
      subcategory: "",
      titleJa: "営業追加アイテム獲得",
      descJa: "営業で追加報酬が獲得できるようになる。",
      titleKo: "영업 추가 아이템 획득",
      descKo: "영업에서 추가 보상을 획득할 수 있게 됨",
      effects: [.samples[4]]
    )
  ]
}
