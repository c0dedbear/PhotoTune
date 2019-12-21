//
//  FiltersCollectionViewCell.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 20.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class FiltersCollectionViewCell: UICollectionViewCell
{

	static let identifier = "FiltersCollectionViewCell"

	private var filterImageView = UIImageView()
	private var title = UILabel()

	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				guard isSelected == false else { return }
				UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
					self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
				}, completion: nil)
			}
			else {
				UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
					self.transform = CGAffineTransform(scaleX: 1, y: 1)
				}, completion: nil)
			}
		}
	}

	override var isSelected: Bool {
		didSet {
			title.textColor = isSelected && isHighlighted == false ? .darkText : .lightGray
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		initialSetup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func initialSetup() {
		filterImageView.backgroundColor = .lightGray
		filterImageView.contentMode = .scaleToFill
		filterImageView.clipsToBounds = true
		filterImageView.layer.cornerRadius = EditinScreenMetrics.filterCellCornerRadius
		addSubview(filterImageView)

		title.textColor = .lightGray
		title.adjustsFontSizeToFitWidth = true
		title.textAlignment = .center
		addSubview(title)

		setConstraints()
		addShadow()
	}

	private func addShadow() {
		layer.shadowRadius = 15
		layer.shadowOpacity = 0.3
		layer.shadowOffset = CGSize(width: 0, height: 5)
	}

	private func setConstraints() {
		filterImageView.translatesAutoresizingMaskIntoConstraints = false
		title.translatesAutoresizingMaskIntoConstraints = false
		filterImageView.fillSuperview()

		title.widthAnchor.constraint(equalTo: filterImageView.widthAnchor, multiplier: 0.95).isActive = true
		title.centerXAnchor.constraint(equalTo: filterImageView.centerXAnchor).isActive = true
		title.anchor(
			top: nil,
			leading: nil,
			bottom: filterImageView.topAnchor,
			trailing: nil,
			padding: .init(top: 0, left: 0, bottom: 10, right: 0))
	}

	func setTitle(_ title: String) {
		self.title.text = title
	}

	func setImage(_ image: UIImage) {
		filterImageView.image = image
	}
}
