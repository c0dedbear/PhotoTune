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
	func setImage(_ image: UIImage)
	func rotateImage()
	func showFiltersCollection()
	func showSlidersView()
	func showRotationView()
	func changeCurrentEditingType(with: EditingType)
}

final class EditingScreenViewController: UIViewController
{
	// MARK: Properties
	private let presenter: IEditingScreenPresenter

	private var currentEditingType: EditingType = .filters {
		didSet { title = currentEditingType.rawValue }
	}

	private var toolBarButtons = [ToolBarButton]()

	private var imageView = UIImageView()
	private var filtersCollectionView: UICollectionView?
	private var slidersView: UIView?
	private var rotationView: UIView?

	// MARK: Initialization
	init(presenter: IEditingScreenPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: VC Life Cycle Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
		setupNavigationBar()
		setupToolBar()
	}

	// MARK: Private Methods
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
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

		let filtersButton = ToolBarButton()
		filtersButton.setImage(#imageLiteral(resourceName: "colormodeFilled"), for: .normal)
		filtersButton.editingType = .filters
		filtersButton.isSelected = true
		toolBarButtons.append(filtersButton)

		let tuneButton = ToolBarButton()
		tuneButton.setImage(#imageLiteral(resourceName: "tuneFilled"), for: .normal)
		tuneButton.editingType = .tune
		toolBarButtons.append(tuneButton)

		let rotateButton = ToolBarButton()
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

	// MARK: Objc Methods
	@objc private func cancelTapped() {
		//dismiss VC
	}

	@objc private func doneTapped() {
		//save edited image
	}

	@objc private func toolBarButtonTapped(_ sender: ToolBarButton) {
		toolBarButtons.forEach { $0.isSelected = false }
		sender.isSelected = true
	}
}

	// MARK: - IEditingScreen
extension EditingScreenViewController: IEditingScreen
{

	func changeCurrentEditingType(with: EditingType) {
		currentEditingType = with
	}

	func rotateImage() {
		//implementation
	}

	func setImage(_ image: UIImage) {
		imageView.image = image
	}

	func showFiltersCollection() {
		//implementation
	}

	func showSlidersView() {
		//implementation
	}

	func showRotationView() {
		//implementation
	}
}
