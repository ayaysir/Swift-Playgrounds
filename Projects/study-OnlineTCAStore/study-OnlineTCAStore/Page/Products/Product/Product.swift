//
//  Product.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//

import Foundation

struct Product: Equatable, Identifiable {
  let id: Int
  let title: String
  let price: Double // Update to Currency
  let description: String
  let category: String // Update to enum
  let imageString: String
  
  // Add rating later...
}
