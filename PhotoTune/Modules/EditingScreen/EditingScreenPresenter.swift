//
//  EditingScreenPresenter.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IEditingScreenPresenter
{
	func getInitialImage() -> UIImage
	func getFilteredImageFor(filterIndex: Int) -> UIImage?

	func filtersToolPressed()
	func tuneToolPressed()
	func rotationToolPressed()

	func getFiltersCount() -> Int
	func getFiltersPreview(index: Int) -> (title: String, image: UIImage?)

	func getTuneToolsCount() -> Int
	func getTuneToolCellDataFor(index: Int) -> (title: String, image: UIImage?, type: TuneToolType)

	func brightnessChanged(value: Float) -> UIImage?
	func contrastChanged(value: Float) -> UIImage?
	func saturationChanged(value: Float) -> UIImage?
	func whenSaveTuneSettingsTapped(save image: UIImage?)
}

final class EditingScreenPresenter
{
	private let router: IEditingScreenRouter
	private let image: UIImage
	private var imageProcessor: IImageProcessor
	private let previews: [(title: String, image: UIImage?)]

	var editingScreen: IEditingScreen?

	init(image: UIImage, imageProcessor: IImageProcessor, router: IEditingScreenRouter) {
		self.image = image
		self.router = router
		self.imageProcessor = imageProcessor
		self.imageProcessor.currentImage = image
		previews = imageProcessor.filtersPreviews(image: self.image)
	}
}

extension EditingScreenPresenter: IEditingScreenPresenter
{
	func brightnessChanged(value: Float) -> UIImage? {
		imageProcessor.brightnessControl(value: value)
		return imageProcessor.tunedImage
	}

	func contrastChanged(value: Float) -> UIImage? {
		imageProcessor.contrastControl(value: value)
		return imageProcessor.tunedImage
	}

	func saturationChanged(value: Float) -> UIImage? {
		imageProcessor.saturationControl(value: value)
		return imageProcessor.tunedImage
	}

	func getInitialImage() -> UIImage { image }
	func filtersToolPressed() { editingScreen?.showFiltersTool() }
	func tuneToolPressed() { editingScreen?.showTuneTools() }
	func rotationToolPressed() { editingScreen?.showRotationTool() }

	func getTuneToolCellDataFor(index: Int) -> (
		title: String,
		image: UIImage?,
		type: TuneToolType) {
			return TuneTool.all[index]
	}

	func getTuneToolsCount() -> Int { TuneTool.all.count }

	func getFiltersPreview(index: Int) -> (title: String, image: UIImage?) { previews[index]
	}

	func getFiltersCount() -> Int { Filter.all.count }

	func getFilteredImageFor(filterIndex: Int) -> UIImage? {
		let filteredImage = imageProcessor.processed(
			image: image,
			with: Filter.all[filterIndex].filter)
		imageProcessor.currentImage = filteredImage
		return filteredImage
	}

	func whenSaveTuneSettingsTapped(save image: UIImage?) {
		imageProcessor.currentImage = image
	}
}
