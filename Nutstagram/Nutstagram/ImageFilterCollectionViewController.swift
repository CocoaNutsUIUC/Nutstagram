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
    var postId: Int!
	
	let displayedFilterCategories = [
		kCICategoryColorEffect,
		kCICategoryStylize
	]
	var chooseableFilters: [String] = ["No Filter"]
	
	let filterQueue = OperationQueue()
	var filterJobs = [IndexPath : Operation]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Get the list of available filters
		for filterCategory in displayedFilterCategories {
			chooseableFilters += CIFilter.filterNames(inCategory: filterCategory)
		}
		
		// Set up our filter work queue
		filterQueue.qualityOfService = .userInitiated
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
			// Create a dummy filter job to simplify things elsewhere
			let filterJob = BlockOperation() {
				// Do nothing
			}
			filterJobs[indexPath] = filterJob
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
			let filterJob = BlockOperation() {
				guard let outputImage = filter.outputImage else {
					print("Unable to apply filter \(filterName) to the image")
					return
				}
				let uiImage = UIImage(ciImage: outputImage)
				DispatchQueue.main.async {
					cell.displayedImageView.image = uiImage
				}
			}
			filterJobs[indexPath] = filterJob
		}
		
        return cell
    }

    // MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let filterJob = filterJobs[indexPath]!
		filterQueue.addOperation(filterJob)
	}
	
	override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let filterJob = filterJobs[indexPath]!
		if filterJob.isExecuting {
			filterJob.cancel()
		}
	}

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
