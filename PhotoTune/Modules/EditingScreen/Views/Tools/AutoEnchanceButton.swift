//
//  AutoEnchanceButton.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 13.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class AutoEnchanceButton: UIButton
{
	init() {
		super.init(frame: .zero)
		if #available(iOS 13.0, *) {
			setImage(UIImage(systemName: "bolt.badge.a"), for: .normal)
			setImage(UIImage(systemName: "bolt.badge.a.fill"), for: .selected)
		}
		else {
			setImage(UIImage(named: "autoEnchance"), for: .normal)
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
