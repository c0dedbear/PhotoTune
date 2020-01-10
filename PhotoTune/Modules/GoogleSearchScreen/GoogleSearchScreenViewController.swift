//
//  GoogleSearchScreenViewController.swift
//  PhotoTune
//
//  Created by Саша Руцман on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//
import UIKit

final class GoogleSearchScreenViewController: UIViewController
{
	private let photos: [UIImage] = []
	private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	private var timer: Timer?
	private let searchController = UISearchController(searchResultsController: nil)
	private let layout = CustomCollectionViewLayout()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Search"
		setupCollectionView()
		setupSearchBar()
	}

	private func setupCollectionView() {
		collectionView.backgroundColor = .white
		layout.delegate = self
		collectionView.collectionViewLayout = layout
		collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
		collectionView.dataSource = self
		view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}

	private func setupSearchBar() {
		searchController.obscuresBackgroundDuringPresentation = false
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		searchController.searchBar.delegate = self
		searchController.definesPresentationContext = true
	}
}

extension GoogleSearchScreenViewController: UISearchBarDelegate
{
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 0.5,
									repeats: false,
									block: { _ in
		})
	}
}

extension GoogleSearchScreenViewController: UICollectionViewDataSource
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return photos.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell",
														for: indexPath) as? ImageCollectionViewCell
		guard let cell = photoCell else { return UICollectionViewCell() }
		cell.imageView.image = photos[indexPath.item]
		return cell
	}
}

extension GoogleSearchScreenViewController: CustomCollectionViewLayoutDelegate
{
	func collectionView(
		_ collectionView: UICollectionView,
		heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
		let itemSize = (collectionView.frame.width -
			(collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
		let myImage = photos[indexPath.item]
		let myImageWidth = myImage.size.width
		let myImageHeight = myImage.size.height
		let ratio = itemSize / myImageWidth
		let scaledHeight = myImageHeight * ratio
		return scaledHeight
	}
}
