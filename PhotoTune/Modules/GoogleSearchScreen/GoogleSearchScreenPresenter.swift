//
//  GoogleSearchScreenPresenter.swift
//  PhotoTune
//
//  Created by Саша Руцман on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IGoogleSearchScreenPresenter
{
	func getPhotos() -> [UIImage]
}

final class GoogleSearchScreenPresenter
{
	private let router: IGoogleSearchScreenRouter
	var googleSearchScreen: IGoogleSearchScreenViewController?
	private var photos: [UIImage]?

	init(router: IGoogleSearchScreenRouter) {
		self.router = router
	}

	func getPhotos() -> [UIImage] {
		return photos ?? []
	}
}

extension GoogleSearchScreenPresenter: IGoogleSearchScreenPresenter
{
}
