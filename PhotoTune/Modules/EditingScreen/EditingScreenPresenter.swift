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
		storageService: IStorageService) {
		self.image = image
		self.editedImage = editedImage
		self.imageProcessor = imageProcessor
		self.storageService = storageService
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
					assertionFailure(AlertMessages.noStoredData)
					return
				}
				imageProcessor.currentImage = storedImage
				imageProcessor.tuneSettings = editedImage.tuneSettings
				previews = imageProcessor.filtersPreviews(image: storedImage)
			}
		}
	}

	private func saveImageAsNew() {
		guard let currentImage = imageProcessor.currentImage else {
			editingScreen?.showErrorAlert(title: AlertMessages.error, message: AlertMessages.nothingToSave, dismiss: true)
			return
		}
		guard let previewImage = self.imageProcessor.tunedImage else {
			editingScreen?.showErrorAlert(title: AlertMessages.error, message: AlertMessages.nothingToSave, dismiss: true)
			return
		}
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
			self?.editingScreen?.dismiss(toRoot: true, completion: nil)
		}
	}

	private func saveExistingImage() {
		guard var editedImage = editedImage else {
			editingScreen?.showErrorAlert(
				title: AlertMessages.error,
				message: AlertMessages.saveNewImagesAsExisting,
				dismiss: true)
			return
		}

		guard let previewImage = self.imageProcessor.tunedImage else {
			editingScreen?.showErrorAlert(title: AlertMessages.error, message: AlertMessages.nothingToSave, dismiss: true)
			return
		}

		editedImage.tuneSettings = imageProcessor.tuneSettings

		storageService.storeImage(previewImage, filename: editedImage.previewFileName) { [weak self] in
			if var currentEditedImages = self?.storageService.loadEditedImages() {
				for (index, item) in currentEditedImages.enumerated()
					where item.imageFileName == editedImage.imageFileName {
					currentEditedImages.remove(at: index)
					currentEditedImages.insert(editedImage, at: index)
				}
				self?.storageService.saveEditedImages(currentEditedImages)
				self?.editingScreen?.dismiss(toRoot: true, completion: nil)
			}
		}
	}
}

extension EditingScreenPresenter: IEditingScreenPresenter
{
	func onCancelTapped() {
		editingScreen?.showAttentionAlert(title: AlertMessages.cancelTappedTitle, message: AlertMessages.cancelTappedMessage)
	}

	func onSaveTapped() {
		if image != nil {
			saveImageAsNew()
		}
		else {
			saveExistingImage()
		}
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
