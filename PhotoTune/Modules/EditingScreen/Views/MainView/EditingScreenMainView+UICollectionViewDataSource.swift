//
//  EditingScreenMainView+UICollectionViewDataSource.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

extension EditingScreenMainView: UICollectionViewDataSource
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		filtersCollectionViewDataSource?.filtersCount ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: FiltersCollectionViewCell.identifier,
			for: indexPath) as? FiltersCollectionViewCell else { return UICollectionViewCell() }

		let title = filtersCollectionViewDataSource?.cellTitleFor(index: indexPath.item)
		let image = filtersCollectionViewDataSource?.cellImageFor(index: indexPath.item)

		cell.setTitle(title ?? "")
		cell.setImage(image)

		return cell
	}
}
