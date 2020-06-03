//
//  FeedTableViewCell.swift
//  InstagramApp
//
//  Created by Gwinyai on 18/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

import  FirebaseDatabase

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userNameTitleButton: UIButton!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var postCommentLabel: UILabel!
    
    @IBOutlet weak var commentCountButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var likesButton: UIButton!
    
    var post: Post?
    
    var postModel: PostModel?
    
    var likesModel: LikesModel?
    
    var currentUser: UserModel?
    
    var userRef: DatabaseReference? {
        
        willSet {
            
            resetUser()
            
        }
        
        didSet {
            
            userRef?.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                
                guard let strongSelf = self else {return}
                
                if let user = UserModel(snapshot) {
                    
                    strongSelf.currentUser = user
                    
                    DispatchQueue.main.async {//单线程获取数据
                        
                        strongSelf.setup(user: user)
                        
                    }
                    
                    
                    
                }
                
            })
            
        }
        
    }
    
    var likesRef: DatabaseReference? {
        
        willSet {
            
            resetLikes()
            
        }
        
        didSet {
            
            likesRef?.observeSingleEvent(of: .value, with: { [weak self](snapshot) in
                
                guard let strongSelf = self else { return }
                
                let likesModel = LikesModel(snapshot)//初始化likes数据
                
                strongSelf.likesModel = likesModel //赋值
                
                DispatchQueue.main.async { //update in the main thread
                    
                    strongSelf.setup(likes: likesModel)
                    
                }
                
            })
            
        }
        
    }
    
    weak var feedDelegate: FeedDataDelegate?
    
    weak var profileDelegate: ProfileDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        profileImage.layer.masksToBounds = true
        
        selectionStyle = UITableViewCell.SelectionStyle.none
        
        likesButton.setImage(UIImage(named: "did_like"), for: .selected)
        
        likesButton.setImage(UIImage(named: "like_icon"), for: .normal)
        
    }
    
    func resetLikes() {
        
        likesButton.isSelected = false
        
        likesCountLabel.text = "0 likes"
        
    }
    
    func resetUser(){
        
        userNameTitleButton.setTitle("--", for: .normal)//初始值--
        
        profileImage.image = nil
        
    }
    
    func setup(likes: LikesModel?) {
        
        guard let likes = likes else { return }
        
        likesCountLabel.text = "\(likes.likesCount) likes"
        
        if likes.postDidLike {
            
            likesButton.isSelected = true
            
        } else  {
            
            likesButton.isSelected = false
            
        }
        
    }
    
    func setup(user: UserModel){
        
        userNameTitleButton.setTitle(user.username, for: .normal)
        
        if let userProfileImage = user.profileImage {
            
            profileImage.sd_cancelCurrentImageLoad()
            
            profileImage.sd_setImage(with: userProfileImage, completed: nil)
            
        }
        
    }
    
    @IBAction func viewCommentsButtonDidTouch(_ sender: Any) {
        
        guard let post = post else { return }
        
        feedDelegate?.commentsDidTouch(post: post)
        
    }
    
    @IBAction func userNameButtonDidTouch(_ sender: Any) {
        
        profileDelegate?.userNameDidTouch()
        
    }
    
    @IBAction func likeButtonDidTouch(_ sender: Any) {
        
        guard let postModel = postModel else { return }
        
        guard let likesModel = likesModel else { return }
        //取反
        likesModel.postDidLike = !likesModel.postDidLike
        
        likesButton.isSelected = likesModel.postDidLike
        
        if likesModel.postDidLike {
            
            LikesModel.postLiked(postModel.key)
            
            likesModel.likesCount += 1
            
        } else {
            
            LikesModel.postUnliked(postModel.key)
            
            if likesModel.likesCount > 0{
            
                likesModel.likesCount -= 1
                
            }
            
        }
        
        likesCountLabel.text = "\(likesModel.likesCount) likes"
        
    }
    
    @IBAction func commentButtonDidTouch(_ sender: Any) {
        
        guard let post = post else { return }
        
        feedDelegate?.commentsDidTouch(post: post)
        
    }
    
}
