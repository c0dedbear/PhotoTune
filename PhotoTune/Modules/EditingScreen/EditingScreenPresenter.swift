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
	func getTuneToolCellDataFor(index: Int) -> TuneTool
	func getTuneSettings() -> TuneSettings?

	func whenSaveTuneSettingsTapped(save settings: TuneSettings, image: (UIImage?) -> Void)
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
		self.imageProcessor.tuneSettings = TuneSettings()
		previews = imageProcessor.filtersPreviews(image: self.image)
	}
}

extension EditingScreenPresenter: IEditingScreenPresenter
{
	func getInitialImage() -> UIImage { image }
	func filtersToolPressed() {
		editingScreen?.showFiltersTool()
	}
	func tuneToolPressed() { editingScreen?.showTuneTools() }
	func rotationToolPressed() { editingScreen?.showRotationTool() }

	func getTuneToolCellDataFor(index: Int) -> TuneTool {
			return TuneTool.allCases[index]
	}

	func getTuneToolsCount() -> Int { TuneTool.allCases.count }

	func getFiltersPreview(index: Int) -> (title: String, image: UIImage?) { previews[index]
	}

	func getFiltersCount() -> Int { Filters.all.count }

	func getFilteredImageFor(filterIndex: Int) -> UIImage? {
		let filteredImage = imageProcessor.processed(
			image: image,
			with: Filters.all[filterIndex].filter)
		imageProcessor.currentImage = filteredImage
		return filteredImage
	}

	func whenSaveTuneSettingsTapped(save settings: TuneSettings, image: (UIImage?) -> Void) {
		imageProcessor.tuneSettings = settings
		image(imageProcessor.tunedImage)
	}

	func getTuneSettings() -> TuneSettings? {
		imageProcessor.tuneSettings
	}
}
