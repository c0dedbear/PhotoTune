//
//  EditingScreenMainView+UICollectionViewDelegateFlowLayout.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

extension EditingScreenMainView: UICollectionViewDelegateFlowLayout
{
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: heightForCell, height: heightForCell)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		CGFloat.greatestFiniteMagnitude
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		if toolCollectionViewDataSource?.editingType == .filters {
			return EditingScreenMetrics.filtersLineSpacing
		}
		else {
			return EditingScreenMetrics.tuneToolLineSpacing
		}
	}
}
