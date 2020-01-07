//
//  EditedImage.swift
//  PhotoTune
//
//  Created by MacBook Air on 17.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

struct EditedImage: Codable
{
	let imagePath: String
	var previewURL: URL?

	var editingDate: Date
	var tuneSettings: TuneSettings?

	var formattedDate: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter.string(from: editingDate)
	}
}
