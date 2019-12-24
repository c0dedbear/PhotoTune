//
//  ToolSlider.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 24.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class ToolSlider: UISlider
{
	var toolType: TuneToolType?

	init() {
		super.init(frame: .zero)
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
