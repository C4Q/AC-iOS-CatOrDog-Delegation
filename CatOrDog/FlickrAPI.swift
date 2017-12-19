//
//  FlickrAPI.swift
//  CatOrDog
//
//  Created by Alex Paul on 12/19/17.
//  Copyright © 2017 Alex Paul. All rights reserved.
//

import Foundation

// creating custom delegation
// this is for memory management - avoid retain cycles
// 1) first part of custom delegation class
protocol APIServiceDelegate: class {
    // required by conforming class
    func apiLoaded() // no implementation, it's left to the conforming class
}

class FlickrAPI {
    
    // singleton - a global manager for our app
    
    // private default initializer
    // on first call for this calls this initializer is fired
    private init() {
        
        // cat search from appdelegate
        FlickrAPI.photoSearch(keyword: "cats") { (error, photos) in
            if let error = error {
                // handle error
            } else if let photos = photos {
                // we are setting the photos for cats in our data model
                PhotoDataModel.setCatPhotos(catPhotos: photos)
                
                // 3
                // inform listeners - critical part of creating custom delegation
                self.delegate?.apiLoaded()
            }
        }
        
        // dog search from appdelegate
        FlickrAPI.photoSearch(keyword: "dogs") { (error, photos) in
            if let error = error {
                // handle error
            } else if let photos = photos {
                // we are setting the photos for cats in our data model
                PhotoDataModel.setDogPhotos(dogPhotos: photos)
                
                // 3
                // inform listeners - critical part of creating custom delegation
                self.delegate?.apiLoaded()
            }
        }
    }
    
    // 2)
    // this is the variable needed to be set by the conforming class
    // e.g tableView.delegate = self
    weak var delegate: APIServiceDelegate?
    
    // to access singleton we need a handle
    static let apiservice = FlickrAPI()
    
    // URLSession instance
    static let session = URLSession.shared // this enable network handling
    
    // photo search function
    static func photoSearch(keyword: String, completion: @escaping (Error?, [Photo]?) -> Void) {
        
        let stringURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=35eaa828993d45c2d8de5b7d6ae3cf3e&lat=40.93&lon=-73.88&format=json&extras=url_m, description&per_page=200&text=\(keyword)&nojsoncallback=1&safe_search=3"
        let searchURL = stringURL.replacingOccurrences(of: " ", with: "")
        
        session.dataTask(with: URL(string: searchURL)!) { (data, response, error) in
            if let error = error {
                // handle error
                completion(error, nil)
            } else if let data = data {
                // JSON Parsing to create your model objects
                // In our case we need Photo Objects
                
                do {
                    let decoder = JSONDecoder()
                    let search = try decoder.decode(Search.self, from: data)
                    completion(nil, search.photos.photo) // return photos
                } catch {
                    print("decoding error: \(error.localizedDescription)")
                    completion(error, nil)
                }
                
                
            }
        }.resume()
        
    }
    
    func loadAPI() {}

    
}
