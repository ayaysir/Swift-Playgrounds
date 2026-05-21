//
//  ChatMessage.swift
//  study-FoundationModel
//
//  Created by 윤범태 on 5/21/26.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let date: Date = .now
}
