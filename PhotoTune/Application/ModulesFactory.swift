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
	func createEditingScreenModule(image: UIImage)
		-> UINavigationController {
			let imageProcessor = ImageProcessor()
			let router = EditingScreenRouter()
			let presenter = EditingScreenPresenter(image: image, imageProcessor: imageProcessor, router: router)
			let editingScreenVC = EditingScreenViewController(presenter: presenter)
			let navController = UINavigationController(rootViewController: editingScreenVC)
			presenter.editingScreen = editingScreenVC
			//fix
//			router.destinationViewController = EditedPhotoController()
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
