//
//  ToolsCollectionView.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class ToolsCollectionView: UICollectionView
{
	var lastSelectedFilter = IndexPath(item: 0, section: 0)

	init() {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		super.init(frame: .zero, collectionViewLayout: layout)
		initialSetup()
	}

	private func initialSetup() {
		if #available(iOS 13.0, *) {
			backgroundColor = .systemBackground
		}
		else {
			backgroundColor = .white
		}
		showsHorizontalScrollIndicator = false
		contentInset = UIEdgeInsets(
			top: 0,
			left: EditingScreenMetrics.collectionViewLeftInset,
			bottom: 0,
			right: EditingScreenMetrics.collectionViewRightInset)
		register(FiltersCollectionViewCell.self, forCellWithReuseIdentifier: FiltersCollectionViewCell.identifier)
		register(TuneToolCollectionViewCell.self, forCellWithReuseIdentifier: TuneToolCollectionViewCell.identifier)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
