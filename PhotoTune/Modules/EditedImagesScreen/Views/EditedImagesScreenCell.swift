//
//  EditedImagesScreenCell.swift
//  PhotoTune
//
//  Created by MacBook Air on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class EditedImagesScreenCell: ImageCollectionViewCell
{
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureCell()
	}

	private func configureCell() {
		imageView.contentMode = .center
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 20
	}
}
