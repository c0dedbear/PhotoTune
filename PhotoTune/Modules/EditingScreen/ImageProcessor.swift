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
	func processed(image: UIImage, with filter: CIFilter?) -> UIImage
	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)]
	func colorControls(image: UIImage,
					   brightness: Float,
					   saturation: Float,
					   contrast: Float ) -> UIImage
}

final class ImageProcessor
{
	private let context = CIContext()

	private func changedUIImageFromContext(image: UIImage, filter: CIFilter) -> UIImage {
		guard let ciImage = CIImage(image: image) else { return image }
		filter.setValue(ciImage, forKey: kCIInputImageKey)
		guard let result = filter.outputImage else { return image }
		guard let cgImage = context.createCGImage(result, from: result.extent) else { return image }

		return UIImage(cgImage: cgImage)
	}
}

extension ImageProcessor: IImageProcessor
{
	func colorControls(image: UIImage, brightness: Float, saturation: Float, contrast: Float) -> UIImage {
		guard let filter = CIFilter(name: "CIColorControls") else { return image }
		filter.setValue(brightness, forKey: kCIInputBrightnessKey) // default 0.0
		filter.setValue(saturation, forKey: kCIInputSaturationKey) // default 1.0
		filter.setValue(contrast, forKey: kCIInputContrastKey) // default 1.0

		return changedUIImageFromContext(image: image, filter: filter)
	}

	func processed(image: UIImage, with filter: CIFilter?) -> UIImage {
		guard let filter = filter else { return image }
		return changedUIImageFromContext(image: image, filter: filter)
	}

	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)] {
		var previews = [(title: String, image: UIImage?)]()
		for index in 0..<Filter.all.count {
			let preview = Filter.all[index]
			let image = processed(image: image, with: preview.filter)
			previews.append((preview.title, image))
		}
		return previews
	}
}
