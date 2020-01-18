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
			setImage(UIImage(named: "autoEnchance"), for: .normal)
			setImage(UIImage(named: "autoEnchancefill"), for: .selected)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
