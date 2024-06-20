//
//  TransferableImage.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/20/24.
//

import SwiftUI

struct TransferableImage: Transferable {
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            return Self(data: data)
            
        }
        
        DataRepresentation(importedContentType: .movie) { data in
            return Self(data: data)
        }
    }
}
