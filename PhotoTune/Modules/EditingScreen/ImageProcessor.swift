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

	func filteredImage(image: UIImage, with filter: CIFilter?) -> UIImage?
	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)]
}

final class ImageProcessor
{
	var currentImage: UIImage?

	var tuneSettings: TuneSettings? {
		didSet {
			if tuneSettings?.rotationAngle != TuneSettingsDefaults.rotationAngle {
				rotateImage()
			}
			appleTuneSettings()
		}
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

		guard let colorFilter = Filter.colorControls.ciFilter else { return }
		colorFilter.setValue(ciInput, forKey: kCIInputImageKey)
		colorFilter.setValue(tuneSettings?.brightnessIntensity, forKey: kCIInputBrightnessKey)
		colorFilter.setValue(tuneSettings?.saturationIntensity, forKey: kCIInputSaturationKey)
		colorFilter.setValue(tuneSettings?.contrastIntensity, forKey: kCIInputContrastKey)

		let coloredImage = changedUIImageFromContext(ciImage: colorFilter.outputImage, filter: colorFilter)

		guard let vignetteFilter = Filter.vignette.ciFilter else { return }
		vignetteFilter.setValue(tuneSettings?.vignetteIntensity, forKey: kCIInputIntensityKey)
		vignetteFilter.setValue(tuneSettings?.vignetteRadius, forKey: kCIInputRadiusKey)

		guard let ciOutput = changedUIImageFromContext(ciImage: coloredImage, filter: vignetteFilter) else { return }

		tunedImage = UIImage(ciImage: ciOutput)
	}

	private func rotateImage() {
		guard let angle = tuneSettings?.rotationAngle else { return }
		guard let image = currentImage else { return }
		guard let filter = Filter.transform.ciFilter else { return }

		let transform = CGAffineTransform(rotationAngle: angle)
		let ciImage = CIImage(image: image)
		filter.setValue(ciImage, forKey: kCIInputImageKey)
		filter.setValue(transform, forKey: kCIInputTransformKey)

		guard let outputImage = filter.outputImage else { return }
		tunedImage = UIImage(ciImage: outputImage)
		currentImage = tunedImage
	}
}

extension ImageProcessor: IImageProcessor
{
	func filteredImage(image: UIImage, with filter: CIFilter?) -> UIImage? {
		guard let filter = filter else { return image }
		let ciInput = CIImage(image: image)
		guard let ciOutput = changedUIImageFromContext(ciImage: ciInput, filter: filter) else { return nil }
		return UIImage(ciImage: ciOutput)
	}

	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)] {
		var previews = [(title: String, image: UIImage?)]()
		for index in 0..<Filter.photoFilters.count {
			let preview = Filter.photoFilters[index]
			let image = filteredImage(image: image, with: preview.ciFilter)
			previews.append((preview.title, image))
		}
		return previews
	}
}
