//
//  CGAfflineTransform.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 17.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

extension CGAffineTransform
{
	var xScale: CGFloat { return sqrt(a * a + c * c) }
	var yScale: CGFloat { return sqrt(b * b + d * d) }
	var rotation: CGFloat { return CGFloat(atan2(Double(b), Double(a))) }
	var xOffset: CGFloat { return tx }
	var yOffset: CGFloat { return ty }
}
