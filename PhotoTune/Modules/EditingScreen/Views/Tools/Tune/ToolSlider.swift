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
	private let throttler = Throttler(minimumDelay: EditingScreenMetrics.hapticThrottlingDelay)
	private let haptics = UIImpactFeedbackGenerator(style: .light)
	private let label = UILabel()
	var tuneSettings: TuneSettings?

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
		throttler.throttle {
			if self.label.text == "0" {
				self.haptics.impactOccurred()
			}
		}
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

	func configureForBrightness() {
		minimumValue = TuneSettingsDefaults.minBrightnessIntensity
		maximumValue = TuneSettingsDefaults.maxBrightnessIntensity
		value = tuneSettings?.brightnessIntensity ?? TuneSettingsDefaults.brightnessIntensity
		updateLabel()
	}

	func configureForContrast() {
		minimumValue = TuneSettingsDefaults.minContrastIntensity
		maximumValue = TuneSettingsDefaults.maxContrastIntensity
		value = tuneSettings?.contrastIntensity ?? TuneSettingsDefaults.contrastIntensity
		updateLabel()
	}

	func configureForSaturation() {
		minimumValue = TuneSettingsDefaults.minSaturationIntensity
		maximumValue = TuneSettingsDefaults.maxSaturationIntensity
		value = tuneSettings?.saturationIntensity ?? TuneSettingsDefaults.saturationIntensity
		updateLabel()
	}

	func configureForSharpness() {
		minimumValue = TuneSettingsDefaults.minSharpnessIntensity
		maximumValue = TuneSettingsDefaults.maxSharpnessIntensity
		value = tuneSettings?.sharpnessIntensity ?? TuneSettingsDefaults.sharpnessIntensity
		updateLabel()
	}

	func configureForVignetteIntensity() {
		minimumValue = TuneSettingsDefaults.minVignetteIntensity
		maximumValue = TuneSettingsDefaults.maxVignetteIntensity
		if let vigInt = tuneSettings?.vignetteIntensity {
		value = (vigInt == TuneSettingsDefaults.vignetteIntensity) ?
				(vigInt + 1) : vigInt // 1 for immediately applying effect
		}
		else {
			value = TuneSettingsDefaults.vignetteIntensity
		}
		updateLabel(convertValues: false)
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
