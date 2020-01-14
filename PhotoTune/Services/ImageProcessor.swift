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

protocol IImageProcessor: AnyObject
{
	var initialImage: UIImage? { get set }
	var tunedImage: UIImage? { get set }

	var tuneSettings: TuneSettings? { get set }
	var outputSource: IImageProcessorOutputSource? { get set }

	func clearContexCache()
	func filtersPreviews(image: UIImage) -> [(title: String, image: UIImage?)]
}

protocol IImageProcessorOutputSource: AnyObject
{
	func updateImage(image: UIImage?)
}

final class ImageProcessor
{
	private let context: CIContext
	private var currentCIImage: CIImage?
	private let throttler = Throttler(minimumDelay: 0.0125)
	private let enhanceThrottler = Throttler(minimumDelay: 0.045)

	weak var outputSource: IImageProcessorOutputSource?
	var initialImage: UIImage?
	private var jpegData: Data? { initialImage?.jpegData(compressionQuality: 0.7) }
	var tunedImage: UIImage? { didSet { outputSource?.updateImage(image: tunedImage) } }

	var tuneSettings: TuneSettings? {
		didSet {
			print(tuneSettings?.autoEnchancement)
			throttler.throttle {
				self.appleTuneSettings()
			}
		}
	}

	var flag = false

	init() {
		if let device = MTLCreateSystemDefaultDevice() {
			//use Metal
			context = CIContext(mtlDevice: device,
								options: [
				CIContextOption.highQualityDownsample: true,
				CIContextOption.cacheIntermediates: true,
			])
		}
		else {
			// use CPU
			context = CIContext()
		}
	}

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
			let adjustments = ciImage.autoAdjustmentFilters(options: [.enhance: true])
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
		print("Appling settings")
		guard let imageData = jpegData else { return }
		guard let resizedImage = UIImage(data: imageData)?.resized(withPercentage: 0.5) else { return }

		currentCIImage = CIImage(image: resizedImage)

		currentCIImage = colorControls(ciInput: currentCIImage)
		currentCIImage = rotateImage(ciImage: currentCIImage)
		currentCIImage = vignette(ciInput: currentCIImage)
		currentCIImage = sharpness(ciInput: currentCIImage)

		if let photoFilterOutput = photoFilter(ciInput: currentCIImage) {
			currentCIImage = photoFilterOutput
		}

//		enhanceThrottler.throttle {
			if self.tuneSettings?.autoEnchancement == true && flag == true {
				print("Appling autoenhance")
				guard let ciOuput = self.autoEnchance(ciInput: self.currentCIImage) else { return }
				currentCIImage = ciOuput
				flag = false
			}
			else {
					flag = true
				}
//		}

		guard let ciOuput = currentCIImage else { return }
		guard let cgImage = context.createCGImage(ciOuput, from: ciOuput.extent) else { return }

		tunedImage = UIImage(cgImage: cgImage)
		print("Finished Appling settings")
	}
}

extension ImageProcessor: IImageProcessor
{
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

extension UIImage
{
	func resized(withPercentage percentage: CGFloat) -> UIImage? {
		let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
		return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image { _ in
			draw(in: CGRect(origin: .zero, size: canvas))
		}
	}
	func resized(toWidth width: CGFloat) -> UIImage? {
		let canvas = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
		return UIGraphicsImageRenderer(
			size: canvas,
			format: imageRendererFormat).image { _ in draw(in: CGRect(origin: .zero, size: canvas))
		}
	}
}
