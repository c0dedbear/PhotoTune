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
	private let networkService: INetworkService
	private let storageRepository: IStorageRepository
	private let imageProcessor: IImageProcessor

	init(
		storageService: IStorageService,
		networkService: INetworkService,
		storageRepository: IStorageRepository,
		imageProcessor: IImageProcessor
	) {
		self.storageService = storageService
		self.networkService = networkService
		self.storageRepository = storageRepository
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

	func createUnsplashSearchScreen() -> UnsplashSearchScreenViewController {
		let networkService = NetworkService()
		let router = UnsplashSearchScreenRouter(factory: self)
		let presenter = UnsplashSearchScreenPresenter(networkService: networkService, router: router)
		let googleSearchScreenVC = UnsplashSearchScreenViewController(presenter: presenter)
		router.viewController = googleSearchScreenVC
		presenter.unsplashSearchScreen = googleSearchScreenVC
		return googleSearchScreenVC
	}
}
