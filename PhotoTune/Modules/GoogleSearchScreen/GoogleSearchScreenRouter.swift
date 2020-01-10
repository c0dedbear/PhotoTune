//
//  GoogleSearchScreenRouter.swift
//  PhotoTune
//
//  Created by Саша Руцман on 08.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import Foundation

protocol IGoogleSearchScreenRouter
{
}

final class GoogleSearchScreenRouter
{
		private var factory: ModulesFactory
		weak var destinationViewController: EditingScreenViewController?

		init(factory: ModulesFactory) {
			self.factory = factory
		}
}

extension GoogleSearchScreenRouter: IGoogleSearchScreenRouter
{
}
