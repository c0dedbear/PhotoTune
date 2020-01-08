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
	private let sizeForDescriptionLabel: CGFloat = 17
	private let sizeForAddingLabel: CGFloat = 25
	private let sizeForAddingButton: CGFloat = 20

	private lazy var addingLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.text = "Add the image"
		label.font = label.font.withSize(sizeForAddingLabel)
		label.textColor = UIColor(red: 0.231, green: 0.231, blue: 0.231, alpha: 1)
		return label
	}()

	private lazy var descriptionLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.text = "Сlick button to add image"
		label.font = label.font.withSize(sizeForDescriptionLabel)
		label.numberOfLines = 2
		label.textColor = UIColor(red: 0.663, green: 0.663, blue: 0.69, alpha: 1)
		return label
	}()

	lazy var addingButton: UIButton = {
		let button = UIButton()
		button.setTitle("ADD", for: .normal)
		button.backgroundColor = UIColor(red: 0.475, green: 0.588, blue: 0.604, alpha: 1)
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 16
		button.titleLabel?.font = button.titleLabel?.font.withSize(sizeForAddingButton)
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(addingLabel)
		addSubview(descriptionLabel)
		addSubview(addingButton)
		makeConstraints()
		backgroundColor = .white
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func makeConstraints() {
		addingButton.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		addingLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			addingButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			addingButton.centerYAnchor.constraint(equalTo: centerYAnchor),
			addingButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),

			descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			descriptionLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
			descriptionLabel.bottomAnchor.constraint(equalTo: addingButton.topAnchor, constant: -20),

			addingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			addingLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -10),
		])
	}
}
