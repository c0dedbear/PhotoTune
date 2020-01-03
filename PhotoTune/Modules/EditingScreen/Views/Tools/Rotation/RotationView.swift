//
//  RotationView.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class RotationView: UIView
{
	weak var parentView: EditingView?

	private let rotateClockwise = UIButton(type: .system)
	private let rotateAntiClockwise = UIButton(type: .system)

	init() {
		super.init(frame: .zero)
		initialSetup()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func initialSetup() {

		if #available(iOS 13.0, *) {
			backgroundColor = .systemBackground
			rotateAntiClockwise.setImage(UIImage(systemName: "rotate.left"), for: .normal)
			rotateClockwise.setImage(UIImage(systemName: "rotate.right"), for: .normal)

			rotateAntiClockwise.tintColor = .label
			rotateClockwise.tintColor = .label
		}
		else {
			backgroundColor = .white
		}

		addSubview(rotateClockwise)
		addSubview(rotateAntiClockwise)

		rotateClockwise.anchor(
			top: nil,
			leading: nil,
			bottom: bottomAnchor,
			trailing: trailingAnchor,
			padding: .init(top: 0, left: 0, bottom: 40, right: 40)
		)

		rotateAntiClockwise.anchor(
			top: nil,
			leading: leadingAnchor,
			bottom: bottomAnchor,
			trailing: nil,
			padding: .init(top: 0, left: 40, bottom: 40, right: 0)
		)

		rotateClockwise.addTarget(self, action: #selector(rotateClockwisePressed), for: .touchUpInside)
		rotateAntiClockwise.addTarget(self, action: #selector(rotateAntiClockwisePressed), for: .touchUpInside)
	}

	@objc private func rotateClockwisePressed() {
		parentView?.toolsDelegate?.rotateClockwise()
	}

	@objc private func rotateAntiClockwisePressed() {
		parentView?.toolsDelegate?.rotateAntiClockwise()
	}
}
