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
	func getImage() -> UIImage
	func getFilteredImageFor(filterIndex: Int) -> UIImage
	func getFiltersCount() -> Int
	func getFilterPreview(index: Int) -> UIImage
	func getFilterTitle(index: Int) -> String
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
	func getFilteredImageFor(filterIndex: Int) -> UIImage {
		let filteredImage = imageProcessor.processed(
			image: image,
			with: imageProcessor.filters[filterIndex])
		return filteredImage
	}

	func getFilterPreview(index: Int) -> UIImage {
		previews[index]
	}

	func getFilterTitle(index: Int) -> String {
		guard previews.count == imageProcessor.filtersTitles.count else { return "" }
		return imageProcessor.filtersTitles[index]
	}

	func getFiltersCount() -> Int { imageProcessor.filters.count }
	func filtersToolPressed() { editingScreen?.showFiltersCollection() }
	func tuneToolPressed() { editingScreen?.showTuneView() }
	func rotationToolPressed() { editingScreen?.showRotationView() }
	func getImage() -> UIImage { image }
}
