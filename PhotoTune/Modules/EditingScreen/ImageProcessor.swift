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
	var currentImage: UIImage? { get set }
	var tunedImage: UIImage? { get set }

	func processed(image: UIImage, with filter: CIFilter?) -> UIImage?
	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)]

	func brightnessControl(value: Float)
	func contrastControl(value: Float)
	func saturationControl(value: Float)
}

final class ImageProcessor
{
	var currentImage: UIImage?

	var tunedImage: UIImage?

	private let context = CIContext()

	private func changedUIImageFromContext(image: UIImage?, filter: CIFilter) -> UIImage? {
		guard let image = image else { return nil }
		guard let ciImage = CIImage(image: image) else { return nil }
		filter.setValue(ciImage, forKey: kCIInputImageKey)
		guard let result = filter.outputImage else { return nil }
		guard let cgImage = context.createCGImage(result, from: result.extent) else { return image }

		return UIImage(cgImage: cgImage)
	}

	private func colorControls(brightness: Float?, saturation: Float?, contrast: Float?) {
		guard let filter = CIFilter(name: "CIColorControls") else { return }

		if let brightness = brightness {
			filter.setValue(brightness, forKey: kCIInputBrightnessKey) // default 0.0
		}
		if let saturation = saturation {
			filter.setValue(saturation, forKey: kCIInputSaturationKey) // default 1.0
		}
		if let contrast = contrast {
			filter.setValue(contrast, forKey: kCIInputContrastKey) // default 1.0
		}

		tunedImage = changedUIImageFromContext(image: currentImage, filter: filter)
	}
}

extension ImageProcessor: IImageProcessor
{

	func brightnessControl(value: Float) {
		colorControls(brightness: value, saturation: nil, contrast: nil)
	}

	func contrastControl(value: Float) {
		colorControls(brightness: nil, saturation: nil, contrast: value)
	}

	func saturationControl(value: Float) {
		colorControls(brightness: nil, saturation: value, contrast: nil)
	}

	func processed(image: UIImage, with filter: CIFilter?) -> UIImage? {
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
