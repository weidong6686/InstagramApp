//
//  Protocols.swift
//  InstagramApp
//
//  Created by Gwinyai on 18/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

protocol FeedDataDelegate: class {
    
    func commentsDidTouch(post: Post)
    
}

protocol ProfileDelegate: class {
    
    func userNameDidTouch()
    
}

protocol ActivityDelegate: class {
    
    func scrollTo(index: Int)
    
    func activityDidTouch()
    
}

protocol ProfileHeaderDelegate: class {
    
    func profileImageDidTouch()
    
}
