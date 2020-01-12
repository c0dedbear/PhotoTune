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
	var currentImage: UIImage? { get }

	func showFiltersTool()
	func showTuneTools()
	func showRotationTool()
	func showAcitivityVC(_ vc: UIActivityViewController)
	func showErrorAlert(title: String?, message: String?, dismiss: Bool)
	func showAttentionAlert(title: String?, message: String?)
	func dismiss(toRoot: Bool, completion: (() -> Void)?)
}

final class EditingScreenViewController: UIViewController
{
	// MARK: Private Properties
	private let presenter: IEditingScreenPresenter

	private var currentEditingType: EditingType = .filters {
		didSet {
			if currentEditingType == .tune {
				navigationItem.titleView = autoEnchaneButton
			}
			else {
				navigationItem.titleView = nil
				title = currentEditingType.rawValue
			}
		}
	}

	private let autoEnchaneButton = AutoEnchanceButton()
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
		currentEditingType = .filters
	}
}
	// MARK: - Private Methods
private extension EditingScreenViewController
{
	func setupNavigationBar() {
		if #available(iOS 13.0, *) {
			navigationController?.navigationBar.tintColor = .label
		}
		else {
			navigationController?.navigationBar.tintColor = .black
		}

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
	@objc func cancelTapped() { presenter.onCancelTapped() }
	@objc func shareTapped() { presenter.onShareTapped() }
	@objc func saveTapped() { presenter.onSaveTapped() }

	@objc func toolBarButtonTapped(_ sender: ToolBarButton) {
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
	var currentImage: UIImage? { editingView.currentImage }

	func dismiss(toRoot: Bool, completion: (() -> Void)?) {
		if toRoot {
			if let rootScreen = self.view.window?.rootViewController as? UINavigationController
			{
				dismiss(animated: true) {
					rootScreen.popToRootViewController(animated: false)
				}
			}
		}
		else {
			dismiss(animated: true, completion: completion)
		}
	}

	func showAcitivityVC(_ vc: UIActivityViewController) { present(vc, animated: true) }
	func showFiltersTool() { editingView.hideAllToolsViews(except: .filters) }
	func showTuneTools() { editingView.hideAllToolsViews(except: .tune) }
	func showRotationTool() { editingView.hideAllToolsViews(except: .rotation) }

	func showErrorAlert(title: String?, message: String?, dismiss: Bool) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
			if dismiss { self?.dismiss(toRoot: true, completion: nil) }
		}
		if #available(iOS 13.0, *) {
			ac.view.tintColor = .label
		}
		ac.addAction(okAction)
		present(ac, animated: true)
	}

	func showAttentionAlert(title: String?, message: String?) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
			self?.dismiss(toRoot: false, completion: nil)
		}
		let cancelAction = UIAlertAction(title: "No", style: .cancel)
		if #available(iOS 13.0, *) {
			ac.view.tintColor = .label
		}
		ac.addAction(yesAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}
}

// MARK: - IToolViewDelegate
extension EditingScreenViewController: IToolViewDelegate
{
	func rotateClockwise() {
		presenter.onRotateClockwiseTapped { image in
			editingView.setImage(image)
		}
	}

	func rotateAntiClockwise() {
		presenter.onRotateAntiClockwiseTapped { image in
		editingView.setImage(image)
		}
	}

	func loadTuneSettings() -> TuneSettings? {
		presenter.getTuneSettings()
	}

	func applyTuneSettings(_ settings: TuneSettings) {
		presenter.onSaveTuneSettingsTapped(save: settings) { image in
			editingView.setImage(image)
		}
	}

	func imageWithFilter(index: Int) -> UIImage? {
		presenter.getFilteredImageFor(filterIndex: index)
	}
}
	// MARK: - IToolCollectionViewDataSource
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

	func showChangesIndicator(for tuneTool: TuneTool?) -> Bool? {
		switch tuneTool {
		case .brightness:
			return presenter.getTuneSettings()?.brightnessIntensity.roundToDecimal(3) != TuneSettingsDefaults.brightnessIntensity
		case .contrast:
			return presenter.getTuneSettings()?.contrastIntensity != TuneSettingsDefaults.contrastIntensity
		case .saturation:
			return presenter.getTuneSettings()?.saturationIntensity != TuneSettingsDefaults.saturationIntensity
		case .vignette:
			return presenter.getTuneSettings()?.vignetteIntensity != TuneSettingsDefaults.vignetteIntensity
		case .none:
			return nil
		}
	}
}
