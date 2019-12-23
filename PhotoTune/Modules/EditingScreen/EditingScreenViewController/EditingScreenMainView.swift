//
//  EditingScreenMainView.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class EditingScreenMainView: UIView
{
	private var imageView = UIImageView()
	private var currentEditingView = UIView()

	var heightForCell: CGFloat { imageView.bounds.height / 3 }

	private func setupView() {
		backgroundColor = .white
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = EditingScreenMetrics.filterCellCornerRadius
		addSubview(imageView)
		addSubview(currentEditingView)
		setConstraints()
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

	func setImage(_ image: UIImage) {
		imageView.image = image
	}
}
