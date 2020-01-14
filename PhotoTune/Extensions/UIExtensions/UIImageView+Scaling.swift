//
//  UIImageView+Scaling.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 14.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

extension UIImageView
{
	func enableZoom() {
		isUserInteractionEnabled = true
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
		doubleTap.numberOfTapsRequired = 2
		addGestureRecognizer(doubleTap)
	}

	@objc private func doubleTapped() {
		if transform.isIdentity {
			let scaleResult = transform.scaledBy(x: 2.5, y: 2.5)
			UIView.animate(withDuration: 0.25) {
				self.transform = scaleResult
				self.superview?.viewWithTag(2)?.alpha = 0
			}
		}
		else {
			UIView.animate(withDuration: 0.25) {
				self.transform = CGAffineTransform.identity
				self.superview?.viewWithTag(2)?.alpha = 1
			}
		}
	}
}
