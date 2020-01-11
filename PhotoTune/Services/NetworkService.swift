//
//  NetworkService.swift
//  PhotoTune
//
//  Created by Саша Руцман on 11.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

typealias GoogleImageInfoResult = Result<[GoogleImage], ServiceError>
typealias DataResult = Result<Data, ServiceError>
typealias ImageResult = Result<UIImage, ServiceError>

protocol INetworkService
{
	func getRandomGoogleImagesInfo(_ completion: @escaping (GoogleImageInfoResult) -> Void)
	func loadImage(urlString: String, _ completion: @escaping (ImageResult) -> Void)
}

final class NetworkService
{
	private func fetchData(from url: URL, _ completion: @escaping(DataResult) -> Void) {
		var urlRequest = URLRequest(url: url)
		urlRequest.setValue("Client-ID \(Constants.accessKey)",
							forHTTPHeaderField: "Authorization")
		let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
			if let newError = error {
				completion(.failure(.sessionError(newError)))
				return
			}
			if let data = data {
				completion(.success(data))
			}
		}
		task.resume()
	}
}

extension NetworkService: INetworkService
{
	func getRandomGoogleImagesInfo(_ completion: @escaping (GoogleImageInfoResult) -> Void) {
		if let url = URL.with(string: "photos/random?count=10") {
			fetchData(from: url) { dataResult in
				switch dataResult {
				case .success(let data):
					do {
						let googleImages = try JSONDecoder().decode([GoogleImage].self, from: data)
						completion(.success(googleImages))
					}
					catch {
						completion(.failure(ServiceError.dataError(error)))
						return
					}
				case .failure(let error):
					completion(.failure(error))
				}
			}
		}
	}

	func loadImage(urlString: String, _ completion: @escaping (ImageResult) -> Void) {
		if let url = URL(string: urlString) {
			fetchData(from: url) { imageResult in
				switch imageResult {
				case .success(let data):
					guard let image = UIImage(data: data) else { return }
					completion(.success(image))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		}
	}
}
