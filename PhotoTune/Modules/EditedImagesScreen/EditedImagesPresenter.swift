//
//  EditedImagesPresenter.swift
//  PhotoTune
//
//  Created by MacBook Air on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import Foundation

protocol IEditedImagesPresenter
{
	func getImages() -> [EditedImage]
}

final class EditedImagesPresenter
{
	private let repository: IRepository
	private let router: IEditedImagesRouter

	init(repository: IRepository, router: IEditedImagesRouter) {
		self.repository = repository
		self.router = router
	}
}

extension EditedImagesPresenter: IEditedImagesPresenter
{
	func getImages() -> [EditedImage] { repository.getEditedImages() }
}
