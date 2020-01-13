//
//  AppDelegate.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 16.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate
{

	var window: UIWindow?

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// MARK: Services
		let storageService = StorageService()
		let imageProcessor = ImageProcessor()

		// MARK: Repositories
		let storageRepository = StorageRepository(storageService: storageService)
		let networkRepository = NetworkRepository()

		// MARK: Create Initial Screen
		let factory = ModulesFactory(
			storageService: storageService,
			storageRepository: storageRepository,
			networkRepository: networkRepository,
			imageProcessor: imageProcessor)

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = factory.createEditedImagesScreenModule()
		window?.makeKeyAndVisible()

		if #available(iOS 13.0, *) {
			window?.backgroundColor = .systemBackground
			window?.tintColor = .label
		}
		else {
			window?.backgroundColor = .white
			window?.tintColor = .black
		}

		return true
	}
}
