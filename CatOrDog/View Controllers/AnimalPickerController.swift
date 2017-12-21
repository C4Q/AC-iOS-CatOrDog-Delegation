//
//  AnimalPickerController.swift
//  CatOrDog
//
//  Created by Alex Paul on 12/19/17.
//  Copyright © 2017 Alex Paul. All rights reserved.
//

import UIKit

// constants
struct PickerIndex {
    static let kCatIndex = "Last Cat Index viewed"
    static let kDogIndex = "Last Dog Index viewed"
}

class AnimalPickerController: UIViewController {
    
    @IBOutlet weak var catsCollectionView: UICollectionView!
    @IBOutlet weak var dogsCollectionView: UICollectionView!
    
    // constant for our cell spacing which will be consistent around our cells
    let cellSpacing: CGFloat = 10.0
    
    // keeps track of last index scrolled to
    private var catIndex: Int = 0
    private var dogIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FlickrAPI.apiservice.delegate = self
        
        // setup delegates and datasource
        
        // cat collection view
        catsCollectionView.dataSource = self
        catsCollectionView.delegate = self
        
        // dog collection view
        dogsCollectionView.dataSource = self
        dogsCollectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let index = UserDefaults.standard.object(forKey: PickerIndex.kCatIndex) as? Int {
            let indexPath = IndexPath(item: index, section: 0)
            catsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        if let index = UserDefaults.standard.object(forKey: PickerIndex.kDogIndex) as? Int {
            let indexPath = IndexPath(item: index, section: 0)
            dogsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension AnimalPickerController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == catsCollectionView {
            return PhotoDataModel.getCatPhotos().count
        } else { // dogs
            return PhotoDataModel.getDogPhotos().count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimalCell", for: indexPath) as! AnimalCell
        if collectionView == catsCollectionView {
            let photo = PhotoDataModel.getCatPhotos()[indexPath.row]
            configureCell(withPhoto: photo, forCell: cell)
        } else {
            let photo = PhotoDataModel.getDogPhotos()[indexPath.row]
            configureCell(withPhoto: photo, forCell: cell)
        }
        return cell
    }
    
    // helper function to configure cell
    func configureCell(withPhoto photo: Photo, forCell cell: AnimalCell) {
        // if we have the image in cache then set the image to the cell
        cell.imageView.image = #imageLiteral(resourceName: "placeholder-image")
        if let image = ImageCache.manager.cachedImage(url: photo.url_m) {
            cell.imageView.image = image
        }
        else { // we don't have an image for the cell in cache, let's process on background
            // keep track of cell that needs to be set so we don't set the wrong cell here and cause flickering
            cell.urlString = photo.url_m.absoluteString
            
            // documents directory
            // testing
            let cachesdirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            print(cachesdirectory ?? "")
            
            ImageCache.manager.processImageInBackground(imageURL: photo.url_m, completion: { (error, image) in
                if let error = error {
                    // handle error
                    print("error: \(error.localizedDescription)")
                } else if let image  = image  {
                    // set the cell if the url string matches
                    
                    // cells are being dequeued and reprocessed at this point so we need to update the cell we tagged earlier in the opening else statement
                    if cell.urlString == photo.url_m.absoluteString {
                        DispatchQueue.main.async {
                            cell.imageView.image = image
                        }
                    }
                }
            })
        }
    }
}

extension AnimalPickerController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let catVisibleCell = catsCollectionView.visibleCells
        let dogVisibleCell = dogsCollectionView.visibleCells
        
        // get the first cell
        if let firstCatCell = catVisibleCell.first {
            if let indexPath = catsCollectionView.indexPath(for: firstCatCell) {
                catIndex = indexPath.row
                UserDefaults.standard.set(catIndex, forKey: PickerIndex.kCatIndex)
            }
        }
        
        if let firstDogCell = dogVisibleCell.first {
            if let indexPath = dogsCollectionView.indexPath(for: firstDogCell) {
                dogIndex = indexPath.row
                UserDefaults.standard.set(dogIndex, forKey: PickerIndex.kDogIndex)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == catsCollectionView {
            let photo = PhotoDataModel.getCatPhotos()[indexPath.row] // get furry animal
            let cell = collectionView.cellForItem(at: indexPath) as! AnimalCell
            PhotoDataModel.manager.setProfile(image: cell.imageView.image, photo: photo)
            showAlert(title: "Furry Friend Selected", message: "\(photo.title)")
        } else {
            let photo = PhotoDataModel.getDogPhotos()[indexPath.row] // get mans best friend
            let cell = collectionView.cellForItem(at: indexPath) as! AnimalCell
            PhotoDataModel.manager.setProfile(image: cell.imageView.image, photo: photo)
            showAlert(title: "Man's Best Friend", message: "\(photo.title)")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { alert in self.tabBarController?.selectedIndex = 0 }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension AnimalPickerController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells: CGFloat = 2.0 // cells visible in row
        let numSpaces: CGFloat = numCells + 1
        let screenWidth = UIScreen.main.bounds.width // screen width of device
        
        // retrun item size
        return CGSize(width: (screenWidth - (cellSpacing * numSpaces)) / numCells, height: collectionView.bounds.height - (cellSpacing * 2))
    }
    
    // padding around our collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellSpacing, left: 0, bottom: cellSpacing, right: 0)
    }
    
    // padding between cells / items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}

extension AnimalPickerController: APIServiceDelegate {
    func apiLoaded() {
        catsCollectionView.reloadData()
        dogsCollectionView.reloadData()
    }
    
    
}

