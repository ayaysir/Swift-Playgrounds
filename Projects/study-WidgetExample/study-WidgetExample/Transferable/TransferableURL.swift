//
//  TransferableURL.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/20/24.
//

import SwiftUI

/// File representation
struct TransferableURL: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .data) { data in
            SentTransferredFile(data.url)
        } importing: { received in
            Self(url: received.file)
        }
    }
}
