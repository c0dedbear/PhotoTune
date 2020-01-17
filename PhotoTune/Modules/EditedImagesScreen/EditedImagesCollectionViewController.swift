//
//  EditedImagesCollectionViewController.swift
//  PhotoTune
//
//  Created by MacBook Air on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IEditedImagesCollectionViewController: AnyObject
{
	func updateCollectionView()
}

final class EditedImagesCollectionViewController: UICollectionViewController
{
	enum Mode
	{
		case view, select
	}

	private let presenter: IEditedImagesPresenter
	private let reuseIdentifier = "Cell"
	private let addingView = AddingView()
	private let layout: UICollectionViewLayout = {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 30, height: UIScreen.main.bounds.width / 2 - 30)
		layout.minimumInteritemSpacing = 20
		layout.minimumLineSpacing = 20
		layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		return layout
	}()

	private var dictionarySelectedIndexPaths: [IndexPath: Bool] = [:]
	private var mode: Mode = .view {
		didSet {
			switch mode {
			case .view:
				for (key, value) in dictionarySelectedIndexPaths where value {
					collectionView.deselectItem(at: key, animated: true)
		  		}
		  		dictionarySelectedIndexPaths.removeAll()
				navigationItem.rightBarButtonItem = addBarButton
				editBarButton.title = "Edit"
				collectionView.allowsMultipleSelection = false
			case .select:
				navigationItem.rightBarButtonItem = deleteBarButton
				editBarButton.title = "Cancel"
		  		collectionView.allowsMultipleSelection = true
			}
		}
	}

	private lazy var editBarButton: UIBarButtonItem = {
		let barButtonItem = UIBarButtonItem(title: "Edit",
											style: .plain,
											target: self,
											action: #selector(editButtonTapped))
		return barButtonItem
	}()

	private lazy var deleteBarButton: UIBarButtonItem = {
		let barButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
											target: self,
											action: #selector(deleteButtonTapped))
		return barButtonItem
	}()

	private lazy var addBarButton: UIBarButtonItem = {
		let barButtonItem = UIBarButtonItem(image: UIImage(named: "addicon"),
											style: .plain,
											target: self,
											action: #selector(addButtonTapped))
		return barButtonItem
	}()

	init(presenter: IEditedImagesPresenter) {
		self.presenter = presenter
		super.init(collectionViewLayout: layout)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		presenter.loadImages()
		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		presenter.loadImages()
		checkNumberOfItems()
	}
}

extension EditedImagesCollectionViewController
{
	override func collectionView(_ collectionView: UICollectionView,
								 numberOfItemsInSection section: Int) -> Int { presenter.getImages().count }

	override func collectionView(_ collectionView: UICollectionView,
								 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
													  for: indexPath) as? EditedImagesScreenCell
		let editedImage = presenter.getImages()[indexPath.row]
		cell?.imageView.image = presenter.getPreviewFor(editedImage)
		cell?.dateLabel.text = "Edited: \(editedImage.formattedDate)"
		return cell ?? UICollectionViewCell()
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch mode {
		case .view:
			collectionView.deselectItem(at: indexPath, animated: true)
			let selectedImage = presenter.getImages()[indexPath.row]
			presenter.transferImageForEditing(image: nil, editedImage: selectedImage)
		case .select:
			dictionarySelectedIndexPaths[indexPath] = true
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if mode == .select {
			dictionarySelectedIndexPaths[indexPath] = false
		}
	}
}

extension EditedImagesCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		guard let selectedImage = info[.editedImage] as? UIImage else { return }
		dismiss(animated: true)
		presenter.transferImageForEditing(image: selectedImage, editedImage: nil)
	}
}

extension EditedImagesCollectionViewController: IEditedImagesCollectionViewController
{
	func updateCollectionView() {
		collectionView.reloadData()
	}
}

private extension EditedImagesCollectionViewController
{
	func setupView() {
		title = "PhotoTune"
		navigationItem.rightBarButtonItem = addBarButton
		navigationItem.leftBarButtonItem = editBarButton
		let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.backBarButtonItem = backButton
		deleteBarButton.tintColor = .red

		if #available(iOS 13.0, *) {
			collectionView.backgroundColor = .systemBackground
		}
		else { collectionView.backgroundColor = .white }
		collectionView.register(EditedImagesScreenCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		view.addSubview(addingView)
		addingView.addingButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

		addingView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			addingView.leftAnchor.constraint(equalTo: view.leftAnchor),
			addingView.rightAnchor.constraint(equalTo: view.rightAnchor),
			addingView.topAnchor.constraint(equalTo: view.topAnchor),
			addingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
		checkNumberOfItems()
	}

	func checkNumberOfItems() {
		if presenter.getImages().isEmpty {
			addingView.isHidden = false
			editBarButton.title = "Edit"
			editBarButton.isEnabled = false
			deleteBarButton.isEnabled = false
			navigationItem.rightBarButtonItem = addBarButton
		}
		else {
			addingView.isHidden = true
			editBarButton.isEnabled = true
			deleteBarButton.isEnabled = true
		}
	}

	@objc func addButtonTapped(_ sender: UIButton) {
		let alert = UIAlertController(title: "Choose image source", message: nil, preferredStyle: .actionSheet)
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.allowsEditing = true

		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
				imagePicker.sourceType = .camera
				self.present(imagePicker, animated: true)
			}
			cameraAction.setValue(UIImage(named: "camera"), forKey: "image")
			alert.addAction(cameraAction)
		}
		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			let photoLibraryAction = UIAlertAction(title: "PhotoLibrary", style: .default) { _ in
				imagePicker.sourceType = .photoLibrary
				self.present(imagePicker, animated: true)
			}
			photoLibraryAction.setValue(UIImage(named: "image-gallery"), forKey: "image")
			alert.addAction(photoLibraryAction)
		}

		let findAction = UIAlertAction(title: "Find with Unsplash", style: .default) { _ in
			self.presenter.transferToSearchScreen()
		}
		findAction.setValue(UIImage(named: "unsplash"), forKey: "image")
		alert.addAction(findAction)

		cancelAction(alert, sender)
	}

	func cancelAction(_ alert: UIAlertController, _ sender: UIButton) {
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(cancelAction)
		alert.popoverPresentationController?.sourceView = sender
		alert.pruneNegativeWidthConstraints()
		present(alert, animated: true)
	}
	@objc func editButtonTapped() {
		if presenter.getImages().count > 0 {
			if mode == .view {
				mode = .select
			}
			else { mode = .view }
		}
	}
	@objc func deleteButtonTapped() {
		guard let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems else { return }
		presenter.deleteImagesFromStorage(selectedIndexPaths)
		mode = .view
		checkNumberOfItems()
	}
}
