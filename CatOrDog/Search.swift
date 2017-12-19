//
//  Search.swift
//  CatOrDog
//
//  Created by Alex Paul on 12/19/17.
//  Copyright © 2017 Alex Paul. All rights reserved.
//

import Foundation

struct Photo: Codable {
    let id: String
    let title: String
    let url_m: URL // image URL
}

struct Results: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo] // array of photos from JSON data
}

struct Search: Codable {
    let photos: Results
}
