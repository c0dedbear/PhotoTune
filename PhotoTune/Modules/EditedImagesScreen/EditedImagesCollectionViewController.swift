//
//  EditedImagesCollectionViewController.swift
//  PhotoTune
//
//  Created by MacBook Air on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class EditedImagesCollectionViewController: UICollectionViewController
{
	private let presenter: IEditedImagesPresenter
	private let reuseIdentifier = "Cell"
	private var images = [EditedImage]()
	private let addingView = AddingView()
	private let layout: UICollectionViewLayout = {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 30, height: UIScreen.main.bounds.width / 2 - 30)
		layout.minimumInteritemSpacing = 20
		layout.minimumLineSpacing = 20
		layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		return layout
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
		images = presenter.getImages()
		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		images = presenter.getImages()
	}

	override func collectionView(_ collectionView: UICollectionView,
								 numberOfItemsInSection section: Int) -> Int { images.count }

	override func collectionView(_ collectionView: UICollectionView,
								 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
													  for: indexPath) as? EditedImagesScreenCell
		cell?.imageView.image = UIImage(named: images[indexPath.row].previewFileName)
		return cell ?? UICollectionViewCell()
	}
}

private extension EditedImagesCollectionViewController
{
	func setupView() {
		if #available(iOS 13.0, *){
			collectionView.backgroundColor = .systemBackground
		}
		else { collectionView.backgroundColor = .white }

		collectionView.register(EditedImagesScreenCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		view.addSubview(addingView)
		addingView.addingButton.addTarget(self, action: #selector(addingButtonPressed), for: .touchUpInside)

		addingView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			addingView.leftAnchor.constraint(equalTo: view.leftAnchor),
			addingView.rightAnchor.constraint(equalTo: view.rightAnchor),
			addingView.topAnchor.constraint(equalTo: view.topAnchor),
			addingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])

		if images.isEmpty {
			collectionView.isHidden = true
			addingView.isHidden = false
		}
		else { addingView.isHidden = true }
	}

	@objc func addingButtonPressed(_ sender: UIButton) {
		let alert = UIAlertController(title: "Choose image source", message: nil, preferredStyle: .actionSheet)
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self

		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
				imagePicker.sourceType = .camera
				self.present(imagePicker, animated: true)
			}
			alert.addAction(cameraAction)
		}
		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			let photoLibraryAction = UIAlertAction(title: "PhotoLibrary", style: .default) { _ in
				imagePicker.sourceType = .photoLibrary
				self.present(imagePicker, animated: true)
			}
			alert.addAction(photoLibraryAction)
		}

		let findAction = UIAlertAction(title: "Find with Google", style: .default) { _ in
			//Переход в модуль поиска
		}
		alert.addAction(findAction)

		cancelAction(alert, sender)
	}

	func cancelAction(_ alert: UIAlertController, _ sender: UIButton) {
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(cancelAction)
		alert.popoverPresentationController?.sourceView = sender
		present(alert, animated: true)
	}
}

extension EditedImagesCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		guard let selectedImage = info[.originalImage] as? UIImage else { return }
		//Передать выбранную картинку в модуль редактирования
		dismiss(animated: true)
	}
}
