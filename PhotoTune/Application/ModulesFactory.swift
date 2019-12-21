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
			let router = EditingScreenRouter()
			let presenter = EditingScreenPresenter(image: image, router: router)
			let editingScreenVC = EditingScreenViewController(presenter: presenter)
			let navController = UINavigationController(rootViewController: editingScreenVC)
			//fix
//			presenter.editingScreen = editingScreenVC
//			router.destinationViewController = EditedPhotoController()
			return navController
	}
}
