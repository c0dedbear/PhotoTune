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

	override var isHighlighted: Bool {
		didSet {}
	}

	override func layoutSubviews() {
		setFont(.systemFont(ofSize: 14, weight: .thin)
		)
		setTextColor(.darkText)
		setImageViewContentMode(mode: .center)
	}
}
