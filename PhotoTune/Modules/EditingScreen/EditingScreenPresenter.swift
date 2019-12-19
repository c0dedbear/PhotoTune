//
//  EditingScreenPresenter.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IEditingScreenPresenter
{
	func filtersToolPressed()
	func tuneToolPressed()
	func rotationToolPressed()
	func getImage() -> UIImage
}

final class EditingScreenPresenter
{
	private let router: IEditingScreenRouter
	private let image: UIImage
	private var editingScreen: IEditingScreen?

	init(image: UIImage, router: IEditingScreenRouter) {
		self.router = router
		self.image = image
	}
}

extension EditingScreenPresenter: IEditingScreenPresenter
{
	func filtersToolPressed() { editingScreen?.showFiltersCollection() }

	func tuneToolPressed() { editingScreen?.showSlidersView() }

	func rotationToolPressed() { editingScreen?.showRotationView() }

	func getImage() -> UIImage { image }
}
