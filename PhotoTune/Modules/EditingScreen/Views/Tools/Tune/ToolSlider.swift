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
	private let label = UILabel()

	init() {
		super.init(frame: .zero)
		initialSetup()
	}

	private func initialSetup() {
		minimumTrackTintColor = UIColor.systemGray.withAlphaComponent(0.5)
		maximumTrackTintColor = UIColor.systemGray.withAlphaComponent(0.5)
		label.text = "\(Int(value))"
		label.textAlignment = .center
		if #available(iOS 13.0, *) {
			label.textColor = .secondaryLabel
		}
		else {
			label.textColor = .gray
		}
		addSubview(label)
	}

	func updateLabel(convertValues: Bool = true) {
		label.frame = thumbBounds.offsetBy(dx: 0, dy: -30)
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.75
		setLabelText(convertValues: convertValues)
	}

	private func setLabelText(convertValues: Bool) {
		if convertValues {
			let percentageValue = Int((value - minimumValue) / (maximumValue - minimumValue) * 100) - 50
			label.text = "\(percentageValue * 2)"
		}
		else {
			let percentageValue = Int((value - minimumValue) / (maximumValue - minimumValue) * 100)
			label.text = "\(percentageValue)"
		}
	}

	func configureForBrightness(withValue: Float) {
		minimumValue = -0.3
		maximumValue = 0.3
		value = withValue
		updateLabel()
	}

	func configureForContrast(withValue: Float) {
		minimumValue = 0.25
		maximumValue = 1.75
		value = withValue
		updateLabel()
	}

	func configureForSaturation(withValue: Float) {
		minimumValue = 0.25
		maximumValue = 1.75
		value = withValue
		updateLabel()
	}

	func configureForVignetteIntensity(withValue: Float) {
		minimumValue = 0.25
		maximumValue = 1.75
		value = (withValue == TuneSettingsDefaults.vignetteIntensity) ?
			(withValue + 1) : withValue // 1 for immediately applying effect
		updateLabel(convertValues: false)
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
