//
//  UnsplashImage.swift
//  PhotoTune
//
//  Created by Саша Руцман on 11.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//
import Foundation

struct SearchResults: Decodable
{
	let total: Int
	let results: [UnsplashImage]
}

struct UnsplashImage: Decodable
{
	let id: String
	let width, height: Int
	let color: String
	let urls: UnsplashImageUrls
}

struct UnsplashImageUrls: Decodable
{
	let raw, full, regular, small: String
	let thumb: String
}
