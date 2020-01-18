//
//  NetworkService.swift
//  PhotoTune
//
//  Created by Саша Руцман on 11.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

typealias UnsplashImageInfoResult = Result<[UnsplashImage], NetworkError>
typealias DataResult = Result<Data, NetworkError>
typealias ImageResult = Result<UIImage, NetworkError>

protocol INetworkService
{
	func getUnsplashImagesInfo(with searchTerm: String?,
							   page: Int?,
							   _ completion: @escaping (UnsplashImageInfoResult) -> Void)
	func loadImage(urlString: String, _ completion: @escaping (ImageResult) -> Void)
	func cancelFetchData(withUrl url: String)
}

final class NetworkService
{
	private let fetchDataQueue = DispatchQueue(label: "fetchDataQueue",
											   qos: .userInteractive,
											   attributes: .concurrent)
	private var dataTasks: [URLSessionDataTask] = []

	private func fetchData(from url: URL, _ completion: @escaping(DataResult) -> Void) {
		var urlRequest = URLRequest(url: url)
		urlRequest.setValue("Client-ID \(Constants.accessKey)",
							forHTTPHeaderField: "Authorization")
		let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
			self.fetchDataQueue.async {
				if error != nil {
					completion(.failure(.sessionError))
					return
				}
				if let data = data {
					completion(.success(data))
				}
			}
		}
		task.resume()
		dataTasks.append(task)
	}

	private func createUrl(searchTerm: String?, page: Int?) -> URL? {
		if let page = page, let searchTerm = searchTerm?.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed) {
			return URL.with(string: Urls.searchPhotosUrl + "\(searchTerm)" + "&page=" + "\(page)")
		}
		else {
			return URL.with(string: "photos/random?count=20")
		}
	}
}

extension NetworkService: INetworkService
{
	func getUnsplashImagesInfo(with searchTerm: String?,
							   page: Int?,
							   _ completion: @escaping (UnsplashImageInfoResult) -> Void) {
		if let url = createUrl(searchTerm: searchTerm, page: page) {
			fetchData(from: url) { dataResult in
				switch dataResult {
				case .success(let data):
					do {
						let unsplashImages = try JSONDecoder().decode(SearchResults.self, from: data)
						completion(.success(unsplashImages.results))
					}
					catch {
						do {
							let unsplashImages = try JSONDecoder().decode([UnsplashImage].self, from: data)
							completion(.success(unsplashImages))
						}
						catch {
							completion(.failure(NetworkError.dataError))
							return
						}
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

	func cancelFetchData(withUrl url: String) {
		guard let dataTaskIndex = dataTasks.firstIndex(where: { task in
			if let taskUrl = task.originalRequest?.url {
				if String(describing: taskUrl) == url {
					return true
				}
			}
			return false
		}) else { return }
		let dataTask = dataTasks[dataTaskIndex]
		dataTask.cancel()
		dataTasks.remove(at: dataTaskIndex)
	}
}
