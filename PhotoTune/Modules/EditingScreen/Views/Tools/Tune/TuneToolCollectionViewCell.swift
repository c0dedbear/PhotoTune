//
//  TuneToolCollectionViewCell.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class TuneToolCollectionViewCell: ToolCollectionViewCell
{
	static let identifier = "TuneToolCollectionViewCell"

	var tuneToolType: TuneToolType?

	override var isSelected: Bool {
		didSet { animateScale(condition: isSelected) }
	}

	override func layoutSubviews() {
		setFont(.systemFont(ofSize: 14, weight: .light))
		setImageViewContentMode(mode: .center)

		if #available(iOS 13.0, *) {
			setTextColor(.label)
			setBorderToImage(color: .label, width: 1)
		}
		else {
			setTextColor(.darkText)
			setBorderToImage(color: .black, width: 1)
		}
	}
}
