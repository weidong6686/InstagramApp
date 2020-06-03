//
//  PhotoLibraryViewController.swift
//  InstagramApp
//
//  Created by Gwinyai on 25/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

import Photos

class PhotoLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var images = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        photosCollectionView.delegate = self
        
        photosCollectionView.dataSource = self
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            
            getImages()
            
        }
        else {
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                switch status {
                    
                case .authorized:
                    
                    DispatchQueue.main.async {
                        
                        self.getImages()
                        
                    }
                    
                case .denied, .notDetermined, .restricted:
                    
                    return
                    
                }
                
            }
            
        }
        
    }
    
    
    func getImages() {
        
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        
        assets.enumerateObjects({ (object, count, stop) in
            
            // self.cameraAssets.add(object)
            self.images.append(object)
        })
        
        //In order to get latest image first, we just reverse the array
        self.images.reverse()
        
        // To show photos, I have taken a UICollectionView
        self.photosCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let asset = images[indexPath.row]
        
        let manager = PHImageManager.default()
        
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        cell.tag = Int(manager.requestImage(for: asset,
                                            targetSize: CGSize(width: 120.0, height: 120.0),
                                            contentMode: .aspectFit,
                                            options: nil) { (result, _) in
                                                cell.photoImageView?.image = result
        })
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width * 0.32
        
        let height = self.view.frame.height * 0.179910045
        
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 2.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = images[indexPath.row]
        
        let manager = PHImageManager.default()
        
        manager.requestImage(for: asset,
                             targetSize: PHImageManagerMaximumSize,
                             contentMode: .aspectFit,
                             options: nil) { (result, _) in
                                
                                NotificationCenter.default.post(name: NSNotification.Name("createNewPost"), object: result)
                                
        }
        
    }
    
}
