//
//  PhotoModel.swift
//  StaticWidget1Extension
//
//  Created by 윤범태 on 6/12/24.
//

import Foundation

/*
 (...)
 
 "items": [
   {
     "title": "PortAransas_011-Edit",
     "link": "https://www.flickr.com/photos/ajramlow/53783445512/",
     "media": {
       "m": "https://live.staticflickr.com/65535/53783445512_86b301a5b9_m.jpg"
     },
     "date_taken": "2024-05-17T08:14:43-08:00",
     "description": " \u003Cp\u003E\u003Ca href=\"https://www.flickr.com/people/ajramlow/\"\u003Eallen ramlow\u003C/a\u003E posted a photo:\u003C/p\u003E \u003Cp\u003E\u003Ca href=\"https://www.flickr.com/photos/ajramlow/53783445512/\" title=\"PortAransas_011-Edit\"\u003E\u003Cimg src=\"https://live.staticflickr.com/65535/53783445512_86b301a5b9_m.jpg\" width=\"240\" height=\"180\" alt=\"PortAransas_011-Edit\" /\u003E\u003C/a\u003E\u003C/p\u003E \u003Cp\u003EShip sailing through Port Aransas Pass.\u003C/p\u003E ",
     "published": "2024-06-11T14:37:21Z",
     "author": "nobody@flickr.com (\"allen ramlow\")",
     "author_id": "55673941@N03",
     "tags": "landscape ship shipping port aransas pass texas"
   },
 
   (...)
 */

struct PhotoModel: Codable {
    struct Item: Codable {
        struct Media: Codable {
            let m: String
        }
        
        let media: Media
    }
    
    let items: [Item]
}

extension PhotoModel {
    var url: String? {
        items.randomElement()?.media.m
    }
}
