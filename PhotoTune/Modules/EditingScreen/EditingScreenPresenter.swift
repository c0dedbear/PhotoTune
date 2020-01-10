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
	func getInitialImage() -> UIImage?
	func getFilteredImageFor(filterIndex: Int) -> UIImage?

	func filtersToolPressed()
	func tuneToolPressed()
	func rotationToolPressed()

	func getFiltersCount() -> Int
	func getFiltersPreview(index: Int) -> (title: String, image: UIImage?)

	func getTuneToolsCount() -> Int
	func getTuneToolCellDataFor(index: Int) -> TuneTool

	func getTuneSettings() -> TuneSettings?
	func onSaveTuneSettingsTapped(save settings: TuneSettings, image: (UIImage?) -> Void)

	func onRotateClockwiseTapped(image: (UIImage?) -> Void)
	func onRotateAntiClockwiseTapped(image: (UIImage?) -> Void)

	func onShareTapped()
}

final class EditingScreenPresenter
{
	private let router: IEditingScreenRouter
	private let storageService: IStorageService
	private let image: UIImage?
	private let editedImage: EditedImage?
	private var imageProcessor: IImageProcessor
	private var previews: [(title: String, image: UIImage?)] = []

	var editingScreen: IEditingScreen?

	private func makePreviews() {
		if let newImage = image {
			imageProcessor.currentImage = newImage
			imageProcessor.tuneSettings = TuneSettings()
			previews = imageProcessor.filtersPreviews(image: newImage)
			return
		}

		if let editedImage = editedImage {
			storageService.loadImage(filename: editedImage.imageFileName) { image in
				guard let storedImage = image else {
					assertionFailure("No stored image")
					return
				}
				imageProcessor.currentImage = storedImage
				imageProcessor.tuneSettings = editedImage.tuneSettings
				previews = imageProcessor.filtersPreviews(image: storedImage)
			}
		}
	}

	init(
		image: UIImage?,
		editedImage: EditedImage?,
		imageProcessor: IImageProcessor,
		storageService: IStorageService,
		router: IEditingScreenRouter) {
		self.image = image
		self.editedImage = editedImage
		self.imageProcessor = imageProcessor
		self.storageService = storageService
		self.router = router
		makePreviews()
	}
}

extension EditingScreenPresenter: IEditingScreenPresenter
{
	func onShareTapped() {
		guard let data = editingScreen?.currentImage?.pngData() else { return }

		let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: [])

		editingScreen?.showAcitivityVC(activityVC)
	}

	func getInitialImage() -> UIImage? {
		if let image = image { return image }
		return imageProcessor.tunedImage
	}

	func getFilteredImageFor(filterIndex: Int) -> UIImage? {
		imageProcessor.tuneSettings?.ciFilter = Filter.photoFilters[filterIndex].ciFilter?.name
		return imageProcessor.tunedImage
	}

	func filtersToolPressed() { editingScreen?.showFiltersTool() }
	func tuneToolPressed() { editingScreen?.showTuneTools() }
	func rotationToolPressed() { editingScreen?.showRotationTool() }

	func getTuneToolCellDataFor(index: Int) -> TuneTool { TuneTool.allCases[index] }
	func getTuneToolsCount() -> Int { TuneTool.allCases.count }

	func getFiltersPreview(index: Int) -> (title: String, image: UIImage?) { previews[index] }
	func getFiltersCount() -> Int { Filter.photoFilters.count }

	func getTuneSettings() -> TuneSettings? { imageProcessor.tuneSettings }
	func onSaveTuneSettingsTapped(save settings: TuneSettings, image: (UIImage?) -> Void) {
		imageProcessor.tuneSettings = settings
		image(imageProcessor.tunedImage)
	}

	func onRotateAntiClockwiseTapped(image: (UIImage?) -> Void) {
		imageProcessor.tuneSettings?.rotationAngle += TuneSettingsDefaults.rotationAngleStep
		image(imageProcessor.tunedImage)
	}

	func onRotateClockwiseTapped(image: (UIImage?) -> Void) {
		imageProcessor.tuneSettings?.rotationAngle -= TuneSettingsDefaults.rotationAngleStep
		image(imageProcessor.tunedImage)
	}
}
