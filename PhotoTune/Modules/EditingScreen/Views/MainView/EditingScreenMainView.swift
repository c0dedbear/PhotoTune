//
//  EditingScreenMainView.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IFilterCollectionViewDelegate: AnyObject
{
	func imageWithFilter(index: Int) -> UIImage
}

protocol IFilterCollectionViewDataSource: AnyObject
{
	var filtersCount: Int { get }

	func cellTitleFor(index: Int) -> String
	func cellImageFor(index: Int) -> UIImage
}

final class EditingScreenMainView: UIView
{
	private var imageView = UIImageView()
	private var currentEditingView = UIView()

	private lazy var filtersCollectionView = FiltersCollectionView()
	private lazy var tuneView = TuneView()
	private lazy var rotationView = RotationView()

	weak var filterCollectionViewDelegate: IFilterCollectionViewDelegate?
	weak var filtersCollectionViewDataSource: IFilterCollectionViewDataSource?

	var heightForCell: CGFloat { imageView.bounds.height / 3 }

	init() {
		super.init(frame: .zero)
		filtersCollectionView.delegate = self
		filtersCollectionView.dataSource = self
		setupView()
		setConstraints()
		addTools()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		backgroundColor = .white
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = EditingScreenMetrics.filterCellCornerRadius
		addSubview(imageView)
		addSubview(currentEditingView)
	}

	private func setConstraints() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		currentEditingView.translatesAutoresizingMaskIntoConstraints = false

		imageView.anchor(top: safeAreaLayoutGuide.topAnchor,
						 leading: leadingAnchor,
						 bottom: nil,
						 trailing: trailingAnchor)

		imageView.heightAnchor.constraint(
			equalTo: safeAreaLayoutGuide.heightAnchor,
			multiplier: 0.66).isActive = true

		currentEditingView.anchor(top: imageView.bottomAnchor,
								  leading: leadingAnchor,
								  bottom: safeAreaLayoutGuide.bottomAnchor,
								  trailing: trailingAnchor)
	}

	private func addTools() {
		currentEditingView.addSubview(filtersCollectionView)
		filtersCollectionView.fillSuperview()
		hideAllToolsViews(except: .filters)
	}

	func setImage(_ image: UIImage) {
		imageView.image = image
	}

	func hideAllToolsViews(except: EditingType) {
		currentEditingView.subviews.forEach { $0.isHidden = true }
		switch except {
		case .filters: filtersCollectionView.animatedAppearing()
		case .tune: tuneView.animatedAppearing()
		case .rotation: rotationView.animatedAppearing()
		}
	}
}
