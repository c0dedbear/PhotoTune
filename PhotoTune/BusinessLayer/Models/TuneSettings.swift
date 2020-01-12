//
//  TuneSettings.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 26.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import CoreImage

struct TuneSettings: Equatable, Codable
{
	var ciFilter: String?
	var brightnessIntensity = TuneSettingsDefaults.brightnessIntensity
	var contrastIntensity = TuneSettingsDefaults.contrastIntensity
	var saturationIntensity = TuneSettingsDefaults.saturationIntensity
	var vignetteIntensity = TuneSettingsDefaults.vignetteIntensity
	var vignetteRadius = TuneSettingsDefaults.vignetteRadius
	var rotationAngle = TuneSettingsDefaults.rotationAngle

	mutating func limitRotationAngle() {
		if rotationAngle > TuneSettingsDefaults.rotationPositiveAngleLimit ||
			rotationAngle < TuneSettingsDefaults.rotationNegativeAngleLimit {
			rotationAngle = TuneSettingsDefaults.rotationAngle
		}
	}

	mutating func resetToActualSettings() {
		if brightnessIntensity < TuneSettingsDefaults.brightnessIntensityStep && brightnessIntensity > TuneSettingsDefaults.brightnessIntensity  {
			brightnessIntensity = TuneSettingsDefaults.brightnessIntensity
		}

		if vignetteIntensity == TuneSettingsDefaults.minVignetteIntensity {
			vignetteIntensity = TuneSettingsDefaults.vignetteIntensity
		}

		if contrastIntensity < TuneSettingsDefaults.contrastIntensityStep && contrastIntensity > TuneSettingsDefaults.contrastIntensity {
			contrastIntensity = TuneSettingsDefaults.contrastIntensity
		}

		if saturationIntensity < TuneSettingsDefaults.saturationIntensityStep && saturationIntensity > TuneSettingsDefaults.saturationIntensity {
			saturationIntensity = TuneSettingsDefaults.saturationIntensity
		}
	}
}

enum TuneSettingsDefaults
{
	static let brightnessIntensity: Float = 0
	static let minBrightnessIntensity: Float = -0.3
	static let maxBrightnessIntensity: Float = 0.3
	static let brightnessIntensityStep: Float = 0.008

	static let contrastIntensity: Float = 1
	static let minContrastIntensity: Float = 0.25
	static let maxContrastIntensity: Float = 1.75
	static let contrastIntensityStep: Float = 1.016

	static let saturationIntensity: Float = 1
	static let minSaturationIntensity: Float = 0.25
	static let maxSaturationIntensity: Float = 1.75
	static let saturationIntensityStep: Float = 1.016

	static let vignetteIntensity: Float = 0
	static let minVignetteIntensity: Float = 0.25
	static let maxVignetteIntensity: Float = 1.75
	static let vignetteRadius: Float = 2

	static let rotationAngle: CGFloat = 0
	static let rotationPositiveAngleLimit: CGFloat = 6.2
	static let rotationNegativeAngleLimit: CGFloat = -6.2
	static let rotationAngleStep: CGFloat = 90 * (.pi / 180)
}
