//
//  CSVParser.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 11/20/25.
//

import Foundation

func parseCSV(bundleName: String) -> [[String]] {
  guard let url = Bundle.main.url(forResource: bundleName, withExtension: "csv") else {
    fatalError("CSV file not found")
  }
  
  do {
    let data = try Data(contentsOf: url)
    
    guard let csvString = String(data: data, encoding: .utf8) else {
      fatalError("CSV file is not in UTF-8 format")
    }
    
    let rows = csvString
      .replacingOccurrences(of: "\r\n", with: "\n")
      .replacingOccurrences(of: "\r", with: "\n")
      .split(separator: "\n", omittingEmptySubsequences: false)
    
    let _ = rows.first!.split(separator: ",")
    
    // print(rows.count, rows)
    return rows.dropFirst().map { row -> [String] in
      row.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
    }
  } catch {
    print(error)
  }
  
  return []
}
