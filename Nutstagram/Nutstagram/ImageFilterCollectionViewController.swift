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
	var selectedFilter = Post.noFilterName
	
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
	var choosableFilters: [String] = [Post.noFilterName]
	
	fileprivate let filterQueue = OperationQueue()
	fileprivate var filterJobs = [IndexPath : Operation]()
	fileprivate var resizeUnmodifiedImageJob: BlockOperation!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Get the list of available filters
		for filterCategory in displayedFilterCategories {
			choosableFilters += CIFilter.filterNames(inCategory: filterCategory)
		}
		// Remove any filters in our excludes list
		choosableFilters = choosableFilters.filter { !excludedFilters.contains($0) }
		choosableFilters = [
			"CIComicEffect",
			"CICrystallize",
			"CIEdges",
			"CIHexagonalPixellate",
			"CILineOverlay",
			"CIPixellate",
			"CIPointillize",
		]
		
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		collectionView?.allowsSelection
	}
	
	// MARK: IBActions
	
	@IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	@IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
		// It may look like it does the same thing as dismiss(animated:), but it doesn't!
		// We do some work to save the selection in our table view controller
		performSegue(withIdentifier: "unwindToNutstagramTVC", sender: self)
	}
	
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return choosableFilters.count // First cell is always no filter
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
			let filterName = choosableFilters[indexPath.row]
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
	
	private func setHighlighted(highlighted: Bool, ForCellAt indexPath: IndexPath) {
		let cell = collectionView?.cellForItem(at: indexPath)
		// Animate setting the background color
		UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
			if highlighted {
				cell?.backgroundColor = UIColor.blue
			} else {
				cell?.backgroundColor = UIColor.clear
			}
		}, completion: nil)
		
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
	
	override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		setHighlighted(highlighted: true, ForCellAt: indexPath)
	}
	
	override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		setHighlighted(highlighted: false, ForCellAt: indexPath)
	}

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// Update our selected filter
		selectedFilter = choosableFilters[indexPath.row]
    }

}
