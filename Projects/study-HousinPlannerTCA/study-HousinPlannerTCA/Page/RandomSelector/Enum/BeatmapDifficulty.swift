//
//  BeatmapGrade.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 12/8/25.
//

import Foundation

enum BeatmapDifficulty: Codable, Hashable, Identifiable, CaseIterable {
  var id: String {
    upperShortenDesc
  }
  
  case debut
  case regular
  case pro
  case master
  case masterPlus
  case legacyMasterPlus
  case witch
  case piano
  case forte
  case light
  case trick
  
  var upperShortenDesc: String {
    switch self {
    case .debut:
      "DEBUT"
    case .regular:
      "REG"
    case .pro:
      "PRO"
    case .master:
      "MAS"
    case .masterPlus:
      "MAS+"
    case .witch:
      "WITCH"
    case .piano:
      "PIANO"
    case .forte:
      "FORTE"
    case .light:
      "LIGHT"
    case .trick:
      "TRICK"
    case .legacyMasterPlus:
      "L.MAS+"
    }
  }
  
  static var casesWithoutBasic: [Self] {
    [
      .masterPlus,
      .witch,
      .piano,
      .forte,
      .light,
      .trick,
    ]
  }
}
