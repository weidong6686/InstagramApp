//
//  ProfileHeaderTableViewCell.swift
//  InstagramApp
//
//  Created by Gwinyai on 20/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class ProfileHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    
    @IBOutlet weak var numberOfFollowingLabel: UILabel!
    
    var profileType: ProfileType = .personal
    
    weak var delegate: ProfileHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileButton.layer.borderWidth = CGFloat(0.5)
        
        profileButton.layer.borderColor = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0).cgColor
        
        profileButton.layer.cornerRadius = CGFloat(3.0)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageDidTouch))
        
        profileImageView.addGestureRecognizer(tapRecognizer)
        
        profileImageView.isUserInteractionEnabled = true
        
        profileImageView.clipsToBounds = true
        
    }
    
    override func layoutSubviews() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        
    }
    
    @IBAction func profileActionButtonDidTouch(_ sender: Any) {
        
        switch profileType {
            
        case .personal:
            
            logout()
            
        case .otherUser:
            
            follow()
            
        }
        
    }
    
    @objc func profileImageDidTouch(){
        
        delegate?.profileImageDidTouch()
        
    }
    
    func logout() {
        
        Helper.logout()
        
    }
    
    func follow() {
        
        print("follow")
        
    }
    
}
