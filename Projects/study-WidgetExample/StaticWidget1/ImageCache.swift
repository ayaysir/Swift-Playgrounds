//
//  ImageCache.swift
//  StaticWidget1Extension
//
//  Created by 윤범태 on 6/12/24.
//

import UIKit

final class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
    
    private init() {}
}
