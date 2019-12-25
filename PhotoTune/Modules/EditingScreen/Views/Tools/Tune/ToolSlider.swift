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
	var toolType: TuneToolType?

	init() {
		super.init(frame: .zero)
	}

	func configureForBrightness() {
		minimumValue = -0.75
		maximumValue = 0.75
		value = 0
	}

	func configureForContrast() {
		minimumValue = 0.25
		maximumValue = 2
		value = 1.0
	}

	func configureForSaturation() {
		minimumValue = 0.5
		maximumValue = 3
		value = 1.0
	}

	func configureForBloomIntensity() {
		minimumValue = 0.5
		maximumValue = 3
		value = 1.0
	}

	func configureForBloomRadius() {
		minimumValue = 0.5
		maximumValue = 3
		value = 1.0
	}

	func configureForVignetteIntensity() {
		minimumValue = 0.5
		maximumValue = 3
		value = 1.0
	}

	func configureForVignetteRadius() {
		minimumValue = 0.5
		maximumValue = 3
		value = 1.0
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
