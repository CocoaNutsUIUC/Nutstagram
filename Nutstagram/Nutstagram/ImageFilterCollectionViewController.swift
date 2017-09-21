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
	
	/// The original image to which we will apply filters
	var unmodifiedImage: UIImage!
    var postId: Int!
	
	let displayedFilterCategories = [
//		kCICategoryColorEffect,
		kCICategoryStylize,
	]
	/// These filters require two images to operate properly, so we don't use them.
	let excludedFilters = [
		"CIBlendWithAlphaMask",
		"CIBlendWithMask",
		"CIColorMap",
		"CIShadedMaterial",
	]
	
	/// The filters that will actually be shown.
	var chooseableFilters: [String] = ["No Filter"]
	
	fileprivate let filterQueue = OperationQueue()
	fileprivate var filterJobs = [IndexPath : Operation]()
	fileprivate var resizeUnmodifiedImageJob: BlockOperation!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Get the list of available filters
		for filterCategory in displayedFilterCategories {
			chooseableFilters += CIFilter.filterNames(inCategory: filterCategory)
		}
		// Remove any filters in our excludes list
		chooseableFilters = chooseableFilters.filter { !excludedFilters.contains($0) }
		
		// Set up our filter work queue
		filterQueue.name = "Image filter queue"
		filterQueue.qualityOfService = .userInitiated
		
		// Resize our original image
		resizeUnmodifiedImageJob = BlockOperation {
			guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
				return
			}
			let cellSize = layout.itemSize
			self.unmodifiedImage = resize(image: self.unmodifiedImage, toFill: cellSize)
		}
		filterQueue.addOperation(resizeUnmodifiedImageJob)
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
		
		let filterJob: BlockOperation // We'll fill this in later
		
		// Configure the cell
		if indexPath.row == 0 {
			// The first filter is always no filter
			cell.label.text = "No Filter"
			cell.displayedImageView.image = unmodifiedImage;
			// Create a dummy filter job to simplify things elsewhere
			filterJob = BlockOperation() {
				// Do nothing
			}
		} else {
			// Apply a Core Image filter
			let filterName = chooseableFilters[indexPath.row]
			cell.label.text = CIFilter.localizedName(forFilterName: filterName)
			// Apply the filter
			filterJob = BlockOperation() {
				// Give it an input image
				let inputParams = [kCIInputImageKey: CIImage(cgImage: self.unmodifiedImage.cgImage!)]
				guard let filter = CIFilter(name: filterName, withInputParameters: inputParams) else {
					print("Unknown filter: \(filterName)")
					return
				}
				guard let outputImage = filter.outputImage else {
					print("Unable to apply filter \(filterName) to the image")
					return
				}
				let uiImage = UIImage(ciImage: outputImage)
				DispatchQueue.main.async {
					cell.displayedImageView.image = uiImage
				}
			}
		}
		
		filterJob.addDependency(resizeUnmodifiedImageJob)
		filterJobs[indexPath] = filterJob
		
        return cell
    }

    // MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let filterJob = filterJobs[indexPath]!
		if !filterJob.isExecuting && !filterJob.isFinished {
			filterQueue.addOperation(filterJob)
		}
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
