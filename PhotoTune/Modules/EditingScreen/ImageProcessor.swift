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

	private func changedUIImageFromContext(image: UIImage?, filter: CIFilter) -> UIImage? {
		guard let image = image else { return nil }
		guard let ciImageInput = CIImage(image: image) else { return nil }
		filter.setValue(ciImageInput, forKey: kCIInputImageKey)
		guard let ciImageOutput = filter.outputImage else { return nil }
		guard let cgImage = context.createCGImage(ciImageOutput, from: ciImageOutput.extent) else { return image }

		return UIImage(cgImage: cgImage)
	}

	private func appleTuneSettings() {
		guard let colorFilter = CIFilter(name: "CIColorControls") else { return }

		colorFilter.setValue(tuneSettings?.brightnessIntensity, forKey: kCIInputBrightnessKey)
		colorFilter.setValue(tuneSettings?.saturationIntensity, forKey: kCIInputSaturationKey)
		colorFilter.setValue(tuneSettings?.contrastIntensity, forKey: kCIInputContrastKey)

		tunedImage = changedUIImageFromContext(image: currentImage, filter: colorFilter)

		guard let vignetteFilter = CIFilter(name: "CIVignette") else { return }
		vignetteFilter.setValue(tuneSettings?.vignetteIntensity, forKey: kCIInputIntensityKey)
		vignetteFilter.setValue(tuneSettings?.vignetteRadius, forKey: kCIInputRadiusKey)

		tunedImage = changedUIImageFromContext(image: tunedImage, filter: vignetteFilter)
	}
}

extension ImageProcessor: IImageProcessor
{
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
