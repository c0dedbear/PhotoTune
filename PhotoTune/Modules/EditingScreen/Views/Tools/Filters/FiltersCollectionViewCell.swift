//
//  FiltersCollectionViewCell.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 20.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class FiltersCollectionViewCell: ToolCollectionViewCell
{
	static let identifier = "FiltersCollectionViewCell"

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
			setTextColor(isSelected && isHighlighted == false ? .darkText : .lightGray)
		}
	}

	override func layoutSubviews() {
		addShadow()
	}
}
