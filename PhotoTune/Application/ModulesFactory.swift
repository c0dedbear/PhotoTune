//
//  ModulesFactory.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class ModulesFactory
{
	func createEditingScreenModule(image: UIImage?, editedImage: EditedImage?)
		-> UINavigationController {
			let storageService = StorageService() // fix: перенести в appdelegate
			let imageProcessor = ImageProcessor() // fix: перенести в appdelegate
			let router = EditingScreenRouter()
			let presenter = EditingScreenPresenter(
				image: image,
				editedImage: editedImage,
				imageProcessor: imageProcessor,
				storageService: storageService,
				router: router)
			let editingScreenVC = EditingScreenViewController(presenter: presenter)
			let navController = UINavigationController(rootViewController: editingScreenVC)
			presenter.editingScreen = editingScreenVC
			return navController
	}

	func createEditedImagesScreenModule() -> UINavigationController {
		let storageService = StorageService() // fix: move to appdelegate
		let repository = Repository(storageService: storageService)
		let router = EditedImagesRouter(factory: self)
		let presenter = EditedImagesPresenter(repository: repository, router: router)
		let viewController = EditedImagesCollectionViewController(presenter: presenter)
		presenter.inject(viewController: viewController)
		let navController = UINavigationController(rootViewController: viewController)
		router.viewController = viewController
		return navController
  }

	func createGoogleSearchScreen() -> UINavigationController {
		let router = GoogleSearchScreenRouter(factory: self)
		let presenter = GoogleSearchScreenPresenter(router: router)
		let googleSearchScreenVC = GoogleSearchScreenViewController(presenter: presenter)
		let navController = UINavigationController(rootViewController: googleSearchScreenVC)
		presenter.googleSearchScreen = googleSearchScreenVC
		return navController
	}
}
