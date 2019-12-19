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

	override func viewDidLoad() {
		super.viewDidLoad()
	}
}

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
