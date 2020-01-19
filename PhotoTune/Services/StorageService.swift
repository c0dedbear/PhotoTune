//
//  StorageService.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 07.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IStorageService
{
	func storeImage(_ image: UIImage, filename: String, completion: (() -> Void)?)
	func loadImage(filename: String, completion: (UIImage?) -> Void)
	func removeFilesAt(filepaths: [String], completion: (() -> Void)?)
	func saveEditedImages(_ editedImages: [EditedImage])
	func loadEditedImages() -> [EditedImage]?
}

final class StorageService
{
	private var archiveURL: URL {
		getDocumentsDirectory()
			.appendingPathComponent("editedImages")
			.appendingPathExtension("plist")
	}

	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
}

extension StorageService: IStorageService
{
	func removeFilesAt(filepaths: [String], completion: (() -> Void)?) {
		for filepath in filepaths {
			let fileURL = getDocumentsDirectory().appendingPathComponent(filepath)
			do {
				try FileManager.default.removeItem(at: fileURL)
			}
			catch {
				assertionFailure(error.localizedDescription)
			}
		}
		completion?()
	}

	func storeImage(_ image: UIImage, filename: String, completion: (() -> Void)?) {
		if let data = image.jpegData(compressionQuality: 1) {
			let filePath = getDocumentsDirectory().appendingPathComponent(filename)
			do {
				try data.write(to: filePath)
				completion?()
			}
			catch {
				assertionFailure(error.localizedDescription)
			}
		}
	}

	func loadImage(filename: String, completion: (UIImage?) -> Void) {
		let filePath = getDocumentsDirectory().appendingPathComponent(filename)

		if let data = try? Data(contentsOf: filePath) {
			if let image = UIImage(data: data) {
				completion(image)
			}
			else {
				completion(nil)
				assertionFailure("No image on the url: \(filePath)")
			}
		}
	}

	func saveEditedImages(_ editedImages: [EditedImage]) {
		let encoder = PropertyListEncoder()
		guard let encodedCars = try? encoder.encode(editedImages) else { return }
		do {
			try encodedCars.write(to: archiveURL, options: .noFileProtection)
		}
		catch {
			assertionFailure(error.localizedDescription)
		}
	}

	func loadEditedImages() -> [EditedImage]? {
		guard let data = try? Data(contentsOf: archiveURL) else { return nil }
		let decoder = PropertyListDecoder()
		let images = try? decoder.decode([EditedImage].self, from: data)
		return images
	}
}
