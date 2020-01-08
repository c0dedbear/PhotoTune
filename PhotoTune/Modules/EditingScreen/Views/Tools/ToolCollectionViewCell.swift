//
//  ToolCollectionViewCell.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//  swiftlint:disable required_final

import UIKit

class ToolCollectionViewCell: UICollectionViewCell
{

	private var imageView = UIImageView()
	private var title = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		initialSetup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func initialSetup() {
		imageView.contentMode = .scaleAspectFill
		imageView.backgroundColor = .white
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = EditingScreenMetrics.filterCellCornerRadius
		addSubview(imageView)

		title.textColor = .systemGray
		title.textAlignment = .center
		addSubview(title)

		setConstraints()
	}

	private func setConstraints() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		title.translatesAutoresizingMaskIntoConstraints = false
		imageView.fillSuperview()

		title.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.2).isActive = true
		title.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
		title.anchor(
			top: nil,
			leading: nil,
			bottom: imageView.topAnchor,
			trailing: nil,
			padding: .init(top: 0, left: 0, bottom: 10, right: 0))
	}

	func setTitle(_ title: String) { self.title.text = title }
	func setFont(_ font: UIFont) { title.font = font }
	func setTextColor(_ color: UIColor) { title.textColor = color }
	func setImageViewContentMode(mode: ContentMode) { imageView.contentMode = mode }
	func setImage(_ image: UIImage?) { imageView.image = image }
	func setBackgroundColor(_ color: UIColor) { imageView.backgroundColor = color }
	func setBorderToImage(color: UIColor, width: CGFloat) {
		imageView.layer.borderColor = color.cgColor
		imageView.layer.borderWidth = width
	}

	func addShadow() {
		layer.shadowRadius = 15
		layer.shadowOpacity = 0.3
		layer.shadowOffset = CGSize(width: 0, height: 5)
	}

	func animateScale(condition: Bool) {
		if condition {
			UIView.animate(
				withDuration: EditingScreenMetrics.tuneCellTapAnimationDuration,
				delay: 0,
				options: .curveEaseOut,
				animations: {
					self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
				}
			)
		}
		else {
			UIView.animate(
				withDuration: EditingScreenMetrics.tuneCellTapAnimationDuration,
				delay: 0,
				options: .curveEaseIn,
				animations: {
					self.transform = CGAffineTransform(scaleX: 1, y: 1)
				}
			)
		}
	}
}
