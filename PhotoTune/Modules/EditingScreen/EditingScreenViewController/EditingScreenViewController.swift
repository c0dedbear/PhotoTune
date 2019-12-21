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
	private var imageView = UIImageView()
	private var currentEditingView = UIView()

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
		setupView()
		imageView.image = presenter.getImage()
		setupFiltersCollectionView()
	}
}
	// MARK: - Internal methods and Properties
extension EditingScreenViewController
{
	var filtersCount: Int { presenter.getFiltersCount() }
	var filterCellHeight: CGFloat { imageView.bounds.height / 3 }

	func setFilteredImage(of filterIndex: Int) {
		imageView.image = presenter.getFilteredImageFor(filterIndex: filterIndex)
	}

	func cellTitleFor(index: Int) -> String {
		presenter.getFilterTitle(index: index)
	}

	func cellImageFor(index: Int) -> UIImage {
		presenter.getFilterPreview(index: index)
	}

	func hideAllToolsViews(except: EditingType) {
		currentEditingView.subviews.forEach { $0.isHidden = true }
		switch except {
		case .filters: filtersCollectionView.isHidden = false
		case .tune: tuneView.isHidden = false
		case .rotation: rotationView.isHidden = false
		}
	}
}
	// MARK: - Private Methods
private extension EditingScreenViewController
{
	private func setupView() {
		view.backgroundColor = .white
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = EditinScreenMetrics.filterCellCornerRadius
		view.addSubview(imageView)
		view.addSubview(currentEditingView)
		setConstraints()
	}

	private func setConstraints() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		currentEditingView.translatesAutoresizingMaskIntoConstraints = false

		imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
						 leading: view.leadingAnchor,
						 bottom: nil,
						 trailing: view.trailingAnchor)

		imageView.heightAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.heightAnchor,
			multiplier: 0.66).isActive = true

		currentEditingView.anchor(top: imageView.bottomAnchor,
								  leading: view.leadingAnchor,
								  bottom: view.safeAreaLayoutGuide.bottomAnchor,
								  trailing: view.trailingAnchor)
	}

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
		currentEditingView.addSubview(filtersCollectionView)
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
		case .filters: presenter.filtersToolPressed()
		case .tune: presenter.tuneToolPressed()
		case .rotation: presenter.rotationToolPressed()
		}
	}
}
