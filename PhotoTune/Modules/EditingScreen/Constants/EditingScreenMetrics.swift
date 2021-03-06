//
//  EditingScreenMetrics.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 20.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

enum EditingScreenMetrics
{
	static let filterCellCornerRadius: CGFloat = 20
	static let collectionViewLeftInset: CGFloat = 20
	static let collectionViewRightInset: CGFloat = 20
	static let filtersLineSpacing: CGFloat = 36
	static let tuneToolLineSpacing: CGFloat = 44
	static let tuneCellTapAnimationDuration = 0.1
	static let filterSelectionDelay = 0.005
	static let tuneToolIndicatorRadius: CGFloat = 6
	static let sliderThrottlingDelay = 0.0125
	static let hapticThrottlingDelay = 0.15
	static let screenSize = UIScreen.main.bounds
	static let smallScreenSizeWidth: CGFloat = 320
	static let scaleImageWidth = EditingScreenMetrics.screenSize.width
	static let previewImageSize = EditingScreenMetrics.screenSize.width / 3
}
