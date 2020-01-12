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
	func getImages(with searchTerm: String)
	func loadImage(urlString: String, index: Int)
}

final class GoogleSearchScreenPresenter
{
	private let router: IGoogleSearchScreenRouter
	private let repository: INetworkRepository
	var googleSearchScreen: IGoogleSearchScreenViewController?
	private var photos: [GoogleImage]?

	init(repository: INetworkRepository, router: IGoogleSearchScreenRouter) {
		self.router = router
		self.repository = repository
	}
}

extension GoogleSearchScreenPresenter: IGoogleSearchScreenPresenter
{
	func getRandomImages() {
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
	
	func getImages(with searchTerm: String) {
		self.repository.getGoogleImagesInfo(with: searchTerm) { [weak self] googleImagesResult in
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
