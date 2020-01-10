//
//  GoogleSearchScreenPresenter.swift
//  PhotoTune
//
//  Created by Саша Руцман on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import Foundation

protocol IGoogleSearchScreenPresenter
{
}

final class GoogleSearchScreenPresenter
{
	private let router: IGoogleSearchScreenRouter
	var googleSearchScreen: IGoogleSearchScreenViewController?

	init(router: IGoogleSearchScreenRouter) {
		self.router = router
	}
}

extension GoogleSearchScreenPresenter: IGoogleSearchScreenPresenter
{
}
