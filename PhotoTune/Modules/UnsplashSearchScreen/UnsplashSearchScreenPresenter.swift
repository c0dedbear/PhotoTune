//
//  UnsplashSearchScreenPresenter.swift
//  PhotoTune
//
//  Created by Саша Руцман on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IUnsplashSearchScreenPresenter
{
	func getImages(with searchTerm: String?, page: Int?)
	func loadImage(urlString: String, cell: Bool, _ completion: @escaping (UIImage?) -> Void)
	func cancelFetchData(wirhUrl url: String)
}

final class UnsplashSearchScreenPresenter
{
	private let router: IUnsplashSearchScreenRouter
	private let networkService: INetworkService
	var unsplashSearchScreen: IUnsplashSearchScreenViewController?
	private var photos: [UnsplashImage]?

	init(networkService: INetworkService, router: IUnsplashSearchScreenRouter) {
		self.router = router
		self.networkService = networkService
	}
}

extension UnsplashSearchScreenPresenter: IUnsplashSearchScreenPresenter
{
	func getImages(with searchTerm: String?, page: Int?) {
		self.networkService.getUnsplashImagesInfo(with: searchTerm, page: page) { [weak self] unsplashImagesResult in
			guard let self = self else { return }
			switch unsplashImagesResult {
			case .success(let data):
				DispatchQueue.main.async {
					if data.count == 0 {
						self.unsplashSearchScreen?.checkResultOfRequest(isEmpty: true, errorText: "", searchTerm: searchTerm)
					}
					else {
						self.unsplashSearchScreen?.checkResultOfRequest(isEmpty: false, errorText: "", searchTerm: nil)
						self.unsplashSearchScreen?.updatePhotosArray(photosInfo: data)
					}
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self.unsplashSearchScreen?.checkResultOfRequest(isEmpty: true,
																  errorText: error.localizedDescription,
																  searchTerm: nil)
				}
			}
		}
	}

	func loadImage(urlString: String, cell: Bool, _ completion: @escaping (UIImage?) -> Void) {
		self.networkService.loadImage(urlString: urlString) { [weak self] imageResult in
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

	func cancelFetchData(wirhUrl url: String) {
		networkService.cancelFetchData(withUrl: url)
	}
}
