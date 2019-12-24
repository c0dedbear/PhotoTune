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
			guard isSelected == false else { return }
			animateScale(condition: isHighlighted)
		}
	}

	override var isSelected: Bool {
		didSet {
			if #available(iOS 13.0, *) {
				setTextColor(isSelected && isHighlighted == false ? .label : .tertiaryLabel)
			}
			else {
				setTextColor(isSelected && isHighlighted == false ? .darkText : .lightGray)
			}
		}
	}

	override func layoutSubviews() {
		addShadow()
	}
}
