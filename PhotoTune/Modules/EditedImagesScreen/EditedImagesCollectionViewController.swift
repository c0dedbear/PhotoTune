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
	private let layout = CustomCollectionViewLayout()
	private let reuseIdentifier = "Cell"
	private var images = [EditedImage]()
	private let addingView = AddingView()

	init(presenter: IEditedImagesPresenter) {
		self.presenter = presenter
		super.init(collectionViewLayout: layout.getLayout())
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(addingView)
		addingView.addingButton.addTarget(self, action: #selector(addingButtonPressed), for: .touchUpInside)
		self.collectionView.register(EditedImagesScreenCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		images = presenter.getImages()
		makeConstraints()
	}

	override func collectionView(_ collectionView: UICollectionView,
								 numberOfItemsInSection section: Int) -> Int { images.count }

	override func collectionView(_ collectionView: UICollectionView,
								 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
													  for: indexPath) as? EditedImagesScreenCell
		cell?.imageView.image = UIImage(named: images[indexPath.row].imagePath)

		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedCellLeft))
		swipeLeft.direction = .left
		cell?.addGestureRecognizer(swipeLeft)
		cell?.isUserInteractionEnabled = true

		return cell ?? UICollectionViewCell()
	}

	@objc private func swipedCellLeft(_ sender: UISwipeGestureRecognizer) {
		guard let cell = sender.view as? EditedImagesScreenCell else { return }
		guard let itemIndex = self.collectionView.indexPath(for: cell)?.item else { return }
		images.remove(at: itemIndex)
		self.collectionView.reloadData()
	}

	private func makeConstraints() {
		addingView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			addingView.leftAnchor.constraint(equalTo: view.leftAnchor),
			addingView.rightAnchor.constraint(equalTo: view.rightAnchor),
			addingView.topAnchor.constraint(equalTo: view.topAnchor),
			addingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}

	@objc private func addingButtonPressed(_ sender: UIButton) {
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

	private func cancelAction(_ alert: UIAlertController, _ sender: UIButton) {
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(cancelAction)
		alert.popoverPresentationController?.sourceView = sender
		present(alert, animated: true)
		addingView.isHidden = true
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
