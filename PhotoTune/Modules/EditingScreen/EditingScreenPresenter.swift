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
	func onSaveTuneSettingsTapped(save settings: TuneSettings, image: (UIImage?) -> Void)

	func onRotateClockwiseTapped(image: (UIImage?) -> Void)
	func onRotateAntiClockwiseTapped(image: (UIImage?) -> Void)

	func onShareTapped()
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
	func onShareTapped() {
		guard let data = editingScreen?.currentImage?.pngData() else { return }

		let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: [])

		activityVC.completionWithItemsHandler = { _, _, _, error in
			if error == nil {
				//saveImage to Disk
			}
		}
		editingScreen?.showAcitivityVC(activityVC)
	}

	func getInitialImage() -> UIImage { image }
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
