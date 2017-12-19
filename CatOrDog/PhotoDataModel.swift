//
//  PhotoDataModel.swift
//  CatOrDog
//
//  Created by Alex Paul on 12/19/17.
//  Copyright © 2017 Alex Paul. All rights reserved.
//
//
//  Function of class:- manages our Photo Data

import UIKit

// 1
// custom delegate
protocol PhotoDataModelDelegate: class {
    func didUpdateProfile(_ image: UIImage?, photo: Photo)
}

class PhotoDataModel {
    
    // singleton
    private init() {}
    static let manager = PhotoDataModel()
    
    // encapsulation - big on interview questions
    // good object oriented programming principles *******
    static private var catPhotos = [Photo]()
    static private var dogPhotos = [Photo]()
    
    // 2 e.g delegate from tableView
    weak var delegate: PhotoDataModelDelegate?

    // setters
    static func setCatPhotos(catPhotos: [Photo]) {
        self.catPhotos = catPhotos
    }
    
    static func setDogPhotos(dogPhotos: [Photo]) {
        self.dogPhotos = dogPhotos
    }
    
    // getters
    static func getCatPhotos() -> [Photo] {
        return catPhotos
    }
    
    static func getDogPhotos() -> [Photo] {
        return dogPhotos
    }
    
    func setProfile(image: UIImage?, photo: Photo) {
        // 3 setting the delegate
        delegate?.didUpdateProfile(image, photo: photo)
    }
}
