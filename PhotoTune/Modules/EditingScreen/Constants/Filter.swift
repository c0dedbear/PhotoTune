//
//  Filter.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 24.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
import CoreImage

enum Filter
{
	static let colorControls: (title: String, ciFilter: CIFilter?, image: UIImage?)
		= ("ColorControls", CIFilter(name: "CIColorControls"), nil)

	static let vignette: (title: String, ciFilter: CIFilter?, image: UIImage?)
		= ("Vignette", CIFilter(name: "CIVignette"), nil)

	static let sharpness: (title: String, ciFilter: CIFilter?, image: UIImage?)
	= ("Sharpness", CIFilter(name: "CIUnsharpMask"), nil)

	static let transform: (title: String, ciFilter: CIFilter?, image: UIImage?)
		= ("Transform", CIFilter(name: "CIAffineTransform"), nil)

	static let photoFilters: [(title: String, ciFilter: CIFilter?, image: UIImage?)] =
		[
		("Original", CIFilter(name: ""), nil),
		("B & W", CIFilter(name: "CIPhotoEffectMono"), nil),
		("Sepia", CIFilter(name: "CISepiaTone"), nil),
		("Noir", CIFilter(name: "CIPhotoEffectNoir"), nil),
		("Transfer", CIFilter(name: "CIPhotoEffectTransfer"), nil),
		("Chrome", CIFilter(name: "CIPhotoEffectChrome"), nil),
		("Pro", CIFilter(name: "CIPhotoEffectProcess"), nil),
		("Fade", CIFilter(name: "CIPhotoEffectFade"), nil),
		("Instant", CIFilter(name: "CIPhotoEffectInstant"), nil),
		("Mono", CIFilter(name: "CIColorMonochrome"), nil),
	]

	static let controlsChainFilters = [
		Filter.colorControls.ciFilter,
		Filter.sharpness.ciFilter,
		Filter.vignette.ciFilter,
		Filter.transform.ciFilter,
	]
}
