//
//  PhotoCollectionViewCell.swift
//  PhotoTune
//
//  Created by Саша Руцман on 10.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//
// swiftlint:disable required_final

import UIKit

class ImageCollectionViewCell: UICollectionViewCell
{
	let imageView = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(imageView)
		imageView.layer.masksToBounds = true
		makeConstraintsForImageView()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func makeConstraintsForImageView() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
}
