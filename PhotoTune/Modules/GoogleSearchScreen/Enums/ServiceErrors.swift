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
	case sessionError(Error)
	case notFound(Error)
	case dataError(Error)
	case statusCode(Int)
}
