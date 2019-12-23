//
//  EditingScreenViewController+FiltersCollectionViewDataSource.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 21.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

// MARK: - FiltersCollectionViewDataSource
extension EditingScreenViewController: UICollectionViewDataSource
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return filtersCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: FiltersCollectionViewCell.identifier,
			for: indexPath) as? FiltersCollectionViewCell else { return UICollectionViewCell() }

		let title = cellTitleFor(index: indexPath.item)
		let image = cellImageFor(index: indexPath.item)

		cell.setTitle(title)
		cell.setImage(image)

		return cell
	}
}
