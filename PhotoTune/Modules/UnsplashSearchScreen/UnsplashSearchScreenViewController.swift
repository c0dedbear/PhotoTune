//
//  UnsplashSearchScreenViewController.swift
//  PhotoTune
//
//  Created by Саша Руцман on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IUnsplashSearchScreenViewController
{
	func updateCellImage(index: Int, image: UIImage)
	func updatePhotosArray(photosInfo: [UnsplashImage])
	func checkResultOfRequest(isEmpty: Bool, errorText: String, searchTerm: String?)
}

final class UnsplashSearchScreenViewController: UIViewController
{
	private let presenter: IUnsplashSearchScreenPresenter
	private var timer: Timer?
	private let searchController = UISearchController(searchResultsController: nil)
	private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	private let layout = CustomCollectionViewLayout()
	private var photos = [UnsplashImage]()
	private let searchStubLabel = UILabel()
	private var searchText = ""
	private var page = 1

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		self.title = "Search"
		setupSearchBar()
		setupCollectionView()
		setupSearchStubLabel()
		presenter.getImages(with: nil, page: nil)
	}

	init(presenter: IUnsplashSearchScreenPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupSearchBar() {
		searchController.obscuresBackgroundDuringPresentation = false
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		searchController.searchBar.delegate = self
		searchController.definesPresentationContext = true
	}

	private func setupCollectionView() {
		if #available(iOS 13.0, *) {
			collectionView.backgroundColor = .systemBackground
		}
		else {
			collectionView.backgroundColor = .white
		}
		layout.delegate = self
		collectionView.collectionViewLayout = layout
		collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
		collectionView.dataSource = self
		collectionView.delegate = self
		view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}

	private func setupSearchStubLabel() {
		view.backgroundColor = .white
		view.addSubview(searchStubLabel)
		searchStubLabel.textColor = .gray
		searchStubLabel.numberOfLines = 0
		searchStubLabel.textAlignment = .center
		searchStubLabel.isHidden = true
		searchStubLabel.translatesAutoresizingMaskIntoConstraints = false
		searchStubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		searchStubLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
	}

	private func presentAlert(index: Int) {
		let alert = UIAlertController(title: "Select an image",
									  message: "By clicking on the \"Select\" button, you will enter the editing mode",
									  preferredStyle: .alert)
		let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
					self.presenter.loadImage(urlString: self.photos[index].urls.regular, cell: false) { _ in }
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(cancelAction)
		alert.addAction(selectAction)
		present(alert, animated: true)
	}
}

extension UnsplashSearchScreenViewController: UISearchBarDelegate
{
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 0.5,
									 repeats: false,
									 block: { [weak self] _ in
										if searchText.isEmpty {
											return
										}
										else {
											guard let self = self else { return }
											self.searchText = searchText
											self.photos = []
											self.presenter.getImages(with: searchText, page: 1)
										}
		})
	}
}

extension UnsplashSearchScreenViewController: IUnsplashSearchScreenViewController
{
	func updateCellImage(index: Int, image: UIImage) {
		guard let cell = self.collectionView.cellForItem(at: IndexPath(row: index,
																	   section: 0)) as? ImageCollectionViewCell else { return }
		cell.imageView.image = image
	}

	func updatePhotosArray(photosInfo: [UnsplashImage]) {
		let photosCount = self.photos.count
		self.photos += photosInfo
		var indexPaths = [IndexPath]()
		for item in photosCount..<photosCount + photosInfo.count - 1 {
			indexPaths.append(IndexPath(item: item, section: 0))
		}
		collectionView.reloadData()
	}

	func checkResultOfRequest(isEmpty: Bool, errorText: String, searchTerm: String?) {
		if isEmpty && photos.count == 0 {
			self.collectionView.isHidden = true
			self.searchStubLabel.isHidden = false
			if searchTerm != nil {
				self.searchStubLabel.text = "Nothing found of query \"\(searchController.searchBar.text ?? "")\""
			}
			else {
				self.searchStubLabel.text = errorText
			}
		}
		else {
			self.collectionView.isHidden = false
			self.searchStubLabel.isHidden = true
		}
	}
}

extension UnsplashSearchScreenViewController: UICollectionViewDataSource
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return photos.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell",
														for: indexPath) as? ImageCollectionViewCell
		guard let cell = photoCell else { return UICollectionViewCell() }
		presenter.loadImage(urlString: photos[indexPath.item].urls.small,
							cell: true) { image in
			cell.imageView.image = image
		}
		cell.layoutIfNeeded()
		return cell
	}
}

extension UnsplashSearchScreenViewController: UICollectionViewDelegate
{
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		presentAlert(index: indexPath.item)
	}

	func collectionView(_ collectionView: UICollectionView,
						willDisplay cell: UICollectionViewCell,
						forItemAt indexPath: IndexPath) {
		if indexPath.item == photos.count - 10 {
			if searchText.isEmpty {
				presenter.getImages(with: nil, page: nil)
			}
			else {
				page += 1
				presenter.getImages(with: searchText, page: page)
			}
		}
	}
}

extension UnsplashSearchScreenViewController: CustomCollectionViewLayoutDelegate
{
	func collectionView(_ layout: CustomCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let photo = photos[indexPath.item]
		return CGSize(width: photo.width, height: photo.height)
	}
}
