//
//  TuneSettings.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 26.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import CoreGraphics

struct TuneSettings
{
	var brightnessIntensity = TuneSettingsDefaults.brightnessIntensity
	var contrastIntensity = TuneSettingsDefaults.contrastIntensity
	var saturationIntensity = TuneSettingsDefaults.saturationIntensity
	var vignetteIntensity = TuneSettingsDefaults.vignetteIntensity
	var vignetteRadius = TuneSettingsDefaults.vignetteRadius
	var rotationAngle = TuneSettingsDefaults.rotationAngle
}

enum TuneSettingsDefaults
{
	static let brightnessIntensity: Float = 0
	static let contrastIntensity: Float = 1
	static let saturationIntensity: Float = 1
	static let vignetteIntensity: Float = 0
	static let vignetteRadius: Float = 2
	static let rotationAngle: CGFloat = 0
}
