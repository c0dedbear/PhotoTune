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
	private let storageService: IStorageService
	private let storageRepository: IStorageRepository
	private let networkRepository: INetworkRepository
	private let imageProcessor: IImageProcessor

	init(
		storageService: IStorageService,
		storageRepository: IStorageRepository,
		networkRepository: INetworkRepository,
		imageProcessor: IImageProcessor
	) {
		self.storageService = storageService
		self.storageRepository = storageRepository
		self.networkRepository = networkRepository
		self.imageProcessor = imageProcessor
	}

	func createEditingScreenModule(image: UIImage?, editedImage: EditedImage?)
		-> UINavigationController {
			let presenter = EditingScreenPresenter(
				image: image,
				editedImage: editedImage,
				imageProcessor: imageProcessor,
				storageService: storageService)
			let editingScreenVC = EditingScreenViewController(presenter: presenter)
			let navController = UINavigationController(rootViewController: editingScreenVC)
			presenter.editingScreen = editingScreenVC
			return navController
	}

	func createEditedImagesScreenModule() -> UINavigationController {
		let repository = storageRepository
		let router = EditedImagesRouter(factory: self)
		let presenter = EditedImagesPresenter(repository: repository, router: router)
		let viewController = EditedImagesCollectionViewController(presenter: presenter)
		presenter.inject(viewController: viewController)
		let navController = UINavigationController(rootViewController: viewController)
		router.viewController = viewController
		return navController
	}

	func createGoogleSearchScreen() -> UINavigationController {
		let repository = NetworkRepository()
		let router = GoogleSearchScreenRouter(factory: self)
		let presenter = GoogleSearchScreenPresenter(repository: repository, router: router)
		let googleSearchScreenVC = GoogleSearchScreenViewController(presenter: presenter)
		let navController = UINavigationController(rootViewController: googleSearchScreenVC)
		router.viewController = googleSearchScreenVC
		presenter.googleSearchScreen = googleSearchScreenVC
		return navController
	}
}
