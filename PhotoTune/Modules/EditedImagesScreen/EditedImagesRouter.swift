//
//  EditedImagesRouter.swift
//  PhotoTune
//
//  Created by MacBook Air on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import Foundation

protocol IEditedImagesRouter
{
}

final class EditedImagesRouter
{
	weak var viewController: EditedImagesCollectionViewController?

	private var factory: ModulesFactory

	init(factory: ModulesFactory) {
		self.factory = factory
	}
}

extension EditedImagesRouter: IEditedImagesRouter
{
}
