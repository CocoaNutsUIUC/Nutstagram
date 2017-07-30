//
//  Post.swift
//  Nutstagram
//
//  Created by Jared Franzone on 7/30/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import Foundation
import UIKit

struct User {
    
    
    
    // MARK: Properties
    
    let name: String
    let emojiProfilePic: String
    var nameWithPic: String {
        // "🕵🏼 Jared Franzone"
        return "\(emojiProfilePic) \(name)"
    }
}

struct Post {
    
    
    
    // MARK: Properties
    
    public let author: User
    public let image: UIImage
    public var numLikes: Int
    public let comments: [String]
    
    private(set) public var isLiked: Bool // read-only property
    
    
    
    // MARK: Initializer
    
    init(author: User, image: UIImage, numLikes: Int, comments: [String]) {
        self.author = author
        self.image = image
        self.numLikes = numLikes
        self.comments = comments
        self.isLiked = false
    }
    
    
    
    // MARK: Methods
    
    mutating func like() {
        self.isLiked = true
        self.numLikes += 1
    }
    
    mutating func unLike() {
        self.isLiked = false
        self.numLikes -= 1
    }
    
}
