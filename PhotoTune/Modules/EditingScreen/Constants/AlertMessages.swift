//
//  AlertMessages.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 11.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import Foundation

enum AlertMessages
{
	static let error = "Error".localized
	static let saveNewImagesAsExisting = "Trying to save new Image as Existing".localized
	static let nothingToSave = "Nothing to save".localized
	static let noStoredData = "No stored data".localized
	static let cancelTappedTitle = "Closing Editor".localized
	static let cancelTappedMessage = "Do you really want close editor?\nIf you have unsaved settings, they will be lost. "
		.localized
}
