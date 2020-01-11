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
	func getRandomImages()
	func loadImage(urlString: String, index: Int)
}

final class GoogleSearchScreenPresenter
{
	private let router: IGoogleSearchScreenRouter
	private let repository: IRepository
	var googleSearchScreen: IGoogleSearchScreenViewController?
	private var photos: [GoogleImage]?
	private let googleRandomImagesQueue = DispatchQueue(label: "googleRandomImagesQueue",
												qos: .userInteractive,
												attributes: .concurrent)

	init(repository: IRepository, router: IGoogleSearchScreenRouter) {
		self.router = router
		self.repository = repository
	}
}

extension GoogleSearchScreenPresenter: IGoogleSearchScreenPresenter
{
	func getRandomImages() {
		googleRandomImagesQueue.async { [weak self] in
			guard let self = self else { return }
			self.repository.getRandomGoogleImagesInfo{ [weak self] googleImagesResult in
				guard let self = self else { return }
				switch googleImagesResult {
				case .success(let data):
					DispatchQueue.main.async {
						self.googleSearchScreen?.updatePhotosArray(photosInfo: data)
					}
				case .failure(let error):
					print(error.localizedDescription)
				}
			}
		}
	}

	func loadImage(urlString: String, index: Int) {
		self.repository.loadImage(urlString: urlString) { [weak self] imageResult in
		guard let self = self else { return }
		switch imageResult {
		case .success(let image):
			DispatchQueue.main.async {
				self.googleSearchScreen?.updateCellImage(index: index, image: image)
			}
		case .failure(let error):
			print(error.localizedDescription)
			}
		}
	}
}
