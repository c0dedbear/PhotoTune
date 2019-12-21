//
//  FiltersCollectionView.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class FiltersCollectionView: UICollectionView
{
	init() {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		super.init(frame: .zero, collectionViewLayout: layout)
		initialSetup()
	}

	private func initialSetup() {
		backgroundColor = .white
		showsHorizontalScrollIndicator = false
		contentInset = UIEdgeInsets(
			top: 0,
			left: EditinScreenMetrics.collectionViewLeftInset,
			bottom: 0,
			right: EditinScreenMetrics.collectionViewRightInset)
		register(FiltersCollectionViewCell.self, forCellWithReuseIdentifier: FiltersCollectionViewCell.identifier)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
