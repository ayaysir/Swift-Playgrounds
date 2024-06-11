//
//  TextModel.swift
//  StaticWidget1Extension
//
//  Created by 윤범태 on 6/11/24.
//

import Foundation

struct TextModel: Codable {
    enum CodingKeys : String, CodingKey {
        case datas = "data"
    }
    
    let datas: [String]
}
