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
	func loadImage(urlString: String, cell: Bool, _ completion: @escaping (UIImage?) -> Void)
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
					if data.count == 0 {
						self.googleSearchScreen?.checkResultOfRequest(isEmpty: true, errorText: "", searchTerm: nil)
					}
					else {
						self.googleSearchScreen?.checkResultOfRequest(isEmpty: false, errorText: "", searchTerm: nil)
						self.googleSearchScreen?.updatePhotosArray(photosInfo: data)
					}
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self.googleSearchScreen?.checkResultOfRequest(isEmpty: true,
																  errorText: error.localizedDescription,
																  searchTerm: nil)
				}
			}
		}
	}

	func getImages(with searchTerm: String) {
		self.repository.getGoogleImagesInfo(with: searchTerm) { [weak self] googleImagesResult in
			guard let self = self else { return }
			switch googleImagesResult {
			case .success(let data):
				DispatchQueue.main.async {
					if data.count == 0 {
						self.googleSearchScreen?.checkResultOfRequest(isEmpty: true, errorText: "", searchTerm: searchTerm)
					}
					else {
						self.googleSearchScreen?.checkResultOfRequest(isEmpty: false, errorText: "", searchTerm: nil)
						self.googleSearchScreen?.updatePhotosArray(photosInfo: data)
					}
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self.googleSearchScreen?.checkResultOfRequest(isEmpty: true,
																  errorText: error.localizedDescription,
																  searchTerm: nil)
				}
			}
		}
	}

	func loadImage(urlString: String, cell: Bool, _ completion: @escaping (UIImage?) -> Void) {
		self.repository.loadImage(urlString: urlString) { [weak self] imageResult in
		guard let self = self else { return }
		switch imageResult {
		case .success(let image):
			DispatchQueue.main.async {
				if cell {
					completion(image)
				}
				else {
					self.router.goToTheEditingScreen(image: image)
				}
			}
		case .failure: break
			}
		}
	}
}
