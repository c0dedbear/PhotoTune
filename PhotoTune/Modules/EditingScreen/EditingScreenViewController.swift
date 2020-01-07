//
//  EditingScreenViewController.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IEditingScreen
{
	func showFiltersTool()
	func showTuneTools()
	func showRotationTool()
}

final class EditingScreenViewController: UIViewController
{
	// MARK: Private Properties
	private let presenter: IEditingScreenPresenter

	var currentEditingType: EditingType = .filters {
		didSet { title = currentEditingType.rawValue }
	}

	private let editingView = EditingView()
	private var toolBarButtons = [ToolBarButton]()

	// MARK: Initialization
	init(presenter: IEditingScreenPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: ViewController Life Cycle Methods
	override func loadView() {
		view = editingView
		editingView.toolsDelegate = self
		editingView.toolCollectionViewDataSource = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationBar()
		setupToolBar()
		editingView.hideAllToolsViews(except: currentEditingType)
		editingView.setImage(presenter.getInitialImage())
	}
}
	// MARK: - Private Methods
private extension EditingScreenViewController
{
	func setupNavigationBar() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(cancelTapped))

		let saveButton = UIBarButtonItem(
			barButtonSystemItem: .save,
			target: self,
			action: #selector(saveTapped))

		let shareButton = UIBarButtonItem(
			barButtonSystemItem: .action,
		target: self,
		action: #selector(shareTapped))

		navigationItem.rightBarButtonItems = [saveButton, shareButton]

		currentEditingType = .filters
	}

	func setupToolBar() {
		guard let height = navigationController?.toolbar.bounds.height else { return }
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

		let filtersButton = ToolBarButton(toolBarHeight: height)
		filtersButton.editingType = .filters
		filtersButton.isSelected = true
		toolBarButtons.append(filtersButton)

		let tuneButton = ToolBarButton(toolBarHeight: height)
		tuneButton.editingType = .tune
		toolBarButtons.append(tuneButton)

		let rotateButton = ToolBarButton(toolBarHeight: height)
		rotateButton.editingType = .rotation
		toolBarButtons.append(rotateButton)

		if #available(iOS 13.0, *) {
			filtersButton.setImage(UIImage(systemName: "f.circle"), for: .normal)
			tuneButton.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
			rotateButton.setImage(UIImage(systemName: "crop.rotate"), for: .normal)
			navigationController?.toolbar.tintColor = .label
		}
		else {
			filtersButton.setImage(ToolBarImage.filters, for: .normal)
			tuneButton.setImage(ToolBarImage.tune, for: .normal)
			rotateButton.setImage(ToolBarImage.rotation, for: .normal)
			navigationController?.toolbar.tintColor = .black
		}

		let filtersBarButton = UIBarButtonItem(customView: filtersButton)
		let tuneBarButton = UIBarButtonItem(customView: tuneButton)
		let rotateBarButton = UIBarButtonItem(customView: rotateButton)

		toolbarItems = [spacer, filtersBarButton, spacer, tuneBarButton, spacer, rotateBarButton, spacer]

		toolBarButtons.forEach { $0.addTarget(self, action: #selector(toolBarButtonTapped(_:)), for: .touchUpInside)
		}

		navigationController?.setToolbarHidden(false, animated: false)
	}

	// MARK: Objc Handling Methods
	@objc private func cancelTapped() {
		//dismiss VC
	}

	@objc private func shareTapped() {
		guard let data = editingView.currentImage?.pngData() else { return }

		let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: [])

		activityVC.completionWithItemsHandler = { _, _, _, error in
			if error == nil {
				//saveImage to Disk (presenter)
			}
		}

		activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(activityVC, animated: true)
	}

	@objc private func saveTapped() {
		//save edited image
	}

	@objc private func toolBarButtonTapped(_ sender: ToolBarButton) {
		guard let editingType = sender.editingType else { return }
		guard editingType != currentEditingType else { return }

		toolBarButtons.forEach { $0.isSelected = false }
		sender.isSelected = true

		switch editingType {
		case .filters:
			currentEditingType = .filters
			presenter.filtersToolPressed()
		case .tune:
			currentEditingType = .tune
			presenter.tuneToolPressed()
		case .rotation:
			currentEditingType = .rotation
			presenter.rotationToolPressed()
		case .none: break
		}
	}
}
	// MARK: - IEditingScreen
extension EditingScreenViewController: IEditingScreen
{
	func showFiltersTool() {
		editingView.hideAllToolsViews(except: .filters)
	}

	func showTuneTools() {
		editingView.hideAllToolsViews(except: .tune)
	}

	func showRotationTool() {
		editingView.hideAllToolsViews(except: .rotation)
	}
}

// MARK: - IToolCollectionViewDelegate
extension EditingScreenViewController: IToolViewDelegate
{
	func loadTuneSettings() -> TuneSettings? {
		presenter.getTuneSettings()
	}

	func applyTuneSettings(_ settings: TuneSettings) {
		presenter.whenSaveTuneSettingsTapped(save: settings) { image in
			editingView.setImage(image)
		}
	}

	func imageWithFilter(index: Int) -> UIImage? {
		presenter.getFilteredImageFor(filterIndex: index)
	}
}
	// MARK: - IToolCollectionViewDelegate
extension EditingScreenViewController: IToolCollectionViewDataSource
{
	var editingType: EditingType { currentEditingType }

	var itemsCount: Int {
		switch currentEditingType {
		case .filters: return presenter.getFiltersCount()
		case .tune: return presenter.getTuneToolsCount()
		default: return 0
		}
	}

	func dataForFilterCell(index: Int) -> (title: String, image: UIImage?) {
		presenter.getFiltersPreview(index: index)
	}

	func dataForTuneCell(index: Int) -> TuneTool {
		presenter.getTuneToolCellDataFor(index: index)
	}
}
