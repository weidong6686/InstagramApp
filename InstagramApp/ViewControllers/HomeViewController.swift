//
//  HomeViewController.swift
//  InstagramApp
//
//  Created by Gwinyai on 17/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var posts: [Post] = {
        
        let model = Model()
        
        return model.postList
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = CGFloat(88.0)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTableViewCell")
        
        tableView.register(UINib(nibName: "StoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "StoriesTableViewCell")
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        
        var leftBarItemImage = UIImage(named: "camera_nav_icon")
        
        leftBarItemImage = leftBarItemImage?.withRenderingMode(.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarItemImage, style: .plain, target: self, action: #selector(newPostButtonDidTouch))
        
        let profileImageView = UIImageView(image: UIImage(named: "logo_nav_icon"))
        
        self.navigationItem.titleView = profileImageView
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesTableViewCell") as! StoriesTableViewCell
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        
        let currentIndex = indexPath.row - 1
        
        let postData = posts[currentIndex]
        
        cell.profileImage.image = postData.user.profileImage
        
        cell.postImage.image = postData.postImage
        
        cell.dateLabel.text = postData.datePosted
        
        cell.likesCountLabel.text = "\(postData.likesCount) likes"
        
        cell.postCommentLabel.text = postData.postComment
        
        cell.userNameTitleButton.setTitle(postData.user.name, for: .normal)
        
        if postData.comments.count > 0 {
            
            let commentTitle = postData.comments.count == 1 ? "View 1 comment" : "View all \(postData.comments.count) comments"
        
            cell.commentCountButton.setTitle(commentTitle, for: .normal)
            
            cell.commentCountButton.isEnabled = true
            
        }
        else {
            
            cell.commentCountButton.setTitle("0 comments", for: .normal)
            
            cell.commentCountButton.isEnabled = false
            
        }
        
        cell.feedDelegate = self
        
        cell.profileDelegate = self
        
        cell.post = postData
        
        return cell
        
    }
    
    @objc func newPostButtonDidTouch() {
        
        let newPostStoryboard = UIStoryboard(name: "NewPost", bundle: nil)
        
        let newPostVC = newPostStoryboard.instantiateViewController(withIdentifier: "NewPost") as! NewPostViewController
        
        let navController = UINavigationController(rootViewController: newPostVC)
        
        present(navController, animated: true, completion: nil)
        
    }

}

extension HomeViewController: FeedDataDelegate {
    
    func commentsDidTouch(post: Post) {
        
        let postStoryboard = UIStoryboard(name: "Post", bundle: nil)
        
        let postVC = postStoryboard.instantiateViewController(withIdentifier: "Post") as! PostViewController
        
        postVC.post = post
        
        navigationController?.pushViewController(postVC, animated: true)
        
    }
    
}

extension HomeViewController: ProfileDelegate {
    
    func userNameDidTouch() {
        
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        
        let profileVC = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        
        profileVC.profileType = .otherUser
        
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
}
