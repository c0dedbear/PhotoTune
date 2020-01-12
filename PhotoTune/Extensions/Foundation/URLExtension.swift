//
//  URLExtension.swift
//  PhotoTune
//
//  Created by Саша Руцман on 11.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import Foundation

extension URL
{
	static func with(string: String) -> URL? {
		return URL(string: "\(Urls.baseUrl)\(string)")
	}
}
