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
	var tuneSettings: TuneSettings? { get set }
	var tunedImage: UIImage? { get set }

	func processed(image: UIImage, with filter: CIFilter?) -> UIImage?
	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)]
}

final class ImageProcessor
{
	var currentImage: UIImage?

	var tuneSettings: TuneSettings? {
		didSet { appleTuneSettings() }
	}
	var tunedImage: UIImage?

	private let context = CIContext()

	private func changedUIImageFromContext(ciImage: CIImage?, filter: CIFilter) -> CIImage? {
		guard let ciInput = ciImage else { return nil }
		filter.setValue(ciInput, forKey: kCIInputImageKey)
		return filter.outputImage
	}

	private func appleTuneSettings() {
		let ciInput: CIImage
		guard let image = currentImage else { return }
		if let ciContext = image.ciImage {
			ciInput = ciContext
		}
		else {
			guard let ciImage = CIImage(image: image) else  { return }
			ciInput = ciImage
		}

		guard let colorFilter = CIFilter(name: "CIColorControls") else { return }
		colorFilter.setValue(ciInput, forKey: kCIInputImageKey)
		colorFilter.setValue(tuneSettings?.brightnessIntensity, forKey: kCIInputBrightnessKey)
		colorFilter.setValue(tuneSettings?.saturationIntensity, forKey: kCIInputSaturationKey)
		colorFilter.setValue(tuneSettings?.contrastIntensity, forKey: kCIInputContrastKey)

		let coloredImage = changedUIImageFromContext(ciImage: colorFilter.outputImage, filter: colorFilter)

		guard let vignetteFilter = CIFilter(name: "CIVignette") else { return }
		vignetteFilter.setValue(tuneSettings?.vignetteIntensity, forKey: kCIInputIntensityKey)
		vignetteFilter.setValue(tuneSettings?.vignetteRadius, forKey: kCIInputRadiusKey)

		guard let ciOutput = changedUIImageFromContext(ciImage: coloredImage, filter: vignetteFilter) else { return }

		tunedImage = UIImage(ciImage: ciOutput)
	}
}

extension ImageProcessor: IImageProcessor
{
	func processed(image: UIImage, with filter: CIFilter?) -> UIImage? {
		guard let filter = filter else { return image }
		let ciInput = CIImage(image: image)
		guard let ciOutput = changedUIImageFromContext(ciImage: ciInput, filter: filter) else { return nil }
		return UIImage(ciImage: ciOutput)
	}

	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)] {
		var previews = [(title: String, image: UIImage?)]()
		for index in 0..<Filters.all.count {
			let preview = Filters.all[index]
			let image = processed(image: image, with: preview.filter)
			previews.append((preview.title, image))
		}
		return previews
	}
}
