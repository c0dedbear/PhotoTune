//
//  UIImage+Resizing.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 15.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

extension UIImage
{
	func resized(toWidth width: CGFloat) -> UIImage? {
		let canvas = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
		return UIGraphicsImageRenderer(
			size: canvas).image { _ in
				draw(in: CGRect(origin: .zero, size: canvas))
		}
	}
}
