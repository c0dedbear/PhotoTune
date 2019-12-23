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
	private var currentEditingType: EditingType = .filters {
		didSet { title = currentEditingType.rawValue }
	}

	private let mainView = EditingScreenMainView()
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
		view = mainView
		mainView.filterCollectionViewDelegate = self
		mainView.filtersCollectionViewDataSource = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
		setupNavigationBar()
		setupToolBar()
		mainView.setImage(presenter.getImage())
	}
}
	// MARK: - IFilterCollectionViewDelegate
extension EditingScreenViewController: IFilterCollectionViewDelegate
{
	func imageWithFilter(index: Int) -> UIImage {
		presenter.getFilteredImageFor(filterIndex: index)
	}
}
	// MARK: - IFilterCollectionViewDataSource
extension EditingScreenViewController: IFilterCollectionViewDataSource
{
	var filtersCount: Int { presenter.getFiltersCount() }

	func cellTitleFor(index: Int) -> String {
		presenter.getFilterTitle(index: index)
	}

	func cellImageFor(index: Int) -> UIImage {
		presenter.getFilterPreview(index: index)
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

		navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .done,
			target: self,
			action: #selector(doneTapped))

		currentEditingType = .filters
	}

	func setupToolBar() {
		guard let height = navigationController?.toolbar.bounds.height else { return }
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

		let filtersButton = ToolBarButton(toolBarHeight: height)
		filtersButton.setImage(#imageLiteral(resourceName: "colormodeFilled"), for: .normal)
		filtersButton.editingType = .filters
		filtersButton.isSelected = true
		toolBarButtons.append(filtersButton)

		let tuneButton = ToolBarButton(toolBarHeight: height)
		tuneButton.setImage(#imageLiteral(resourceName: "tuneFilled"), for: .normal)
		tuneButton.editingType = .tune
		toolBarButtons.append(tuneButton)

		let rotateButton = ToolBarButton(toolBarHeight: height)
		rotateButton.setImage(#imageLiteral(resourceName: "rotateFilled"), for: .normal)
		rotateButton.editingType = .rotation
		toolBarButtons.append(rotateButton)

		let filtersBarButton = UIBarButtonItem(customView: filtersButton)
		let tuneBarButton = UIBarButtonItem(customView: tuneButton)
		let rotateBarButton = UIBarButtonItem(customView: rotateButton)

		toolbarItems = [spacer, filtersBarButton, spacer, tuneBarButton, spacer, rotateBarButton, spacer]

		toolBarButtons.forEach { $0.addTarget(self, action: #selector(toolBarButtonTapped(_:)), for: .touchUpInside)
		}

		navigationController?.toolbar.tintColor = .black
		navigationController?.setToolbarHidden(false, animated: false)
	}

	// MARK: Objc Handling Methods
	@objc private func cancelTapped() {
		//dismiss VC
	}

	@objc private func doneTapped() {
		//save edited image
	}

	@objc private func toolBarButtonTapped(_ sender: ToolBarButton) {
		guard let editingType = sender.editingType else { return }
		guard editingType != currentEditingType else { return }

		toolBarButtons.forEach { $0.isSelected = false }
		sender.isSelected = true

		switch editingType {
		case .filters:
			presenter.filtersToolPressed()
			currentEditingType = .filters
		case .tune:
			presenter.tuneToolPressed()
			currentEditingType = .tune
		case .rotation:
			presenter.rotationToolPressed()
			currentEditingType = .rotation
		}
	}
}
	// MARK: - IEditingScreen
extension EditingScreenViewController: IEditingScreen
{
	func showFiltersTool() {
		mainView.hideAllToolsViews(except: .filters)
	}

	func showTuneTools() {
		mainView.hideAllToolsViews(except: .tune)
	}

	func showRotationTool() {
		mainView.hideAllToolsViews(except: .rotation)
	}
}
