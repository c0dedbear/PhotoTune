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
	var initialImage: UIImage? { get set }
	var resizedImage: UIImage? { get }
	var tunedImage: UIImage? { get set }

	var tuneSettings: TuneSettings? { get set }
	var outputSource: IImageProcessorOutputSource? { get set }

	func resizedImage(_ image: UIImage?, for size: CGSize) -> UIImage?
	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)]
}

protocol IImageProcessorOutputSource
{
	var scaleFactor: CGFloat { get }
	var scale: CGAffineTransform { get }
	var size: CGSize { get }

	func updateImage(image: UIImage?)
}

final class ImageProcessor
{
	var outputSource: IImageProcessorOutputSource?

	private var currentCIImage: CIImage?
	private var currentPhotoFilter: CIFilter? { CIFilter(name: tuneSettings?.ciFilter ?? "") }
	private let filtersChain = Filter.controlsChainFilters

	var initialImage: UIImage?
	var tunedImage: UIImage?

	var tuneSettings: TuneSettings? {
		didSet {
			tuneSettings?.limitRotationAngle()
//			DispatchQueue.global(qos: .userInteractive).async {
//				if self.tuneSettings?.autoEnchancement == true {
//					self.currentCIImage = self.autoEnchance(ciInput: self.currentCIImage) ?? CIImage()
//				}
				self.appleTuneSettings()
//			}
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

	private func colorControls() -> CIImage? {
		guard let image = resizedImage else { return nil }
		guard let ciImage = CIImage(image: image) else { return nil }
		guard let colorFilter = Filter.colorControls.ciFilter else { return nil }
		colorFilter.setValue(ciImage, forKey: kCIInputImageKey)
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

		if currentCIImage == nil {
			DispatchQueue.main.async {
				self.currentCIImage = self.colorControls()
			}
		}

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
	var resizedImage: UIImage? { resizedImage(initialImage, for: outputSource?.size ?? .zero) }

	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)] {
		var previews = [(title: String, image: UIImage?)]()
		for index in 0..<Filter.photoFilters.count {
			let preview = Filter.photoFilters[index]
			let image = filteredImageForPreview(image: image, with: preview.ciFilter)
			previews.append((preview.title, image))
		}
		return previews
	}

	func resizedImage(_ image: UIImage?, for size: CGSize) -> UIImage? {
		guard let image = image else { return nil }
		print(size)

		let renderer = UIGraphicsImageRenderer(size: size)
		let newImage = renderer.image { _ in
			image.draw(in: CGRect(origin: .zero, size: size))
		}
		print(newImage.size)
		return newImage
	}
}
