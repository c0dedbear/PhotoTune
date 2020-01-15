//
//  EditingScreenPresenter.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

// MARK: - Protocol IEditingScreenPresenter
protocol IEditingScreenPresenter
{
	func getInitialImage() -> UIImage?
	func getFilteredImageFor(filterIndex: Int)

	func filtersToolPressed()
	func tuneToolPressed()
	func rotationToolPressed()

	func getFiltersCount() -> Int
	func getFiltersPreview(index: Int) -> (title: String, image: UIImage?)

	func getTuneToolsCount() -> Int
	func getTuneToolCellDataFor(index: Int) -> TuneTool

	func getTuneSettings() -> TuneSettings?
	func onSaveTuneSettingsTapped(save settings: TuneSettings)

	func onRotateClockwiseTapped()
	func onRotateAntiClockwiseTapped()

	func onShareTapped()
	func onCancelTapped()
	func onSaveTapped()
	func onAutoEnchanceTapped(value: Bool)
}
// MARK: - EditingScreenPresenter
final class EditingScreenPresenter
{
	weak var editingScreen: IEditingScreen?

	private let storageService: IStorageService
	private let image: UIImage?
	private let editedImage: EditedImage?
	private var imageProcessor: IImageProcessor
	private var previews: [(title: String, image: UIImage?)] = []

	init(
		image: UIImage?,
		editedImage: EditedImage?,
		imageProcessor: IImageProcessor,
		storageService: IStorageService) {
		self.image = image
		self.editedImage = editedImage
		self.imageProcessor = imageProcessor
		self.storageService = storageService
		self.imageProcessor.outputSource = self
		makePreviews()
	}
}
// MARK: - Private Methods
private extension EditingScreenPresenter
{
	func makePreviews() {
		if let newImage = image {
			imageProcessor.initialImage = newImage
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
				imageProcessor.initialImage = storedImage
				imageProcessor.tuneSettings = editedImage.tuneSettings
				previews = imageProcessor.filtersPreviews(image: storedImage)
			}
		}
	}

	func saveImageAsNew() {
		guard let currentImage = imageProcessor.initialImage else {
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

	func saveExistingImage() {
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

// MARK: - IEditingScreenPresenter Methods
extension EditingScreenPresenter: IEditingScreenPresenter
{
	func onAutoEnchanceTapped(value: Bool) {
		imageProcessor.tuneSettings?.autoEnchancement = value
	}

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
		imageProcessor.clearContexCache()
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

	func getFilteredImageFor(filterIndex: Int) {
		imageProcessor.tuneSettings?.ciFilter = Filter.photoFilters[filterIndex].ciFilter?.name
	}

	func filtersToolPressed() { editingScreen?.showFiltersTool() }
	func tuneToolPressed() { editingScreen?.showTuneTools() }
	func rotationToolPressed() { editingScreen?.showRotationTool() }

	func getTuneToolCellDataFor(index: Int) -> TuneTool { TuneTool.allCases[index] }
	func getTuneToolsCount() -> Int { TuneTool.allCases.count }

	func getFiltersPreview(index: Int) -> (title: String, image: UIImage?) { previews[index] }
	func getFiltersCount() -> Int { Filter.photoFilters.count }

	func getTuneSettings() -> TuneSettings? { imageProcessor.tuneSettings }

	func onSaveTuneSettingsTapped(save settings: TuneSettings) {
		imageProcessor.tuneSettings = settings
	}

	func onRotateAntiClockwiseTapped() {
		imageProcessor.tuneSettings?.rotationAngle += TuneSettingsDefaults.rotationAngleStep
		imageProcessor.tuneSettings?.limitRotationAngle()
	}

	func onRotateClockwiseTapped() {
		imageProcessor.tuneSettings?.rotationAngle -= TuneSettingsDefaults.rotationAngleStep
		imageProcessor.tuneSettings?.limitRotationAngle()
	}
}

// MARK: - IImageProcessorOutputSource Methods
extension EditingScreenPresenter: IImageProcessorOutputSource
{
	func updateImage(image: UIImage?) { editingScreen?.updateImageView(image: image) }
}
