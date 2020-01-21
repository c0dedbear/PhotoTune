//
//  EditedImage.swift
//  PhotoTune
//
//  Created by MacBook Air on 17.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

struct EditedImage: Codable, Equatable
{
	let imageFileName: String
	let previewFileName: String

	var editingDate: Date
	var tuneSettings: TuneSettings?

	var formattedDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short
		dateFormatter.doesRelativeDateFormatting = true
		return dateFormatter.string(from: editingDate)
	}
}
