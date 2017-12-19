//
//  ViewController.swift
//  CatOrDog
//
//  Created by Alex Paul on 12/19/17.
//  Copyright © 2017 Alex Paul. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegate
        // 1) set the delegate e.g tableView.delegate = self
        PhotoDataModel.manager.delegate = self 
    }
}

// 2) implementing the required protocol methods e.g cellForRowAtIndex.....
extension ProfileViewController: PhotoDataModelDelegate {
    func didUpdateProfile(_ image: UIImage?, photo: Photo) {
        // do all ui updates needed
        imageView.image = image
        descriptionLabel.text = photo.title
    }
}

