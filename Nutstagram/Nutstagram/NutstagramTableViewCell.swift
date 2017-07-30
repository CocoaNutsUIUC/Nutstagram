//
//  NutstagramTableViewCell.swift
//  Nutstagram
//
//  Created by Jared Franzone on 7/30/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import UIKit

class NutstagramTableViewCell: UITableViewCell {

    
    
    // MARK: IB Outlets
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numLikesLabel: UILabel!
    @IBOutlet weak var userCommentLabel: UILabel!
    @IBOutlet weak var viewAllCommentsButton: UIButton!
    
    
    // MARL: Properties
    
    public var post: Post? {
        
        didSet {
            
            guard let post = post else {
                return
            }
            
            userNameLabel.text = post.author.nameWithPic
            postImageView.image = post.image
            (post.isLiked) ? likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal) : likeButton.setImage(#imageLiteral(resourceName: "default"), for: .normal)
            numLikesLabel.text = "\(post.numLikes) \(post.numLikes == 1 ? "like" : "likes")"
            userCommentLabel.text = post.comments.first
            viewAllCommentsButton.setTitle("View all \(post.comments.count) comments", for: .normal)
        }
        
    }

}
