//
//  ActivityTableViewCell.swift
//  InstagramApp
//
//  Created by Gwinyai on 28/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImage.layer.masksToBounds = true
        
        selectionStyle = .none
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
    }
    
}
