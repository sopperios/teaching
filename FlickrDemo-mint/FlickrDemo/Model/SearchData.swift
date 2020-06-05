//
//  SearchData.swift
//  FlickrDemo
//
//  Created by apple on 2020/5/22.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    var farm: Int?
    var secret: String?
    var id: String?
    var server: String?
    var title: String?
    var isFavorites: Bool?
    var indexPathItem: Int?
    var favoritesImageUrl: String?
    var imageUrl: URL {
        if let farm = self.farm {
            return URL(string: "https://farm\(farm).staticflickr.com/\(server!)/\(id!)_\(secret!)_m.jpg")!
        } else {
            // 隨便帶入網址，只是怕會跳出錯誤
            return URL(string: "https://farm")!
        }
        
    }
    
    
    init(farm: Int?, secret: String?, id: String?, server: String? ,isFavorites: Bool?, indexPathItem: Int?, title: String?, favoritesImageUrl: String) {
        self.farm = farm
        self.secret = secret
        self.id = id
        self.server = server
        self.isFavorites = isFavorites
        self.indexPathItem = indexPathItem
        self.title = title
        self.favoritesImageUrl = favoritesImageUrl
    }
    
}

struct PhotoData: Decodable {
    var photo: [Photo]
}

struct SearchData: Decodable {
    var photos: PhotoData
}
