//
//  ImageFilterCollectionViewController.swift
//  Nutstagram
//
//  Created by Justin Loew on 9/20/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import CoreImage
import UIKit

private let reuseIdentifier = "filterCell"

class ImageFilterCollectionViewController: UICollectionViewController {
	
	var unmodifiedImage: UIImage!
	
	let displayedFilterCategories = [
		kCICategoryColorEffect,
		kCICategoryStylize
	]
	var chooseableFilters: [String] = ["No Filter"]
    var postId: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(ImageFilterCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
		// Get the list of available filters
		for filterCategory in displayedFilterCategories {
			chooseableFilters += CIFilter.filterNames(inCategory: filterCategory)
		}
    }
	
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chooseableFilters.count // First cell is always no filter
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageFilterCollectionViewCell
    
        // Configure the cell
		if indexPath.row == 0 {
			// The first filter is always no filter
			cell.label.text = "No Filter"
			cell.displayedImageView.image = unmodifiedImage;
		} else {
			// Apply a Core Image filter
			let filterName = chooseableFilters[indexPath.row]
			// Give it an input image
			let inputParams = [kCIInputImageKey: CIImage(cgImage: unmodifiedImage.cgImage!)]
			guard let filter = CIFilter(name: filterName, withInputParameters: inputParams) else {
				print("Unknown filter: \(filterName)")
				return cell
			}
			cell.label.text = CIFilter.localizedName(forFilterName: filterName)
			// Apply the filter
			guard let outputImage = filter.outputImage else {
				print("Unable to apply filter \(filterName) to the image")
				return cell
			}
			cell.displayedImageView.image = UIImage(ciImage: outputImage)
		}
		
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
