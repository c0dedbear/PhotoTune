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
			EditedImage(imageFileName: "images.jpeg",
						previewFileName: "images.jpeg",
						editingDate: Date(),
						tuneSettings: nil),
			EditedImage(imageFileName: "images-2.jpeg",
						previewFileName: "images-2.jpeg",
						editingDate: Date(),
						tuneSettings: nil),
			EditedImage(imageFileName: "images-3.jpeg",
						previewFileName: "images-3.jpeg",
						editingDate: Date(),
						tuneSettings: nil),
			EditedImage(imageFileName: "images-4.jpeg",
						previewFileName: "images-4.jpeg",
						editingDate: Date(),
						tuneSettings: nil),
			EditedImage(imageFileName: "images-5.jpeg",
						previewFileName: "images-5.jpeg",
						editingDate: Date(),
						tuneSettings: nil),
			EditedImage(imageFileName: "images-6.jpeg",
						previewFileName: "images-6.jpeg",
						editingDate: Date(),
						tuneSettings: nil),
			EditedImage(imageFileName: "images-7.jpeg",
						previewFileName: "images-7.jpeg",
						editingDate: Date(),
						tuneSettings: nil),
			EditedImage(imageFileName: "images-8.jpeg",
						previewFileName: "images-8.jpeg",
						editingDate: Date(),
						tuneSettings: nil),
		]
	}
}

extension Repository: IRepository
{
	func getImages() -> [EditedImage] {
		return images
	}
}
