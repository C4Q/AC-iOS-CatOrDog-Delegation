//
//  AnimalCell.swift
//  CatOrDog
//
//  Created by Alex Paul on 12/19/17.
//  Copyright © 2017 Alex Paul. All rights reserved.
//

import UIKit

class AnimalCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // for use when caching to keep track of setting an cells' image
    var urlString: String = ""
}
