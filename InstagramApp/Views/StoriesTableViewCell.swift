//
//  StoriesTableViewCell.swift
//  InstagramApp
//
//  Created by Gwinyai on 17/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class StoriesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var stories: [Story] = {
        
        let model = Model()
        
        return model.storyList
        
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = UITableViewCell.SelectionStyle.none
        
        collectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryCollectionViewCell")
        
        collectionView.delegate = self
        
        collectionView.dataSource = self
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return stories.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as! StoryCollectionViewCell
        
        
        cell.storyImage.image = stories[indexPath.row].post.postImage
        
        cell.userNameLabel.text = stories[indexPath.row].post.user.name
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 90, height: 110)
        
    }
    
}
