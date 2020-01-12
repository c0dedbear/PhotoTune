//
//  UIAlertController+Constraints.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 13.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

/*
It's a new bug in iOS versions:
12.2
12.3
12.4
13.0
13.1
13.2
13.2.3
13.3
The only thing we can do is to file a bug report to Apple (I just did that and you should too).
I'll try to update answer for a new version(s) of iOS when it come out.

The following removes the warning without needing to disable animation.
And assuming Apple eventually fixes the root cause of the warning, it shouldn't break anything else.
*/

import UIKit

extension UIAlertController
{
	func pruneNegativeWidthConstraints() {
		for subView in self.view.subviews {
			for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
				subView.removeConstraint(constraint)
			}
		}
	}
}
