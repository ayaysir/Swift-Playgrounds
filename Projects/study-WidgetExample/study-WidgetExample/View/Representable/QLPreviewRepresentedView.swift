//
//  QLPreviewRepresentedView.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/22/24.
//

import SwiftUI
import QuickLook

struct QLPreviewRepresentedView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        let parent: QLPreviewRepresentedView
        
        init(parent: QLPreviewRepresentedView) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(
            in controller: QLPreviewController
        ) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            return parent.url as NSURL
        }
    }
}

#Preview {
    QLPreviewRepresentedView(url: Bundle.main.url(forResource: "LeBao", withExtension: "jpg")!)
}
