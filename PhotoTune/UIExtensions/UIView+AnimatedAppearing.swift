//
//  UIView+AnimatedAppearing.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 21.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

extension UIView
{
	func animatedAppearing() {
		isHidden = false
		alpha = 0
		UIView.animate(
			withDuration: 0.3,
			delay: 0,
			options: .curveEaseOut,
			animations: { self.alpha = 1 }
		)
	}
}
