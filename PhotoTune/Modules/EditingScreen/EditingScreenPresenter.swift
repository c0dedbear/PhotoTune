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

	func onResetTapped()
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
	private let originalImage: UIImage?
	private var resizedImage: UIImage?
	private let editedImage: EditedImage?
	private var imageProcessor: IImageProcessor
	private var previews: [(title: String, image: UIImage?)] = []

	init(
		image: UIImage?,
		editedImage: EditedImage?,
		imageProcessor: IImageProcessor,
		storageService: IStorageService) {
		self.originalImage = image
		self.editedImage = editedImage
		resizedImage = image?.resized(toWidth: EditingScreenMetrics.scaleImageWidth)
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
		if let newImage = originalImage?.resized(toWidth: EditingScreenMetrics.scaleImageWidth) {
			imageProcessor.initialImage = newImage
			imageProcessor.tuneSettings = TuneSettings()
			previews = imageProcessor.filtersPreviews(image: newImage.resized(toWidth:
				EditingScreenMetrics.previewImageSize) ?? newImage)
			return
		}

		if let editedImage = editedImage {
			storageService.loadImage(filename: editedImage.imageFileName) { image in
				guard let storedImage = image else {
					assertionFailure(AlertMessages.noStoredData)
					return
				}
				imageProcessor.initialImage = storedImage.resized(toWidth: EditingScreenMetrics.scaleImageWidth)
				imageProcessor.tuneSettings = editedImage.tuneSettings
				previews = imageProcessor.filtersPreviews(image: storedImage.resized(toWidth:
					EditingScreenMetrics.previewImageSize) ?? storedImage)
			}
		}
	}

	func saveImageAsNew() {
		guard let currentImage = originalImage else {
			editingScreen?.showErrorAlert(title: AlertMessages.error, message: AlertMessages.nothingToSave, dismiss: true)
			return
		}
		guard let previewImage = self.imageProcessor.tunedImage?.resized(toWidth: EditingScreenMetrics.previewImageSize)
			else {
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

		guard let previewImage = self.imageProcessor.tunedImage?.resized(toWidth: EditingScreenMetrics.previewImageSize)
			else {
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

	func showActivityController(with dataItem: Data?) {
		guard let imageData = dataItem else { return }

		let activityVC = UIActivityViewController(activityItems: [imageData], applicationActivities: [])

		activityVC.completionWithItemsHandler = { _, _, _, error in
			if let error = error {
				self.editingScreen?.showAttentionAlert(title: "Error", message: error.localizedDescription)
			}
		}
		DispatchQueue.main.async { [weak self] in
			self?.editingScreen?.showActivityVC(activityVC)
		}
	}
}

// MARK: - IEditingScreenPresenter Methods
extension EditingScreenPresenter: IEditingScreenPresenter
{
	func onResetTapped() {
		guard let actualSettings = imageProcessor.tuneSettings else { return }
		let defaults = TuneSettings()
		if actualSettings != defaults {
			let action = UIAlertAction(title: "Continue".localized, style: .destructive) { [weak self ] _ in
				self?.imageProcessor.tuneSettings = defaults
				self?.editingScreen?.unselectAutoEnhanceButton()
				switch self?.editingScreen?.currentEditingType {
				case .filters: self?.editingScreen?.showFiltersTool()
				case .tune: self?.editingScreen?.showTuneTools()
				case .rotation: self?.editingScreen?.showRotationTool()
				default: break
				}
			}
			editingScreen?.showResetAlert(
				title: AlertMessages.resetTitle,
				message: AlertMessages.resetMessage,
				yesAction: action)
		}
	}

	func onAutoEnchanceTapped(value: Bool) {
		imageProcessor.tuneSettings?.autoEnchancement = value
	}

	func onCancelTapped() {
		editingScreen?.showAttentionAlert(title: AlertMessages.cancelTappedTitle, message: AlertMessages.cancelTappedMessage)
	}

	func onSaveTapped() {
		if originalImage != nil {
			saveImageAsNew()
		}
		else {
			saveExistingImage()
		}
		imageProcessor.clearContexCache()
	}

	func onShareTapped() {
		imageProcessor.fullSizeTunedImage { [weak self] tunedImage in
			guard let image = tunedImage else { return }
			if let data = image.pngData() {
				let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: [])
				self?.editingScreen?.showActivityVC(activityVC)
			}
		}
	}

	func getInitialImage() -> UIImage? {
		if let image = originalImage { return image }
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
	}

	func onRotateClockwiseTapped() {
		imageProcessor.tuneSettings?.rotationAngle -= TuneSettingsDefaults.rotationAngleStep
	}
}

// MARK: - IImageProcessorOutputSource Methods
extension EditingScreenPresenter: IImageProcessorOutputSource
{
	func getOriginal(_ image: (UIImage?) -> Void) {
		if let originalImage = originalImage {
			image(originalImage)
			return
		}

		if let editedImage = editedImage {
			storageService.loadImage(filename: editedImage.imageFileName) { storageImage in
				image(storageImage)
			}
		}
	}

	func updateImage(image: UIImage?) { editingScreen?.updateImageView(image: image) }
}
