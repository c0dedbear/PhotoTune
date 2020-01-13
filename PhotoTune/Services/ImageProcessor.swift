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
	var outputSource: IEditingScreenPresenter? { get set }

	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)]
}

final class ImageProcessor
{
	var outputSource: IEditingScreenPresenter?

	private var currentFilter: CIFilter? {
		didSet {
			guard let currentImage = currentImage else { return }
			let beginImage = CIImage(image: currentImage)
			currentCIImage = beginImage
			DispatchQueue.global(qos: .userInteractive).async {
				if self.tuneSettings?.autoEnchancement == true {
					self.currentCIImage = self.autoEnchance(ciInput: self.currentCIImage) ?? CIImage()
				}
				self.appleTuneSettings()
			}
		}
	}

	private var currentCIImage: CIImage?

	var currentImage: UIImage?
	var tunedImage: UIImage?

	var tuneSettings: TuneSettings? {
		didSet {
			tuneSettings?.limitRotationAngle()
			currentFilter = CIFilter(name: tuneSettings?.ciFilter ?? "")
		}
	}

	private let context = CIContext()

	private func filteredImageForPreview(image: UIImage, with filter: CIFilter?) -> UIImage? {
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

	private func sharpness(ciInput: CIImage?) -> CIImage? {
		guard let sharpFilter = Filter.sharpness.ciFilter else { return nil }
		sharpFilter.setValue(ciInput, forKey: kCIInputImageKey)
		sharpFilter.setValue(tuneSettings?.sharpnessIntensity, forKey: kCIInputIntensityKey)
		sharpFilter.setValue(tuneSettings?.sharpnessRadius, forKey: kCIInputRadiusKey)
		return sharpFilter.outputImage
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

	private func autoEnchance(ciInput: CIImage?) -> CIImage? {
		if var ciImage = ciInput {
			let adjustments = ciImage.autoAdjustmentFilters(options: [.redEye: false])
			for filter in adjustments {
				filter.setValue(ciImage, forKey: kCIInputImageKey)
				if let outputImage = filter.outputImage {
					ciImage = outputImage
				}
			}
			return ciImage
		}
		return nil
	}

	private func appleTuneSettings() {

		currentCIImage = colorControls(ciInput: currentCIImage)
		currentCIImage = rotateImage(ciImage: currentCIImage)
		currentCIImage = vignette(ciInput: currentCIImage)
		currentCIImage = sharpness(ciInput: currentCIImage)

		if let photoFilterOutput = photoFilter(ciInput: currentCIImage) {
			currentCIImage = photoFilterOutput
		}

		guard let ciOuput = currentCIImage else { return }
		guard let cgImage = context.createCGImage(ciOuput, from: ciOuput.extent) else { return }
		DispatchQueue.main.async { [weak self] in
			self?.tunedImage = UIImage(cgImage: cgImage)
			self?.outputSource?.updateImage(image: self?.tunedImage)
		}
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
