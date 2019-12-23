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
	func imageWithFilter(index: Int) -> UIImage?
}

protocol IFilterCollectionViewDataSource: AnyObject
{
	var itemsCount: Int { get }
	var currentEditingType: EditingType { get }

	func cellTitleFor(index: Int) -> String
	func cellImageFor(index: Int) -> UIImage?
}

final class EditingScreenMainView: UIView
{
	private let imageView = UIImageView()
	private let editingView = UIView()

	private let filtersTools = ToolsCollectionView()
	private let tuneTools = ToolsCollectionView()
	private let rotationTool = RotationView()

	weak var filterCollectionViewDelegate: IFilterCollectionViewDelegate?
	weak var filtersCollectionViewDataSource: IFilterCollectionViewDataSource?

	var heightForCell: CGFloat { imageView.bounds.height / 3 }

	init() {
		super.init(frame: .zero)
		filtersTools.delegate = self
		filtersTools.dataSource = self
		tuneTools.delegate = self
		tuneTools.dataSource = self
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
		addSubview(editingView)
	}

	private func setConstraints() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		editingView.translatesAutoresizingMaskIntoConstraints = false

		imageView.anchor(top: safeAreaLayoutGuide.topAnchor,
						 leading: leadingAnchor,
						 bottom: nil,
						 trailing: trailingAnchor)

		imageView.heightAnchor.constraint(
			equalTo: safeAreaLayoutGuide.heightAnchor,
			multiplier: 0.66).isActive = true

		editingView.anchor(top: imageView.bottomAnchor,
								  leading: leadingAnchor,
								  bottom: safeAreaLayoutGuide.bottomAnchor,
								  trailing: trailingAnchor)
	}

	private func addTools() {
		editingView.addSubview(filtersTools)
		filtersTools.fillSuperview()
		editingView.addSubview(tuneTools)
		tuneTools.fillSuperview()
		hideAllToolsViews(except: .filters)
	}

	func setImage(_ image: UIImage) {
		imageView.image = image
	}

	func hideAllToolsViews(except: EditingType) {
		editingView.subviews.forEach { $0.isHidden = true }
		switch except {
		case .filters:
			filtersTools.reloadData()
			filtersTools.animatedAppearing()
		case .tune:
			tuneTools.reloadData()
			tuneTools.animatedAppearing()
		case .rotation: rotationTool.animatedAppearing()
		}
	}
}
