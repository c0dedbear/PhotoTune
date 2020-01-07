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
			EditedImage(imageFileName: "", previewFileName: "images.jpeg", editingDate: Date(), tuneSettings: nil),
			EditedImage(imageFileName: "", previewFileName: "images-2.jpeg", editingDate: Date(), tuneSettings: nil),
			EditedImage(imageFileName: "", previewFileName: "images-3.jpeg", editingDate: Date(), tuneSettings: nil),
			EditedImage(imageFileName: "", previewFileName: "images-4.jpeg", editingDate: Date(), tuneSettings: nil),
			EditedImage(imageFileName: "", previewFileName: "images-5.jpeg", editingDate: Date(), tuneSettings: nil),
			EditedImage(imageFileName: "", previewFileName: "images-6.jpeg", editingDate: Date(), tuneSettings: nil),
			EditedImage(imageFileName: "", previewFileName: "images-7.jpeg", editingDate: Date(), tuneSettings: nil),
			EditedImage(imageFileName: "", previewFileName: "images-8.jpeg", editingDate: Date(), tuneSettings: nil),
		]
	}
}

extension Repository: IRepository
{
	func getImages() -> [EditedImage] {
		return images
	}
}
