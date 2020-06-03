//
//  SearchViewController.swift
//  InstagramApp
//
//  Created by Gwinyai on 17/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var searchController: UISearchController!
    
    lazy var posts: [Post] = {
        
        let model = Model()
        
        return model.postList
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        
        collectionView.dataSource = self
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.obscuresBackgroundDuringPresentation = true
        
        searchController.searchBar.showsCancelButton = false
        
        for subView in searchController.searchBar.subviews {
            
            for subView1 in subView.subviews {
                
                if let textField = subView1 as? UITextField {
                    
                    textField.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
                    
                    textField.textAlignment = NSTextAlignment.center
                    
                }
                
            }
            
        }
        
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.definesPresentationContext = true
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)

        navigationItem.titleView = searchBarContainer
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreCollectionViewCell", for: indexPath) as! ExploreCollectionViewCell
        
        cell.exploreImage.image = posts[indexPath.row].postImage
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let post = posts[indexPath.row]
        
        let postStoryboard = UIStoryboard(name: "Post", bundle: nil)
        
        let postVC = postStoryboard.instantiateViewController(withIdentifier: "Post") as! PostViewController
        
        postVC.post = post
        
        navigationController?.pushViewController(postVC, animated: true)
        
    }

}
