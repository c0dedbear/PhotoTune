//
//  ToolSlider.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 24.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class ToolSlider: UISlider
{
	init() {
		super.init(frame: .zero)
	}

	func configureForBrightness(withValue: Float) {
		minimumValue = -0.75
		maximumValue = 0.75
		value = withValue
	}

	func configureForContrast(withValue: Float) {
		minimumValue = 0.25
		maximumValue = 2
		value = withValue
	}

	func configureForSaturation(withValue: Float) {
		minimumValue = -2
		maximumValue = 4
		value = withValue
	}

	func configureForVignetteIntensity(withValue: Float) {
		minimumValue = 0.25
		maximumValue = 1.75
		value = withValue + 1 // 1 for immediately effect
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
