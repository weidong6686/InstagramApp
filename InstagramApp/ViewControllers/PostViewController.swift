//
//  PostViewController.swift
//  InstagramApp
//
//  Created by Gwinyai on 17/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var post: Post!
    
    var commentTextViewIsActive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = CGFloat(88.0)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
        
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        commentTextView.delegate = self
        
        title = "Post"
        
        commentTextView.font = UIFont(name: "Roboto-Regular", size: 15)
        
        commentTextView.inputAccessoryView = nil
        
        commentTextView.inputView = nil
        
    }
    
    @objc func dismissKeyboard() {
        
        if commentTextViewIsActive {
            
            view.endEditing(true)
            
        }
        
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        let rect:CGRect = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        
        let duration = ((notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        self.keyboardConstraint.constant = rect.height - (self.tabBarController?.tabBar.frame.size.height ?? 49.0)
        
        UIView.animate(withDuration: duration!, animations: {
            
            self.view.layoutSubviews()
            
        })
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        let duration = ((notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        self.keyboardConstraint.constant = 0
        
        UIView.animate(withDuration: duration!, animations: {
            
            self.view.layoutSubviews()
            
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
            
        }
        else {
            
            return post.comments.count
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            return
            
        }
        
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        
        let profileVC = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        
        profileVC.profileType = .otherUser
        
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
            
            cell.profileImage.image = post.user.profileImage
            
            cell.postImage.image = post.postImage
            
            cell.dateLabel.text = post.datePosted
            
            cell.likesCountLabel.text = "\(post.likesCount) likes"
            
            cell.postCommentLabel.text = post.postComment
            
            cell.userNameTitleButton.setTitle(post.user.name, for: .normal)
            
            cell.profileDelegate = self
            
            cell.feedDelegate = self
            
            return cell
            
        }
        
        let comment = post.comments[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
        
        cell.commentLabel.text = comment.details
        
        cell.commentIndex = indexPath.row
        
        //cell.delegate = self
        
        let commentUserName: String = comment.user.name
        
        let commentDetails: String = comment.details
        
        let commentAttributedString = NSMutableAttributedString(string: " \(commentDetails)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        let nameString = NSMutableAttributedString(string: commentUserName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        
        nameString.append(commentAttributedString)
        
        cell.commentLabel.attributedText = nameString
        
        return cell
        
    }
    
    @IBAction func postCommentButtonDidTouch(_ sender: Any) {
    }
    
    
}

extension PostViewController: ProfileDelegate {
    
    func userNameDidTouch() {
        
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        
        let profileVC = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        
        profileVC.profileType = .otherUser
        
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
}

extension PostViewController: FeedDataDelegate {
    
    func commentsDidTouch(post: Post) {
        
        
        
    }
    
}

extension PostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        commentTextViewIsActive = true
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        commentTextViewIsActive = false
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
        
    }
    
}
