//
//  EditingScreenViewController+UICollectionViewDelegateFlowLayout.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 21.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

// MARK: - FiltersCollectionViewDelegateFlowLayout
extension EditingScreenViewController: UICollectionViewDelegateFlowLayout
{
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: filterCellHeight, height: filterCellHeight)
	}
}
