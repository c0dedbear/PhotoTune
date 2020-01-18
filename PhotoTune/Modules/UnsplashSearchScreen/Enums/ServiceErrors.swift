//
//  ServiceErrors.swift
//  PhotoTune
//
//  Created by Саша Руцман on 11.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import Foundation

enum NetworkError: Error
{
	case sessionError
	case dataError
	case statusCode(Int)
}

extension NetworkError: LocalizedError
{
	var errorDescription: String? {
		switch self {
		case .sessionError:
			return NSLocalizedString("Check your internet connection", comment: "")
		case .dataError:
			return NSLocalizedString("Error loading", comment: "")
		case .statusCode(let code):
			let message = NSLocalizedString("Status code: %d", comment: "")
			return String.localizedStringWithFormat(message, code)
		}
	}
}
