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
				self.appleTuneSettings()
			}
		}
	}

	private var currentCIImage: CIImage?

	var currentImage: UIImage?
	var tunedImage: UIImage?

	var previousTuneSettings: TuneSettings?
	var tuneSettings: TuneSettings? {
		didSet {
			previousTuneSettings = oldValue
			tuneSettings?.limitRotationAngle()
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

	private func appleTuneSettings() {

		let changes = detectChangesInTuneSettings()

		switch changes {
		case .all: applyAllSettings(ciInput: currentCIImage)
		case .autoEnhance: autoEnchance(ciInput: currentCIImage)
		case .colorControls: colorControls(ciInput: currentCIImage)
		case .filter: photoFilter(ciInput: currentCIImage)
		case .rotation: rotateImage(ciImage: currentCIImage)
		case .sharpness: sharpness(ciInput: currentCIImage)
		case .vignette: vignette(ciInput: currentCIImage)
		case .none: break
		@unknown default: assertionFailure(AlertMessages.unknownInstrumentChanged)
		}

		guard let ciOuput = currentCIImage else { return }
		ciOuput.clampedToExtent()
		guard let cgImage = context.createCGImage(ciOuput, from: ciOuput.extent) else { return }
		DispatchQueue.main.async { [weak self] in
			self?.tunedImage = UIImage(cgImage: cgImage)
			self?.outputSource?.updateImage(image: self?.tunedImage)
		}
	}

	private func detectChangesInTuneSettings() -> ChangedInstrument {
		guard let oldSettings = previousTuneSettings else { return .all }
		guard let currentSettings = tuneSettings else { return .none }

		if oldSettings.ciFilter != currentSettings.ciFilter { return .filter }
		if oldSettings.autoEnchancement != currentSettings.autoEnchancement { return .autoEnhance }
		if oldSettings.rotationAngle != currentSettings.rotationAngle { return .rotation }

		if (oldSettings.sharpnessIntensity != currentSettings.sharpnessIntensity)
			|| (oldSettings.sharpnessRadius != currentSettings.sharpnessRadius) {
			return .sharpness
		}

		if (oldSettings.brightnessIntensity != currentSettings.brightnessIntensity)
			|| (oldSettings.contrastIntensity != currentSettings.contrastIntensity)
			|| (oldSettings.saturationIntensity != currentSettings.saturationIntensity) {
			return .colorControls
		}

		return .none
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

// MARK: - Filters
private extension ImageProcessor
{
	func applyAllSettings(ciInput: CIImage?) {
		colorControls(ciInput: ciInput)
		rotateImage(ciImage: ciInput)
		vignette(ciInput: ciInput)
		sharpness(ciInput: ciInput)
		photoFilter(ciInput: ciInput)
		autoEnchance(ciInput: ciInput)
	}

	func photoFilter(ciInput: CIImage?) {
		guard let photoFilter = CIFilter(name: tuneSettings?.ciFilter ?? "") else { return }
		photoFilter.setValue(ciInput, forKey: kCIInputImageKey)
		currentCIImage = photoFilter.outputImage
	}

	func colorControls(ciInput: CIImage?) {
		guard let colorFilter = Filter.colorControls.ciFilter else { return }
		colorFilter.setValue(ciInput, forKey: kCIInputImageKey)
		colorFilter.setValue(tuneSettings?.brightnessIntensity, forKey: kCIInputBrightnessKey)
		colorFilter.setValue(tuneSettings?.saturationIntensity, forKey: kCIInputSaturationKey)
		colorFilter.setValue(tuneSettings?.contrastIntensity, forKey: kCIInputContrastKey)
		currentCIImage = colorFilter.outputImage
	}

	func sharpness(ciInput: CIImage?){
		guard let sharpFilter = Filter.sharpness.ciFilter else { return }
		sharpFilter.setValue(ciInput, forKey: kCIInputImageKey)
		sharpFilter.setValue(tuneSettings?.sharpnessIntensity, forKey: kCIInputIntensityKey)
		sharpFilter.setValue(tuneSettings?.sharpnessRadius, forKey: kCIInputRadiusKey)
		currentCIImage = sharpFilter.outputImage
	}

	func vignette(ciInput: CIImage?) {
		guard let vignetteFilter = Filter.vignette.ciFilter else { return }
		vignetteFilter.setValue(ciInput, forKey: kCIInputImageKey)
		vignetteFilter.setValue(tuneSettings?.vignetteIntensity, forKey: kCIInputIntensityKey)
		vignetteFilter.setValue(tuneSettings?.vignetteRadius, forKey: kCIInputRadiusKey)
		currentCIImage = vignetteFilter.outputImage
	}

	func rotateImage(ciImage: CIImage?) {
		guard let filter = Filter.transform.ciFilter else { return }
		guard let angle = tuneSettings?.rotationAngle else { return }

		let transform = CGAffineTransform(rotationAngle: angle)

		filter.setValue(ciImage, forKey: kCIInputImageKey)
		filter.setValue(transform, forKey: kCIInputTransformKey)

		currentCIImage = filter.outputImage
	}

	func autoEnchance(ciInput: CIImage?) {
		if tuneSettings?.autoEnchancement == true {
			if var ciImage = ciInput {
				let adjustments = ciImage.autoAdjustmentFilters(options: [.redEye: false])
				for filter in adjustments {
					filter.setValue(ciImage, forKey: kCIInputImageKey)
					if let outputImage = filter.outputImage {
						ciImage = outputImage
					}
				}
				currentCIImage = ciImage
			}
		}
	}
}
