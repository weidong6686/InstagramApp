//
//  UserData.swift
//  InstagramApp
//
//

import Foundation

import UIKit

import  FirebaseDatabase

import FirebaseAuth

import FirebaseStorage

struct User {
    
    var name: String
    
    var profileImage: UIImage
    
}

class UsersModel {
    
    var users: [User] = [User]()
    
    init() {
        
        let user1 = User(name: "John Carmack", profileImage: UIImage(named: "user1")!)
        
        users.append(user1)
        
        let user2 = User(name: "Bjarne Stroustrup", profileImage: UIImage(named: "user2")!)
        
        users.append(user2)
        
    }
    
    
}

class UserModel {
    
    static var collection: DatabaseReference {
    
        get {
            
            return Database.database().reference().child("users")
            
        }
        
    }
    
    static var personalFeed: DatabaseReference {
        
        get {
            
            return Database.database().reference().child("user_posts")
            
        }
        
    }
    
    var username:String = ""
    
    var bio:String = ""
    
    var profileImage: URL?
    
    init?(_ snapshot: DataSnapshot){
        
        guard let value = snapshot.value as? [String: Any] else {return}
        
        self.username = value["username"] as? String ?? ""
        
        self.bio = value["bio"] as? String ?? ""
        
        if let profileImage = value["profile_image"] as? String {
            
            self.profileImage = URL(string: profileImage)
            
        }
        
        
    }
    
}
