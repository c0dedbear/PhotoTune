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
}

final class EditingScreenViewController: UIViewController
{
	//MARK: Properties
	private let presenter: IEditingScreenPresenter

	private var imageView = UIImageView()
	private var filtersCollectionView: UICollectionView?
	private var slidersView: UIView?
	private var rotationView: UIView?

	init(presenter: IEditingScreenPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	//MARK: VC Life Cycle Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationBar()
		setupToolBar()
	}
	//MARK: Private Methods
	private func setupNavigationBar() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(cancelTapped))

		navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .done,
			target: self,
			action: #selector(doneTapped))
	}

	private func setupToolBar() {
		let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		toolbarItems = [spacer, add, spacer, add, spacer, add, spacer]
		navigationController?.toolbar.tintColor = .black
		navigationController?.setToolbarHidden(false, animated: false)
	}

	@objc private func cancelTapped() {
		//dismiss VC
	}

	@objc private func doneTapped() {
		//save edited image
	}
}

	//MARK: - IEditingScreen
extension EditingScreenViewController: IEditingScreen
{
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
