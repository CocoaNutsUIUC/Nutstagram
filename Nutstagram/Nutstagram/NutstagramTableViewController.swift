//
//  NutstagramTableViewController.swift
//  Nutstagram
//
//  Created by Jared Franzone on 7/30/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import UIKit

class NutstagramTableViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var posts = [Post]()
    
    // these dictionaries map a posts "like" button and "view all comments" button to the "posts" array
    var commentsButtonPostLink = [Int:Int]()
    var postForButton = [Int:Int]()
    
    private let refreshControl = UIRefreshControl()
    
    
    
    // MARK: ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup refresh control
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(NutstagramTableViewController.refreshPosts(sender:)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        
        // load the fake data
        loadFakeData()
    }

    
    
    // MARK: IB Actions

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        
        // get index of cell the button tapped was in
        if let index = postForButton[sender.hash] {
            
            // get the post and cell
            var post = posts[index]
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NutstagramTableViewCell else {
                return
            }
            
            // make needed updates to model and UI
            if post.isLiked {
                post.unLike()
                
                sender.setImage(#imageLiteral(resourceName: "default"), for: .normal)
                cell.numLikesLabel.text = "\(post.numLikes) \(post.numLikes == 1 ? "like" : "likes")"
            } else {
                post.like()
                
                sender.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                cell.numLikesLabel.text = "\(post.numLikes) \((post.numLikes) == 1 ? "like" : "likes")"
            }
            
            // save the post back in the array -- NEEDED because we are using a Struct (value type) for Posts.
            posts[index] = post
        }
        
    }
    
    
    
    // MARK: Private Helper methods
    
    private func loadFakeData() {
        
        posts.removeAll()
        
        posts.append(
            Post(
                author:  User(name: "Jared Franzone", emojiProfilePic: "🕵🏼"),
                image: resize(image: #imageLiteral(resourceName: "lentils")),
                numLikes: 5,
                comments: ["Lentils :)", "Yum!", "Can you make those in the microwave?", "I'd rather have pizza"]
            )
        )
        posts.append(
            Post(
                author: User(name: "John Smith", emojiProfilePic: "👨🏽‍✈️"),
                image: resize(image: #imageLiteral(resourceName: "sailboats")),
                numLikes: 9,
                comments: ["Look at all the sailboats!","I see a whale", "⛵️"]
            )
        )
        posts.append(
            Post(author: User(name: "Jane Doe", emojiProfilePic: "👩🏻‍⚖️"),
                 image: resize(image: #imageLiteral(resourceName: "cave")),
                 numLikes: 22,
                 comments: ["having soo much fun in TX!", "Wow! cool cave", "Where is that place?"]
            )
        )
        
    }
    
    private func resize(image: UIImage ) -> UIImage {
        // calculate scaling ratio
        let imageWidth = image.size.width
        let screenWidth = (UIDevice.current.orientation == .portrait) ? self.view.bounds.width : self.view.bounds.height
        let ratio = Double(screenWidth) / Double(imageWidth)
        
        // resize image
        let size = image.size.applying(CGAffineTransform(scaleX: CGFloat(ratio), y: CGFloat(ratio)))
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return (scaledImage == nil) ? image : scaledImage!
    }
    
    @objc private func refreshPosts(sender: UIRefreshControl) {
        // FUTURE: Fetch data from server
        self.refreshControl.endRefreshing()
    }
    
    
    
    // MARK: Nagigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comments" {
            if let vc = segue.destination as? NutstagramCommentsTableViewController {
                if let button = sender as? UIButton {
                    if let row = commentsButtonPostLink[button.hash] {
                        vc.comments = posts[row].comments
                    }
                }
            }
        }
    }

}



// MARK: - UITableViewDelegate extension

extension NutstagramTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}



// MARK: - UITableViewDataSource extension

extension NutstagramTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NutstagramTableViewCell else {
            return NutstagramTableViewCell()
        }
        
        cell.post = posts[indexPath.row]
        
        commentsButtonPostLink[cell.viewAllCommentsButton.hash] = indexPath.row
        postForButton[cell.likeButton.hash] = indexPath.row
        
        return cell
    }
}
