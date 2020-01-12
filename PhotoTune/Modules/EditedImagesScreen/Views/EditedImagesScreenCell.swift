//
//  EditedImagesScreenCell.swift
//  PhotoTune
//
//  Created by MacBook Air on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

//swiftlint:disable explicit_false

import UIKit

final class EditedImagesScreenCell: ImageCollectionViewCell
{
	let highlightIndicator = UIView()
	let selectIndicator = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureCell()
		setupConstraints()
	}

	override var isHighlighted: Bool {
	  didSet {
		highlightIndicator.isHidden = !isHighlighted
	  }
	}

	override var isSelected: Bool {
	  didSet {
		highlightIndicator.isHidden = !isSelected
		selectIndicator.isHidden = !isSelected
	  }
	}

	private func configureCell() {
		layer.shadowRadius = 15
		layer.shadowOpacity = 0.5
		layer.shadowOffset = CGSize(width: 5, height: 5)

		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 20

		highlightIndicator.clipsToBounds = true
		highlightIndicator.isHidden = true
		addSubview(highlightIndicator)
		highlightIndicator.layer.cornerRadius = 20
		highlightIndicator.backgroundColor = UIColor(white: 0.3, alpha: 0.5)

		selectIndicator.isHidden = true
		addSubview(selectIndicator)
		selectIndicator.clipsToBounds = true
		selectIndicator.image = UIImage(named: "checkmark")
	}

	private func setupConstraints() {
		selectIndicator.translatesAutoresizingMaskIntoConstraints = false
		highlightIndicator.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			highlightIndicator.leftAnchor.constraint(equalTo: leftAnchor),
			highlightIndicator.rightAnchor.constraint(equalTo: rightAnchor),
			highlightIndicator.topAnchor.constraint(equalTo: topAnchor),
			highlightIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),

			selectIndicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15),
			selectIndicator.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.15),
			selectIndicator.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
			selectIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
		])
	}
}
