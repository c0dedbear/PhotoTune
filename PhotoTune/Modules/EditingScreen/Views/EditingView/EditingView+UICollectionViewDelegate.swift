//
//  EditingView+UICollectionViewDelegate.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

extension EditingView: UICollectionViewDelegate
{
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		guard let toolsCollectionView = collectionView as? ToolsCollectionView else { return }

		guard let cell = toolsCollectionView.cellForItem(at: indexPath) as? ToolCollectionViewCell else { return }
		cell.isSelected = true

		switch toolCollectionViewDataSource?.editingType {
		case .filters:
			if let filteredImage = toolsDelegate?.imageWithFilter(index: indexPath.item) {
				setImage(filteredImage)
			}
			toolsCollectionView.lastSelectedFilter = indexPath
		case .tune:
			guard let tuneToolCell = cell as? TuneToolCollectionViewCell else { return }
			guard let type = tuneToolCell.tuneTool else { return }
			DispatchQueue.main.asyncAfter(wallDeadline: .now() + EditingScreenMetrics.tuneCellTapAnimationDuration)
			{ [weak self] in
				self?.hideAllToolsViews(except: .none)
				self?.showSlider(type: type)
			}
		default: break
		}
	}
}
