//
//  ImageModel.swift
//  PhotoTune
//
//  Created by MacBook Air on 17.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

struct ImageModel
{
	let name: String
	let image: UIImage
	let editingDate: Date

	init(name: String, image: UIImage, editingDate: Date) {
		self.name = name
		self.image = image
		self.editingDate = editingDate
	}
}
