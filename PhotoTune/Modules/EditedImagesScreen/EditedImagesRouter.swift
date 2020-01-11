//
//  EditedImagesRouter.swift
//  PhotoTune
//
//  Created by MacBook Air on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IEditedImagesRouter
{
	func goToEditingScreen(image: UIImage?, editedImage: EditedImage?)
}

final class EditedImagesRouter
{
	weak var viewController: EditedImagesCollectionViewController?

	private var factory: ModulesFactory

	init(factory: ModulesFactory) {
		self.factory = factory
	}
}

extension EditedImagesRouter: IEditedImagesRouter
{
	func goToEditingScreen(image: UIImage?, editedImage: EditedImage?) {
		let editingScreenViewController = factory.createEditingScreenModule(image: image, editedImage: editedImage)
		viewController?.navigationController?.present(editingScreenViewController, animated: true)
	}
}
