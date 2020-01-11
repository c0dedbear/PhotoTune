//
//  Repository.swift
//  PhotoTune
//
//  Created by MacBook Air on 19.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IRepository
{
	func getEditedImages() -> [EditedImage]
	func updateEditedImages(_ editedImages: [EditedImage])
	func loadPreviewFor(editedImage: EditedImage) -> UIImage?
}

final class Repository
{
	private var editedImages: [EditedImage]?
	private let storageService: IStorageService

	init(storageService: IStorageService) {
		self.storageService = storageService
	}
}

extension Repository: IRepository
{
	func getEditedImages() -> [EditedImage] {
		if let storedImages = storageService.loadEditedImages() {
			return storedImages
		}
		return [EditedImage]()
	}

	func updateEditedImages(_ editedImages: [EditedImage]) {
		if let storedImages = storageService.loadEditedImages() {
			//search for deleted images
			for (index, storedEditedImage) in storedImages.enumerated() {
				if storedImages.contains(editedImages[index]) == false {
					if storedEditedImage.imageFileName != editedImages[index].imageFileName {
					storageService.removeFilesAt(filepaths:
						[storedEditedImage.imageFileName, storedEditedImage.previewFileName], completion: nil)
					}
				}
			}
		}
		storageService.saveEditedImages(editedImages)
	}

	func loadPreviewFor(editedImage: EditedImage) -> UIImage? {
		var image: UIImage?
		storageService.loadImage(filename: editedImage.previewFileName) { storedPreview in
			if let preview = storedPreview {
				image = preview
			}
		}
		return image
	}
}
