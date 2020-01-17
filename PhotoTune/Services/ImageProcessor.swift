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

// MARK: - Protocols
protocol IImageProcessor: AnyObject
{
	var initialImage: UIImage? { get set }
	var tunedImage: UIImage? { get set }
	var transformedImage: UIImage? { get }

	var tuneSettings: TuneSettings? { get set }
	var outputSource: IImageProcessorOutputSource? { get set }

	func clearContexCache()
	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)]
	func makeFullSizeTunedImage(from image: UIImage, output: @escaping ((UIImage?) -> Void))
}

protocol IImageProcessorOutputSource: AnyObject
{
	func updateImage(image: UIImage?)
}

// MARK: - ImageProcessor
final class ImageProcessor
{
	// MARK: Properties
	var outputSource: IImageProcessorOutputSource?

	var initialImage: UIImage? {
		didSet {
			if let image = initialImage {
				autoEnhanceFilters = CIImage(image: image)?.autoAdjustmentFilters()
			}
		}
	}

	var tunedImage: UIImage? { didSet { outputSource?.updateImage(image: tunedImage) } }

	var transformedImage: UIImage? { applyTransform(ciImage: currentCIImage) }

	var tuneSettings: TuneSettings? {
		didSet {
			throttler.throttle {
				self.appleTuneSettings()
			}
		}
	}

	// MARK: Private Properties
	private let throttler: Throttler
	private let context: CIContext
	private var currentCIImage: CIImage?
	private var autoEnhanceFilters: [CIFilter]?
	private var jpegData: Data? { initialImage?.jpegData(compressionQuality: 0.7) }
	private let screenSize = UIScreen.main.bounds

	init() {
		throttler = Throttler(minimumDelay: 0.0125)
		if let device = MTLCreateSystemDefaultDevice() {
			//use Metal if possible
			context = CIContext(mtlDevice: device)
		}
		else {
			// use CPU
			context = CIContext()
		}
	}
}
// MARK: - Private Methods
private extension ImageProcessor
{
	func filteredImageForPreview(image: UIImage, with filter: CIFilter?) -> UIImage? {
		guard let filter = filter else { return image }
		let ciInput = CIImage(image: image)
		filter.setValue(ciInput, forKey: kCIInputImageKey)
		guard let ciOutput = filter.outputImage else { return nil }
		return UIImage(ciImage: ciOutput)
	}

	func photoFilter(ciInput: CIImage?) -> CIImage? {
		guard let photoFilter = CIFilter(name: tuneSettings?.ciFilter ?? "") else { return nil }
		photoFilter.setValue(ciInput, forKey: kCIInputImageKey)
		return photoFilter.outputImage
	}

	func colorControls(ciInput: CIImage?) -> CIImage? {
		guard let colorFilter = Filter.colorControls.ciFilter else { return nil }
		colorFilter.setValue(ciInput, forKey: kCIInputImageKey)
		colorFilter.setValue(tuneSettings?.brightnessIntensity, forKey: kCIInputBrightnessKey)
		colorFilter.setValue(tuneSettings?.saturationIntensity, forKey: kCIInputSaturationKey)
		colorFilter.setValue(tuneSettings?.contrastIntensity, forKey: kCIInputContrastKey)
		return colorFilter.outputImage
	}

	func sharpness(ciInput: CIImage?) -> CIImage? {
		guard let sharpFilter = Filter.sharpness.ciFilter else { return nil }
		sharpFilter.setValue(ciInput, forKey: kCIInputImageKey)
		sharpFilter.setValue(tuneSettings?.sharpnessIntensity, forKey: kCIInputIntensityKey)
		sharpFilter.setValue(tuneSettings?.sharpnessRadius, forKey: kCIInputRadiusKey)
		return sharpFilter.outputImage
	}

	func vignette(ciInput: CIImage?) -> CIImage? {
		guard let vignetteFilter = Filter.vignette.ciFilter else { return nil }
		vignetteFilter.setValue(ciInput, forKey: kCIInputImageKey)
		vignetteFilter.setValue(tuneSettings?.vignetteIntensity, forKey: kCIInputIntensityKey)
		vignetteFilter.setValue(tuneSettings?.vignetteRadius, forKey: kCIInputRadiusKey)

		return vignetteFilter.outputImage
	}

	private func applyTransform(ciImage: CIImage?) -> UIImage? {
		/*
		Call this method only when save or export image, because it's expensive for real time using.
		RatherUse your's imageView .transform property for showing real time transformation to user.
		*/
		guard let filter = Filter.transform.ciFilter else { return nil }
		guard let angle = tuneSettings?.rotationAngle else { return nil }

		let transform = CGAffineTransform(rotationAngle: -angle)

		filter.setValue(ciImage, forKey: kCIInputImageKey)
		filter.setValue(transform, forKey: kCIInputTransformKey)

		currentCIImage = filter.outputImage
		guard let ciOuput = self.currentCIImage else { return nil }
		guard let cgImage = self.context.createCGImage(ciOuput, from: ciOuput.extent) else { return nil }
		return UIImage(cgImage: cgImage)
	}

	private func autoEnchance() {
		if let filters = autoEnhanceFilters {
			for filter in filters {
				filter.setValue(currentCIImage, forKey: kCIInputImageKey)
				currentCIImage = filter.outputImage
			}
		}
	}

	private func appleTuneSettings(to image: UIImage? = nil,
								   output: ((UIImage?) -> Void)? = nil) {

		DispatchQueue.global(qos: .userInteractive).async {
			if let image = image {
				self.currentCIImage = CIImage(image: image)
			}
			else {
				guard let inputImage = self.initialImage else { return }
				self.currentCIImage = CIImage(image: inputImage)
			}

			self.currentCIImage = self.colorControls(ciInput: self.currentCIImage)
			self.currentCIImage = self.vignette(ciInput: self.currentCIImage)
			self.currentCIImage = self.sharpness(ciInput: self.currentCIImage)

			if let photoFilterOutput = self.photoFilter(ciInput: self.currentCIImage) {
				self.currentCIImage = photoFilterOutput
			}

			if self.tuneSettings?.autoEnchancement == true {
				self.autoEnchance()
			}

			guard let ciOuput = self.currentCIImage else { return }

			if output != nil {
				if let image = self.transformedImage {
				output?(image)
				}
				return
			}

			DispatchQueue.main.async {
				self.tunedImage = UIImage(ciImage: ciOuput, scale: self.initialImage?.scale ?? 0.5, orientation: .up)
			}
		}
	}
}
// MARK: - IImageProcessor Methods
extension ImageProcessor: IImageProcessor
{
	func makeFullSizeTunedImage(from image: UIImage, output: @escaping ((UIImage?) -> Void))  {

		appleTuneSettings(to: image) { image in
			output(image)
		}
	}

	func clearContexCache() {
		context.clearCaches()
	}

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
