//
//  EditingScreenViewController+FiltersCollectionViewDelegate.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 21.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

// MARK: - FiltersCollectionViewDelegate
extension EditingScreenViewController: UICollectionViewDelegate
{
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		cell?.isSelected = true
		setFilteredImage(of: indexPath.item)
	}
}
