//
//  NutstagramTableViewController.swift
//  Nutstagram
//
//  Created by Jared Franzone on 7/30/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import UIKit

class NutstagramTableViewController: UIViewController {

    // MARK: IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var posts = [Post]()
    
    // database id's of posts in the `posts` array
    var postIds = [Int]()
    
    // these dictionaries map a posts "like" button and "view all comments" button and "write comment" button to the `posts` array
    var commentsButtonPostLink = [Int:Int]()
    var addCommentButtonPostLink = [Int:Int]()
	var filterButtonPostLink = [Int:Int]()
    var postForButton = [Int:Int]()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup refresh control
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(NutstagramTableViewController.refreshPosts(sender:)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        
        // load data from server
        loadServerData()
    }
    
    // MARK: IB Actions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        
        // get index of cell the button tapped was in
        if let index = postForButton[sender.hash] {
            
            // get the post and cell
            var post = posts[index]
            let postId = postIds[index]
            
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NutstagramTableViewCell else {
                return
            }
            
            // make needed updates to model and UI
            if post.isLiked {
                post.unLike()
                sender.setImage(#imageLiteral(resourceName: "default"), for: .normal)
                cell.numLikesLabel.text = "\(post.numLikes) \(post.numLikes == 1 ? "like" : "likes")"
                
                // send request to server
                unlikePost(withId: postId)
            } else {
                post.like()
                sender.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                cell.numLikesLabel.text = "\(post.numLikes) \((post.numLikes) == 1 ? "like" : "likes")"
                
                // send request to server
                likePost(withId: postId)
            }
            
            // save the post back in the array -- NEEDED because we are using a Struct (value type) for Posts.
            posts[index] = post
        }
        
    }
	
	@IBAction func changeFilterButtonTapped(_ sender: UIButton) {
		// Show the UI to select a new filter
		self.performSegue(withIdentifier: "showFilterPicker", sender: sender)
	}
	
    // MARK: Private Helper methods
    
    fileprivate func loadServerData() {
        if let url = URL(string: "http://nutstagramapi-env-2.j3tcbpybxd.us-east-1.elasticbeanstalk.com/posts") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            send(urlRequest: request, delegate: self)

        }
    }
    
    private func likePost(withId postId: Int) {
        if let url = URL(string: "http://nutstagramapi-env-2.j3tcbpybxd.us-east-1.elasticbeanstalk.com/\(postId)") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            send(urlRequest: request, delegate: nil)
        }
    }
    
    private func unlikePost(withId postId: Int) {
        if let url = URL(string: "http://nutstagramapi-env-2.j3tcbpybxd.us-east-1.elasticbeanstalk.com/\(postId)") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            send(urlRequest: request, delegate: nil)
        }
    }
    
    fileprivate func send(urlRequest: URLRequest, delegate: URLSessionDataDelegate?) {
        let defaultSession = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let dataTask = defaultSession.dataTask(with: urlRequest)
        dataTask.resume()
    }
    
    fileprivate func resize(image: UIImage) -> UIImage {
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
        loadServerData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: Navigation
    
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
        
        if segue.identifier == "addComment" {
            if let vc = segue.destination as? AddCommentViewController {
                if let button = sender as? UIButton {
                    if let row = addCommentButtonPostLink[button.hash] {
                        vc.postId = postIds[row]
                        vc.row = row
                        vc.delegate = self
                    }
                }
            }
        }
		
		if segue.identifier == "showFilterPicker" {
			if let vc = segue.destination as? ImageFilterCollectionViewController {
				if let button = sender as? UIButton {
					if let row = filterButtonPostLink[button.hash] {
						let post = posts[row]
                        let postId = postIds[row]
						vc.unmodifiedImage = post.image
                        vc.postId = postId
					}
				}
			}
		}
    }
}

// MARK: - AddCommentViewControllerDelegate extension

extension NutstagramTableViewController: AddCommentViewControllerDelegate {
    func addComment(_ comment: String, postId: Int, row: Int) {
        if let url = URL(string: "http://nutstagramapi-env-2.j3tcbpybxd.us-east-1.elasticbeanstalk.com/comment/\(postId)") {
            var request = URLRequest(url: url)
            let dictionary = ["text": comment]
            let httpBody = try! JSONSerialization.data(withJSONObject: dictionary, options: [])

            request.httpMethod = "POST"
            request.httpBody = httpBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            send(urlRequest: request, delegate: nil)
            posts[row].comments.append(comment)
            tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
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
        
        configure(cell: cell, at: indexPath, with: posts[indexPath.row])
        
        commentsButtonPostLink[cell.viewAllCommentsButton.hash] = indexPath.row
        addCommentButtonPostLink[cell.addCommentButton.hash] = indexPath.row
        postForButton[cell.likeButton.hash] = indexPath.row
        filterButtonPostLink[cell.changeFilterButton.hash] = indexPath.row
        
        return cell
    }
    
    private func configure(cell: NutstagramTableViewCell, at indexPath: IndexPath, with post: Post) {
        cell.userNameLabel.text = post.author.nameWithPic
        if let image = post.image {
            cell.postImageView.image = self.resize(image: image)
        } else {
            loadImage(from: post.imageURL, for: cell, at: indexPath)
        }
        
        (post.isLiked) ? cell.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal) : cell.likeButton.setImage(#imageLiteral(resourceName: "default"), for: .normal)
        cell.numLikesLabel.text = "\(post.numLikes) \(post.numLikes == 1 ? "like" : "likes")"
        cell.userCommentLabel.text = post.comments.first
        cell.viewAllCommentsButton.setTitle("View all \(post.comments.count) comments", for: .normal)
    }
    
    private func loadImage(from url: URL, for cell: NutstagramTableViewCell, at indexPath: IndexPath) {
        DispatchQueue(label: "LoadImage").async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            guard let image = UIImage(data: imageData) else { return }
            
            DispatchQueue.main.async {
                self.posts[indexPath.row].image = image
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

// MARK: - URLSessionDataDelegate extension

extension NutstagramTableViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        // convert data to json object
        let postsJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        
        // cast json object to array of posts, each post represented by a dictionary
        guard let postsInfo = postsJSON as? [[String: Any]] else {
            return
        }
        
        var posts = [Post]()
        var postIds = [Int]()
        
        // convert json dictionaries into model data structures
        postsInfo.forEach { (postInfo) in
            guard let postId = postInfo["id"] as? Int else { return }
            postIds.append(postId)
            
            guard let imageURLString = postInfo["image_url"] as? String else { return }
            guard let numLikes = postInfo["num_likes"] as? Int else { return }
            
            guard let userInfo = postInfo["user"] as? [String: Any] else { return }
            guard let commentsInfo = postInfo["comments"] as? [[String: Any]] else { return }
            
            guard let userName = userInfo["name"] as? String else { return }
            guard let userEmojiProfilePic = userInfo["emoji_profile_pic"] as? String else { return }
            
            var comments = [String]()
            
            for commentInfo in commentsInfo {
                guard let text = commentInfo["text"] as? String else { return }
                comments.append(text)
            }
            
            guard let imageURL = URL(string: imageURLString) else { return }
                        
            let user = User(name: userName, emojiProfilePic: userEmojiProfilePic)
            let post = Post(author: user, imageURL: imageURL, numLikes: numLikes, comments: comments)
            
            posts.append(post)
        }
        
        // update locally stored posts
        self.posts = posts
        self.postIds = postIds
        
        // reload table view
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
