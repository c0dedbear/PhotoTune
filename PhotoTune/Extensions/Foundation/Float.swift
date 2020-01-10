//
//  Float.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 09.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import Foundation

extension Float
{
	func roundToDecimal(_ fractionDigits: Int) -> Float {
		let multiplier = pow(10, Float(fractionDigits))
		return Darwin.round(self * multiplier) / multiplier
	}
}
