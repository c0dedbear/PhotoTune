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
		let navigationRoot = ModulesFactory().createEditedImagesScreenModule()
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = navigationRoot
		window?.makeKeyAndVisible()
		return true
	}
}
