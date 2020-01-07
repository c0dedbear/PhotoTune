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
	func storeImage(_ image: UIImage, with id: String)
	func loadImage(id: String, completion: (UIImage?) -> Void)
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
	func storeImage(_ image: UIImage, with id: String) {
		if let data = image.pngData() {
			let filePath = getDocumentsDirectory().appendingPathComponent(id)
			do {
				try data.write(to: filePath)
			}
			catch {
				assertionFailure(error.localizedDescription)
			}
		}
	}

	func loadImage(id: String, completion: (UIImage?) -> Void) {
		let filePath = getDocumentsDirectory().appendingPathComponent(id)

		if let data = try? Data(contentsOf: filePath) {
			if let image = UIImage(data: data) {
				completion(image)
			}
			else {
				assertionFailure("No image on the url: \(filePath)")
				completion(nil)
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
		return try? decoder.decode([EditedImage].self, from: data)
	}
}
