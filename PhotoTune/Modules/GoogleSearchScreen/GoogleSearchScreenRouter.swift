//
//  GoogleSearchScreenRouter.swift
//  PhotoTune
//
//  Created by Саша Руцман on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IGoogleSearchScreenRouter
{
	func goToTheEditingScreen(image: UIImage)
}

final class GoogleSearchScreenRouter
{
		private var factory: ModulesFactory
		weak var viewController: GoogleSearchScreenViewController?

		init(factory: ModulesFactory) {
			self.factory = factory
		}
}

extension GoogleSearchScreenRouter: IGoogleSearchScreenRouter
{
	func goToTheEditingScreen(image: UIImage) {
		let editingScreenViewController = factory.createEditingScreenModule(image: image, editedImage: nil)
		editingScreenViewController.modalPresentationStyle = .fullScreen
		viewController?.navigationController?.present(editingScreenViewController, animated: true)
	}
}
