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

	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)]
}

final class ImageProcessor
{
	var currentImage: UIImage?
	var tunedImage: UIImage?
	var tuneSettings: TuneSettings? {
		didSet {
			tuneSettings?.limitRotationAngle()
			appleTuneSettings()
		}
	}

	private let context = CIContext()

	func filteredImageForPreview(image: UIImage, with filter: CIFilter?) -> UIImage? {
		guard let filter = filter else { return image }
		let ciInput = CIImage(image: image)
		filter.setValue(ciInput, forKey: kCIInputImageKey)
		guard let ciOutput = filter.outputImage else { return nil }
		return UIImage(ciImage: ciOutput)
	}

	private func photoFilter(ciInput: CIImage?) -> CIImage? {
		guard let photoFilter = CIFilter(name: tuneSettings?.ciFilter ?? "") else { return nil }
		photoFilter.setValue(ciInput, forKey: kCIInputImageKey)
		return photoFilter.outputImage
	}

	private func colorControls(ciInput: CIImage?) -> CIImage? {
		guard let colorFilter = Filter.colorControls.ciFilter else { return nil }
		colorFilter.setValue(ciInput, forKey: kCIInputImageKey)
		colorFilter.setValue(tuneSettings?.brightnessIntensity, forKey: kCIInputBrightnessKey)
		colorFilter.setValue(tuneSettings?.saturationIntensity, forKey: kCIInputSaturationKey)
		colorFilter.setValue(tuneSettings?.contrastIntensity, forKey: kCIInputContrastKey)
		return colorFilter.outputImage
	}

	private func vignette(ciInput: CIImage?) -> CIImage? {
		guard let vignetteFilter = Filter.vignette.ciFilter else { return nil }
		vignetteFilter.setValue(ciInput, forKey: kCIInputImageKey)
		vignetteFilter.setValue(tuneSettings?.vignetteIntensity, forKey: kCIInputIntensityKey)
		vignetteFilter.setValue(tuneSettings?.vignetteRadius, forKey: kCIInputRadiusKey)

		return vignetteFilter.outputImage
	}

	private func rotateImage(ciImage: CIImage?) -> CIImage? {
		guard let filter = Filter.transform.ciFilter else { return nil }
		guard let angle = tuneSettings?.rotationAngle else { return nil }

		let transform = CGAffineTransform(rotationAngle: angle)

		filter.setValue(ciImage, forKey: kCIInputImageKey)
		filter.setValue(transform, forKey: kCIInputTransformKey)

		return filter.outputImage
	}

	private func appleTuneSettings() {
		guard let image = currentImage else { return }

		let ciInput: CIImage

		if let ciContext = image.ciImage {
			ciInput = ciContext
		}
		else {
			guard let ciImage = CIImage(image: image) else  { return }
			ciInput = ciImage
		}

		let colorControlsOutput = colorControls(ciInput: ciInput)
		let vignetteOutput = vignette(ciInput: colorControlsOutput)
		let rotationOutput = rotateImage(ciImage: vignetteOutput)

		if let photoFilterOutput = photoFilter(ciInput: rotationOutput) {
			guard let cgImage = context.createCGImage(photoFilterOutput, from: photoFilterOutput.extent) else { return }
			tunedImage = UIImage(cgImage: cgImage)
			return
		}

		guard let ciChainOutput = rotationOutput else { return }
		guard let cgImage = context.createCGImage(ciChainOutput, from: ciChainOutput.extent) else { return }
		tunedImage = UIImage(cgImage: cgImage)
	}
}

extension ImageProcessor: IImageProcessor
{
	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)] {
		var previews = [(title: String, image: UIImage?)]()
		for index in 0..<Filter.photoFilters.count {
			let preview = Filter.photoFilters[index]
			let image = filteredImageForPreview(image: image, with: preview.ciFilter)
			previews.append((preview.title, image))
		}
		return previews
	}
}
