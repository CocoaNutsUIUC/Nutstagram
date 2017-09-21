//
//  Post.swift
//  Nutstagram
//
//  Created by Jared Franzone on 7/30/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import Foundation
import CoreImage
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

class Post {
	
	public static let noFilterName = "no_filter"
    
    // MARK: Properties
    
    public let author: User
    public var image: UIImage?
	public var filteredImage: UIImage?
    public let imageURL: URL
    public var numLikes: Int
    public var comments: [String]
    // Add filterName to keep track of which filter is applied to the image.
    public var filterName: String
    
    private(set) public var isLiked: Bool // read-only property
    
    // MARK: Initializer
    
    init(author: User, imageURL: URL, numLikes: Int, comments: [String], filterName: String) {
        self.author = author
        self.imageURL = imageURL
        self.numLikes = numLikes
        self.comments = comments
        self.isLiked = false
        self.filterName = filterName
    }
    
    // MARK: Methods
    
    func like() {
        self.isLiked = true
        self.numLikes += 1
    }
    
    func unLike() {
        self.isLiked = false
        self.numLikes -= 1
    }
	
	func regenerateFilteredImage() {
		guard let image = image else {
			filteredImage = nil
			return
		}
		
		if filterName == Post.noFilterName {
			// That was easy!
			filteredImage = image
		} else {
			// Create our filter
			let inputParams = [kCIInputImageKey: CIImage(cgImage: image.cgImage!)]
			guard let filter = CIFilter(name: filterName, withInputParameters: inputParams) else {
				print("Unknown filter: \(filterName)")
				filteredImage = nil
				return
			}
			guard let outputImage = filter.outputImage else {
				print("Unable to apply filter \(filterName) to the image")
				filteredImage = nil
				return
			}
			// And we're done!
			filteredImage = UIImage(ciImage: outputImage)
		}
	}
}
