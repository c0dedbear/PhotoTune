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
	static let all: [(title: String, filter: CIFilter?, image: UIImage?)] =
		[
		(title: "Normal", filter: CIFilter(name: ""), image: nil),
		(title: "B & W", filter: CIFilter(name: "CIPhotoEffectMono"), image: nil),
		(title: "Sepia", filter: CIFilter(name: "CISepiaTone"), image: nil),
		(title: "Noir", filter: CIFilter(name: "CIPhotoEffectNoir"), image: nil),
		(title: "Transfer", filter: CIFilter(name: "CIPhotoEffectTransfer"), image: nil),
		(title: "Chrome", filter: CIFilter(name: "CIPhotoEffectChrome"), image: nil),
		(title: "Pro", filter: CIFilter(name: "CIPhotoEffectProcess"), image: nil),
		(title: "Fade", filter: CIFilter(name: "CIPhotoEffectFade"), image: nil),
		(title: "Instant", filter: CIFilter(name: "CIPhotoEffectInstant"), image: nil),
		(title: "Mono", filter: CIFilter(name: "CIColorMonochrome"), image: nil),
	]
}
