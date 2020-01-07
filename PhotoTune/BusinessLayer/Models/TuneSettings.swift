//
//  TuneSettings.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 26.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

struct TuneSettings
{
	var brightnessIntensity = TuneSettingsDefaults.brightnessIntensity
	var contrastIntensity = TuneSettingsDefaults.contrastIntensity
	var saturationIntensity = TuneSettingsDefaults.saturationIntensity
	var vignetteIntensity = TuneSettingsDefaults.vignetteIntensity
	var vignetteRadius = TuneSettingsDefaults.vignetteRadius

	mutating func resetToActualSettings() {
		if brightnessIntensity < 0.008 && brightnessIntensity > TuneSettingsDefaults.brightnessIntensity  {
			brightnessIntensity = TuneSettingsDefaults.brightnessIntensity
		}

		if vignetteIntensity == 0.25 {
			vignetteIntensity = TuneSettingsDefaults.vignetteIntensity
		}

		if contrastIntensity < 1.016 && contrastIntensity > TuneSettingsDefaults.contrastIntensity {
			contrastIntensity = TuneSettingsDefaults.contrastIntensity
		}

		if saturationIntensity < 1.016 && saturationIntensity > TuneSettingsDefaults.saturationIntensity {
			saturationIntensity = TuneSettingsDefaults.saturationIntensity
		}
	}
}

enum TuneSettingsDefaults
{
	static let brightnessIntensity: Float = 0
	static let contrastIntensity: Float = 1
	static let saturationIntensity: Float = 1
	static let vignetteIntensity: Float = 0
	static let vignetteRadius: Float = TuneSettingsDefaults.vignetteIntensity + 1
}

extension Float
{
	func roundToDecimal(_ fractionDigits: Int) -> Float {
		let multiplier = pow(10, Float(fractionDigits))
		return Darwin.round(self * multiplier) / multiplier
	}
}
