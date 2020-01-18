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
	var autoEnchancement = false

	var brightnessIntensity = TuneSettingsDefaults.brightnessIntensity
	var contrastIntensity = TuneSettingsDefaults.contrastIntensity
	var saturationIntensity = TuneSettingsDefaults.saturationIntensity

	var vignetteIntensity = TuneSettingsDefaults.vignetteIntensity
	var vignetteRadius = TuneSettingsDefaults.vignetteRadius

	var rotationAngle = TuneSettingsDefaults.rotationAngle

	var sharpnessIntensity = TuneSettingsDefaults.sharpnessIntensity
	var sharpnessRadius = TuneSettingsDefaults.sharpnessRadius

	mutating func resetToActualSettings() {
		if brightnessIntensity < TuneSettingsDefaults.brightnessIntensityStep
			&& brightnessIntensity > TuneSettingsDefaults.brightnessIntensity  {
			brightnessIntensity = TuneSettingsDefaults.brightnessIntensity
		}

		if vignetteIntensity == TuneSettingsDefaults.minVignetteIntensity {
			vignetteIntensity = TuneSettingsDefaults.vignetteIntensity
		}

		if contrastIntensity < TuneSettingsDefaults.contrastIntensityStep
			&& contrastIntensity > TuneSettingsDefaults.contrastIntensity {
			contrastIntensity = TuneSettingsDefaults.contrastIntensity
		}

		if saturationIntensity < TuneSettingsDefaults.saturationIntensityStep
			&& saturationIntensity > TuneSettingsDefaults.saturationIntensity {
			saturationIntensity = TuneSettingsDefaults.saturationIntensity
		}

		if (sharpnessIntensity - TuneSettingsDefaults.sharpnessIntensity) < TuneSettingsDefaults.sharpnessIntensityStep
			&& sharpnessIntensity > TuneSettingsDefaults.sharpnessIntensity {
			sharpnessIntensity = TuneSettingsDefaults.sharpnessIntensity
		}
	}
}

enum TuneSettingsDefaults
{
	static let brightnessIntensity: Float = 0
	static let minBrightnessIntensity: Float = -0.2
	static let maxBrightnessIntensity: Float = 0.2
	static let brightnessIntensityStep: Float = 0.005

	static let contrastIntensity: Float = 1
	static let minContrastIntensity: Float = 0.5
	static let maxContrastIntensity: Float = 1.5
	static let contrastIntensityStep: Float = 1.012

	static let saturationIntensity: Float = 1
	static let minSaturationIntensity: Float = 0.25
	static let maxSaturationIntensity: Float = 1.75
	static let saturationIntensityStep: Float = 1.016

	static let vignetteIntensity: Float = 0
	static let minVignetteIntensity: Float = 0
	static let maxVignetteIntensity: Float = 1.5
	static let vignetteRadius: Float = 2

	static let rotationAngle: CGFloat = 0
	static let rotationAngleStep: CGFloat = 90 * (.pi / 180)

	static let sharpnessIntensity: Float = 0.5
	static let sharpnessRadius: Float = 2.5
	static let minSharpnessIntensity: Float = -0.5
	static let maxSharpnessIntensity: Float = 1.5
	static let sharpnessIntensityStep: Float = 0.018
}
