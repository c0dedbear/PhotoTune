//
//  EditingScreenViewController.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class EditingScreenViewController: UIViewController
{
	// MARK: Private Properties
	private let presenter: IEditingScreenPresenter
	private var currentEditingType: EditingType = .filters {
		didSet { title = currentEditingType.rawValue }
	}

	private var toolBarButtons = [ToolBarButton]()
	private var mainView = EditingScreenMainView()

	private lazy var filtersCollectionView = FiltersCollectionView()
	private lazy var tuneView = TuneView()
	private lazy var rotationView = RotationView()

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
	override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
		setupNavigationBar()
		setupToolBar()
		mainView.setImage(presenter.getImage())
		setupFiltersCollectionView()
	}
}
	// MARK: - Internal methods and Properties
extension EditingScreenViewController
{
	var filtersCount: Int { presenter.getFiltersCount() }

	var filterCellHeight: CGFloat { mainView.heightForCell }

	func setFilteredImage(of filterIndex: Int) {
		mainView.setImage(presenter.getFilteredImageFor(filterIndex: filterIndex))
	}

	func cellTitleFor(index: Int) -> String {
		presenter.getFilterTitle(index: index)
	}

	func cellImageFor(index: Int) -> UIImage {
		presenter.getFilterPreview(index: index)
	}

	func hideAllToolsViews(except: EditingType) {
		mainView.subviews.forEach { $0.isHidden = true }
		switch except {
		case .filters: filtersCollectionView.animatedAppearing()
		case .tune: tuneView.animatedAppearing()
		case .rotation: rotationView.animatedAppearing()
		}
	}
}
	// MARK: - Private Methods
private extension EditingScreenViewController
{
	private func setupNavigationBar() {
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

	private func setupToolBar() {
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

	private func setupFiltersCollectionView() {
		filtersCollectionView.delegate = self
		filtersCollectionView.dataSource = self
		mainView.addSubview(filtersCollectionView)
		filtersCollectionView.fillSuperview()
		showFiltersCollection()
	}
}

// MARK: - Objc Handling Methods
extension EditingScreenViewController
{
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
