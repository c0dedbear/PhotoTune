//
//  EditingScreenMainView+UICollectionViewDelegate.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

extension EditingScreenMainView: UICollectionViewDelegate
{
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		if let filterCell = collectionView.cellForItem(at: indexPath) as? FiltersCollectionViewCell {
			filterCell.isSelected = true
			if let filteredImage = filterCollectionViewDelegate?.imageWithFilter(index: indexPath.item) {
				setImage(filteredImage)
			}
		}

		if let tuneToolCell = collectionView.cellForItem(at: indexPath) as? TuneToolCollectionViewCell {
			tuneToolCell.isSelected = true
			//show sliders or other tune tools
		}
	}
}
