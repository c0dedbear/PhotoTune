//
//  EditingView+UICollectionViewDelegate.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IToolCollectionViewDelegate: AnyObject
{
	func imageWithFilter(index: Int) -> UIImage?
	func saveTuneSettings()
	func setBrightness(value: Float)
	func setContrast(value: Float)
	func setSaturation(value: Float)
}

extension EditingView: UICollectionViewDelegate
{
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		guard let toolsCollectionView = collectionView as? ToolsCollectionView else { return }

		guard let cell = toolsCollectionView.cellForItem(at: indexPath) as? ToolCollectionViewCell else { return }
		cell.isSelected = true

		switch toolCollectionViewDataSource?.editingType {
		case .filters:
			if let filteredImage = toolCollectionViewDelegate?.imageWithFilter(index: indexPath.item) {
				toolsCollectionView.lastSelection = indexPath
				setImage(filteredImage)
			}
		case .tune:
			guard let tuneTool = cell as? TuneToolCollectionViewCell else { return }
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
				self?.hideAllToolsViews(except: .none)
				guard let type = tuneTool.tuneToolType else { return }
				self?.showSliders(of: type)
			}

		default: break
		}
	}
}
