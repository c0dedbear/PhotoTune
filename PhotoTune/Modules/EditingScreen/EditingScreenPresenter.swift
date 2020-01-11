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
	func onCancelTapped()
	func onSaveTapped()
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
					assertionFailure(ErrorMessages.noStoredData)
					return
				}
				imageProcessor.currentImage = storedImage
				imageProcessor.tuneSettings = editedImage.tuneSettings
				previews = imageProcessor.filtersPreviews(image: storedImage)
			}
		}
	}

	private func saveImageAsNew() {
		guard let currentImage = imageProcessor.currentImage else { fatalError(ErrorMessages.nothingToSave) }
		guard let previewImage = self.imageProcessor.tunedImage else { fatalError(ErrorMessages.nothingToSave) }
		let filename = UUID().uuidString
		let previewFileName = "preview_" + filename
		let editedImage = EditedImage(imageFileName: filename,
									  previewFileName: previewFileName,
									  editingDate: Date(),
									  tuneSettings: imageProcessor.tuneSettings)
		storageService.storeImage(currentImage, filename: filename) { [weak self] in
			self?.storageService.storeImage(previewImage, filename: previewFileName) {
				if var existingEditedImages = self?.storageService.loadEditedImages() {
					existingEditedImages.append(editedImage)
					self?.storageService.saveEditedImages(existingEditedImages)
				}
				else {
					self?.storageService.saveEditedImages([editedImage])
				}
			}
		}
	}

	private func saveExistingImage() {
		guard let editedImage = editedImage else { fatalError(ErrorMessages.saveNewImagesAsExisting) }
		guard let previewImage = self.imageProcessor.tunedImage else { fatalError(ErrorMessages.nothingToSave) }
		storageService.storeImage(previewImage, filename: editedImage.previewFileName) { [weak self] in
			if var currentEditedImages = self?.storageService.loadEditedImages() {
				for (index, item) in currentEditedImages.reversed().enumerated()
					where item.imageFileName == editedImage.imageFileName {
					currentEditedImages.remove(at: index)
					currentEditedImages.insert(editedImage, at: index)
				}
				self?.storageService.saveEditedImages(currentEditedImages)
			}
		}
	}
}

extension EditingScreenPresenter: IEditingScreenPresenter
{
	func onCancelTapped() { editingScreen?.dismiss() }

	func onSaveTapped() {
		if image != nil {
			saveImageAsNew()
		}
		else {
			saveExistingImage()
		}
		editingScreen?.dismiss()
	}

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
