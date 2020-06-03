//
//  LikeModel.swift
//  InstagramApp
//
//  Created by Dong Wei on 5/20/20.
//  Copyright © 2020 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import FirebaseDatabase

import FirebaseAuth

/*
 一般不建议3层以上的数据nested关系， 让data retrive difficult，需要flat
 Data structrue:
 likes
    postId
        userId: true
        userId: true
 */


class LikesModel {
    
    static var collection: DatabaseReference {
        
        get {
            
            return Database.database().reference().child("likes")
            
        }
        
    }
    
    
    
    var postDidLike: Bool = false
    
    var likesCount: Int = 0
    
    init?( _ snapshot: DataSnapshot) { // all posts like
        
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        
        self.likesCount = snapshot.children.allObjects.count
        
        for item in snapshot.children {
            
            guard let snapshot = item as? DataSnapshot else { continue }
            
            if snapshot.key == userId {
            
                postDidLike = true
                
                break;
            }
            
        }
        
    }
    
    static func postLiked( _ postKey: String) {
        
        if let userId = Auth.auth().currentUser?.uid {
            
            let likesRef = LikesModel.collection.child(postKey)
            
            likesRef.updateChildValues([userId: true])
            
        }
        
    }
    
    static func postUnliked( _ postKey: String) {
        
        if let userId = Auth.auth().currentUser?.uid {
            
            let likesRef = LikesModel.collection.child(postKey).child(userId)
            
            likesRef.removeValue()
            
        }
        
    }
    
    
}
