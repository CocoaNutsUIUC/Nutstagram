//
//  Utilities.swift
//  Nutstagram
//
//  Created by Justin Loew on 9/21/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import UIKit

func resize(image: UIImage, toFill newMinSize: CGSize) -> UIImage {
	// calculate scaling ratio
	let imageWidth = image.size.width
	let ratio = Double(newMinSize.width) / Double(imageWidth)
	
	// resize image
	let size = image.size.applying(CGAffineTransform(scaleX: CGFloat(ratio), y: CGFloat(ratio)))
	UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
	image.draw(in: CGRect(origin: .zero, size: size))
	let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	
	return (scaledImage == nil) ? image : scaledImage!
}
