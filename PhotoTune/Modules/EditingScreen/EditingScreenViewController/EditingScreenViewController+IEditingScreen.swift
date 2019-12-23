//
//  EditingScreenViewController+IEditingScreen.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 21.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IEditingScreen
{
	func showFiltersCollection()
	func showTuneView()
	func showRotationView()
}

	// MARK: - IEditingScreen
extension EditingScreenViewController: IEditingScreen
{
	func showFiltersCollection() {
		hideAllToolsViews(except: .filters)
	}

	func showTuneView() {
		hideAllToolsViews(except: .tune)
	}

	func showRotationView() {
		hideAllToolsViews(except: .rotation)
	}
}
