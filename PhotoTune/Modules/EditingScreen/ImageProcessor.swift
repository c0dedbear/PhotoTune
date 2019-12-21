//
//  ImageProcessor.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 20.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation
import CoreImage
import UIKit

protocol IImageProcessor
{
	var filtersCount: Int { get }

	func processed(image: UIImage, with filter: String) -> UIImage
	func filtersPreviews(image: UIImage) -> [UIImage]
	func filterTitleFor(index: Int) -> String
	func filterFor(index: Int) -> String
}

final class ImageProcessor
{
	private let context = CIContext()

	private let filters = [
		"", "CIPhotoEffectMono",
		"CISepiaTone", "CIPhotoEffectNoir",
		"CIPhotoEffectTransfer", "CIPhotoEffectChrome",
		"CIPhotoEffectProcess", "CIPhotoEffectFade",
		"CIPhotoEffectInstant", "CIColorMonochrome",
		]

	private let filtersTitles = [
		"Normal", "B & W",
		"Sepia", "Noir",
		"Transfer", "Chrome",
		"Pro", "Fade",
		"Instant", "Mono",
	]
}

extension ImageProcessor: IImageProcessor
{
	var filtersCount: Int { filters.count }

	func filterTitleFor(index: Int) -> String { filtersTitles[index] }
	func filterFor(index: Int) -> String { filters[index] }

	func processed(image: UIImage, with filter: String) -> UIImage {
		guard let filter = CIFilter(name: filter) else { return image }
		guard let ciImage = CIImage(image: image) else { return  image }
		filter.setValue(ciImage, forKey: kCIInputImageKey)
		guard let result = filter.outputImage else { return image }
		guard let cgImage = context.createCGImage(result, from: result.extent) else { return image }
		return UIImage(cgImage: cgImage)
	}

	func filtersPreviews(image: UIImage) -> [UIImage] {
		var previews = [UIImage]()
		for filter in filters {
			let image = processed(image: image, with: filter)
			previews.append(image)
		}
		return previews
	}
}
