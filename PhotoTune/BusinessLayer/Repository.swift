//
//  Repository.swift
//  PhotoTune
//
//  Created by MacBook Air on 19.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import Foundation

protocol IRepository
{
	func getImages() -> [EditedImage]
}

final class Repository
{
	var images: [EditedImage] {
		[
			EditedImage(imagePath: "images.jpeg", editingDate: Date()),
			EditedImage(imagePath: "images-2.jpeg", editingDate: Date()),
			EditedImage(imagePath: "images-3.jpeg", editingDate: Date()),
			EditedImage(imagePath: "images-4.jpeg", editingDate: Date()),
			EditedImage(imagePath: "images-5.jpeg", editingDate: Date()),
			EditedImage(imagePath: "images-6.jpeg", editingDate: Date()),
			EditedImage(imagePath: "images-7.jpeg", editingDate: Date()),
			EditedImage(imagePath: "images-8.jpeg", editingDate: Date()),
		]
	}
}

extension Repository: IRepository
{
	func getImages() -> [EditedImage] {
		return images
	}
}
