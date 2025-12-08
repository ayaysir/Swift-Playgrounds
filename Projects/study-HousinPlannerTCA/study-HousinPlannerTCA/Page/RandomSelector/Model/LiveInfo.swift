//
//  LiveInfo.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 11/20/25.
//

import Foundation

struct LiveInfo: Codable, Equatable, Identifiable {
  let id: UUID
  // タイプ  楽曲名  ☆  時間  Note  Long  Flick  Slide
  let title: String
  let difficulty: BeatmapDifficulty
  let type: String
  let grade: Int
  let time: String
  let note: Int
  let long: Double?
  let flick: Double?
  let slide: Double?
}

extension LiveInfo {
  init?(fromCSVArray array: [String], difficulty: BeatmapDifficulty) {
    guard let title = array[safe: 1],
          let type = array[safe: 0],
          let grade = array[safe: 2],
          let time = array[safe: 3],
          let note = array[safe: 4] else {
            print("dkfkfk:", array)
      return nil
    }
    
    let long: Double? = switch difficulty {
    case .masterPlus, .witch, .light, .trick:
      Double(array[safe: 5, default: ""])
    default:
      nil
    }
    
    let flick: Double? = switch difficulty {
    case .masterPlus, .witch, .trick:
      Double(array[safe: 6, default: ""])
    case .piano, .forte:
      Double(array[safe: 5, default: ""])
    default:
      nil
    }
    
    let slide: Double? = switch difficulty {
    case .masterPlus, .witch, .trick:
      Double(array[safe: 7, default: ""])
    case .piano, .forte:
      Double(array[safe: 6, default: ""])
    default:
      nil
    }
    
    self.init(
      id: UUID(),
      title: title,
      difficulty: difficulty,
      type: type,
      grade: Int(grade) ?? 0,
      time: time,
      note: Int(note) ?? 0,
      long: long,
      flick: flick,
      slide: slide
    )
  }
}
