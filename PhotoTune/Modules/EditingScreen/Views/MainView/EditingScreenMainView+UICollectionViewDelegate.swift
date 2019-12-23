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
		let cell = collectionView.cellForItem(at: indexPath)
		cell?.isSelected = true
		if let filteredImage = filterCollectionViewDelegate?.imageWithFilter(index: indexPath.item) {
			setImage(filteredImage)
		}
	}
}
