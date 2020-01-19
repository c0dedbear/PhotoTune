//
//  EditingScreenViewController.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

// MARK: Protocol IEditingScreen
protocol IEditingScreen: AnyObject
{
	var currentEditingType: EditingType { get set }
	var currentImage: UIImage? { get }

	func showFiltersTool()
	func showTuneTools()
	func showRotationTool()
	func showActivityVC(_ vc: UIActivityViewController)
	func showErrorAlert(title: String?, message: String?, dismiss: Bool)
	func showAttentionAlert(title: String?, message: String?)
	func showResetAlert(title: String?, message: String?, yesAction: UIAlertAction)
	func dismiss(toRoot: Bool, completion: (() -> Void)?)
	func updateImageView(image: UIImage?)
	func unselectAutoEnhanceButton()
	func showActivityIndicator()
	func hideActivityIndicator()
}
// MARK: - EditingScreenViewController
final class EditingScreenViewController: UIViewController
{
	// MARK: Private Properties
	private let presenter: IEditingScreenPresenter
	private let autoEnchanceButton = AutoEnchanceButton()
	private let editingView = EditingView()
	private var toolBarButtons = [ToolBarButton]()

	var currentEditingType: EditingType = .filters

	// MARK: Initialization
	init(presenter: IEditingScreenPresenter) {
		self.presenter = presenter
		autoEnchanceButton.isSelected = presenter.getTuneSettings()?.autoEnchancement ?? false
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
		autoEnchanceButton.addTarget(self, action: #selector(autoEnchanceTapped), for: .touchUpInside)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationBar()
		setupToolBar()
		setupEditingView()
	}
}
	// MARK: - Private Methods
private extension EditingScreenViewController
{
	func setupEditingView() {
		editingView.hideAllToolsViews(except: currentEditingType)
		editingView.setImage(presenter.getInitialImage())
		currentEditingType = .filters
	}
	func setupNavigationBar() {

		let cancelButton = UIBarButtonItem(
		barButtonSystemItem: .cancel,
		target: self,
		action: #selector(cancelTapped))

		let resetButton = UIBarButtonItem(
			image: UIImage(named: "reset"),
			style: .plain,
			target: self,
			action: #selector(resetTapped))

		let saveButton = UIBarButtonItem(
			barButtonSystemItem: .save,
			target: self,
			action: #selector(saveTapped))

		let shareButton = UIBarButtonItem(
			barButtonSystemItem: .action,
		target: self,
		action: #selector(shareTapped))

		navigationItem.leftBarButtonItems = [cancelButton, resetButton]
		navigationItem.rightBarButtonItems = [saveButton, shareButton]

		if EditingScreenMetrics.screenSize.width <= EditingScreenMetrics.smallScreenSizeWidth {
			let attributes: [NSAttributedString.Key: Any]? = [.font: UIFont.systemFont(ofSize: 14, weight: .regular)]
			cancelButton.setTitleTextAttributes(attributes, for: .normal)
			saveButton.setTitleTextAttributes(attributes, for: .normal)
			cancelButton.setTitleTextAttributes(attributes, for: .highlighted)
			saveButton.setTitleTextAttributes(attributes, for: .highlighted)
		}
			navigationItem.titleView = autoEnchanceButton
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
		}
		else {
			filtersButton.setImage(ToolBarImage.filters, for: .normal)
			tuneButton.setImage(ToolBarImage.tune, for: .normal)
			rotateButton.setImage(ToolBarImage.rotation, for: .normal)
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
	@objc func resetTapped() { presenter.onResetTapped() }
	@objc func cancelTapped() { presenter.onCancelTapped() }
	@objc func shareTapped() {
		showActivityIndicator()
		presenter.onShareTapped()
	}
	@objc func saveTapped() { presenter.onSaveTapped() }

	@objc func autoEnchanceTapped() {
		autoEnchanceButton.isSelected.toggle()
		if autoEnchanceButton.isSelected {
			let haptics = UIImpactFeedbackGenerator(style: .medium)
			haptics.impactOccurred()
		}
	presenter.onAutoEnchanceTapped(value: autoEnchanceButton.isSelected)
}

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

	func updateImageView(image: UIImage?) { editingView.setImage(image) }
	func showActivityIndicator() { view.showActivityIndicator() }
	func hideActivityIndicator() { view.removeActivityIndicator() }

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

	func showActivityVC(_ vc: UIActivityViewController) { present(vc, animated: true) }
	func showFiltersTool() { editingView.hideAllToolsViews(except: .filters) }
	func showTuneTools() { editingView.hideAllToolsViews(except: .tune) }
	func showRotationTool() { editingView.hideAllToolsViews(except: .rotation) }

	func showErrorAlert(title: String?, message: String?, dismiss: Bool) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
			if dismiss { self?.dismiss(toRoot: true, completion: nil) }
		}
		ac.addAction(okAction)
		present(ac, animated: true)
	}

	func showAttentionAlert(title: String?, message: String?) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "Yes".localized, style: .destructive) { [weak self] _ in
			self?.dismiss(toRoot: false, completion: nil)
		}
		let cancelAction = UIAlertAction(title: "No".localized, style: .cancel)
		ac.addAction(yesAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}

	func showResetAlert(title: String?, message: String?, yesAction: UIAlertAction) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel)
		ac.addAction(yesAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}

	func unselectAutoEnhanceButton() {
		autoEnchanceButton.isSelected = false
	}
}

// MARK: - IToolViewDelegate
extension EditingScreenViewController: IToolViewDelegate
{
	func rotateClockwise() {
		presenter.onRotateClockwiseTapped()
	}

	func rotateAntiClockwise() {
		presenter.onRotateAntiClockwiseTapped()
	}

	func loadTuneSettings() -> TuneSettings? {
		let settings = presenter.getTuneSettings()
		return settings
	}

	func applyTuneSettings(_ settings: TuneSettings) {
		presenter.onSaveTuneSettingsTapped(save: settings)
	}

	func applyFilterToImageWith(index: Int ) {
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
		guard let settings = presenter.getTuneSettings() else { return nil }
		switch tuneTool {
		case .brightness:
			return settings.brightnessIntensity.roundToDecimal(3) != TuneSettingsDefaults.brightnessIntensity
		case .contrast:
			return settings.contrastIntensity != TuneSettingsDefaults.contrastIntensity
		case .saturation:
			return settings.saturationIntensity != TuneSettingsDefaults.saturationIntensity
		case .sharpness:
			return settings.sharpnessIntensity != TuneSettingsDefaults.sharpnessIntensity
		case .vignette:
			return settings.vignetteIntensity != TuneSettingsDefaults.vignetteIntensity
		case .none:
			return nil
		}
	}
}
