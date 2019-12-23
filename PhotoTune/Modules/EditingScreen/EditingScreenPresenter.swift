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
	func filtersToolPressed()
	func tuneToolPressed()
	func rotationToolPressed()
	func getInitialImage() -> UIImage
	func getFilteredImageFor(filterIndex: Int) -> UIImage
	func getFiltersCount() -> Int
	func getFilterPreview(index: Int) -> UIImage
	func getFilterTitle(index: Int) -> String

	func getTuneToolsCount() -> Int
	func getTuneToolImageFor(index: Int) -> UIImage?
	func getTuneTitleFor(index: Int) -> String
	func controlsColorsWithValues(brightness: Float, saturation: Float, contrast: Float) -> UIImage
}

final class EditingScreenPresenter
{
	private let router: IEditingScreenRouter
	private let image: UIImage
	private let imageProcessor: IImageProcessor
	private let previews: [UIImage]

	var editingScreen: IEditingScreen?

	init(image: UIImage, imageProcessor: IImageProcessor, router: IEditingScreenRouter) {
		self.image = image
		self.router = router
		self.imageProcessor = imageProcessor
		previews = imageProcessor.filtersPreviews(image: self.image)
	}
}

extension EditingScreenPresenter: IEditingScreenPresenter
{
	func getTuneToolsCount() -> Int { TuneTools.all.count }

	func getTuneToolImageFor(index: Int) -> UIImage? {
		TuneTools.all[index].image
	}

	func getTuneTitleFor(index: Int) -> String {
		TuneTools.all[index].title
	}

	func getFilterPreview(index: Int) -> UIImage { previews[index] }
	func getFilterTitle(index: Int) -> String { imageProcessor.filterTitleFor(index: index) }
	func getFiltersCount() -> Int { imageProcessor.filtersCount }

	func getFilteredImageFor(filterIndex: Int) -> UIImage {
		let filteredImage = imageProcessor.processed(
			image: image,
			with: imageProcessor.filterFor(index: filterIndex))
		return filteredImage
	}

	func controlsColorsWithValues(brightness: Float, saturation: Float, contrast: Float) -> UIImage {
		imageProcessor.colorControls(image: image,
									 brightness: brightness,
									 saturation: saturation,
									 contrast: contrast)
	}

	func filtersToolPressed() { editingScreen?.showFiltersTool() }
	func tuneToolPressed() { editingScreen?.showTuneTools() }
	func rotationToolPressed() { editingScreen?.showRotationTool() }

	func getInitialImage() -> UIImage { image }
}
