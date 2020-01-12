//
//  StorageRepository.swift
//  PhotoTune
//
//  Created by MacBook Air on 19.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IStorageRepository
{
	func getEditedImages() -> [EditedImage]
	func updateEditedImages(_ editedImages: [EditedImage])
	func loadPreviewFor(editedImage: EditedImage) -> UIImage?
	func removeAllEditedImages(except: [EditedImage])
}

final class StorageRepository
{
	private var editedImages: [EditedImage]?
	private let storageService: IStorageService

	init(storageService: IStorageService) {
		self.storageService = storageService
	}
}

extension StorageRepository: IStorageRepository
{
	func getEditedImages() -> [EditedImage] {
		if let storedImages = storageService.loadEditedImages() {
			return storedImages
		}
		return [EditedImage]()
	}

	func updateEditedImages(_ editedImages: [EditedImage]) {
		if let storedImages = storageService.loadEditedImages() {
			for (index, storedEditedImage) in storedImages.enumerated() {
				guard index < editedImages.count else { continue }
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

	func removeAllEditedImages(except: [EditedImage]) {
		var deletionPaths = [String]()
		guard let storedImages = storageService.loadEditedImages() else { return }
		for storedImage in storedImages {
			if except.contains(storedImage) == false {
				deletionPaths.append(storedImage.imageFileName)
				deletionPaths.append(storedImage.previewFileName)
			}
		}
		storageService.removeFilesAt(filepaths: deletionPaths) { [weak self] in
			self?.storageService.saveEditedImages(except)
		}
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
