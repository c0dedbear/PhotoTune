//
//  TuneToolsImages.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

enum TuneTool
{
	static let all = [
		(title: "Brightness", image: UIImage(named: "brightness"), type: TuneToolType.brightness),
		(title: "Contrast", image: UIImage(named: "contrast"), type: TuneToolType.contrast),
		(title: "Saturation", image: UIImage(named: "saturation"), type: TuneToolType.saturation),
		(title: "Vignette", image: UIImage(named: "vignette"), type: TuneToolType.vignette),
	]
}
