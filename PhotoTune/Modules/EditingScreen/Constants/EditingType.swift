//
//  EditingType.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 19.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

enum EditingType: String
{
	case filters
	case tune
	case rotation
	case none

	func setTitle() -> String {
		switch self {
		case .filters:
			return "Filters".localized
		case .tune:
			return "Tune".localized
		case .rotation:
			return "Rotation".localized
		case .none:
			return ""
		}
	}
}
