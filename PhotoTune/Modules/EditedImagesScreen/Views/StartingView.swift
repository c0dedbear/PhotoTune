//
//  StartingView.swift
//  PhotoTune
//
//  Created by MacBook Air on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class AddingView: UIView
{
	let addingButton = UIButton()
	private let descriptionLabel = UILabel()
	private let imageView = UIImageView(image: UIImage(named: "StartView"))

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(descriptionLabel)
		addSubview(addingButton)
		addSubview(imageView)
		makeConstraints()
		configureView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configureView() {
		if #available(iOS 13.0, *) {
			backgroundColor = .systemBackground
			addingButton.backgroundColor = .darkGray
			addingButton.setTitleColor(.systemBackground, for: .normal)
			descriptionLabel.textColor = .label
		}
		else {
			backgroundColor = .white
			addingButton.backgroundColor = .darkGray
			addingButton.setTitleColor(.white, for: .normal)
			descriptionLabel.textColor = .darkGray
		}
		imageView.contentMode = .scaleAspectFit
		imageView.alpha = 0.3

		descriptionLabel.textAlignment = .center
		descriptionLabel.text = "Сlick button to add image".localized
		descriptionLabel.font = descriptionLabel.font.withSize(StartingViewSize.forDescriptionLabel)
		descriptionLabel.numberOfLines = 0

		addingButton.setTitle("ADD".localized, for: .normal)
		addingButton.layer.cornerRadius = StartingViewSize.forButtonCornerRadius
		addingButton.titleLabel?.font = addingButton.titleLabel?.font.withSize(StartingViewSize.forAddingButton)
	}

	private func makeConstraints() {
		addingButton.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		imageView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			imageView.leftAnchor.constraint(equalTo: leftAnchor),
			imageView.rightAnchor.constraint(equalTo: rightAnchor),
			imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -80),

			descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			descriptionLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
			descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),

			addingButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			addingButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
			addingButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
		])
	}
}
