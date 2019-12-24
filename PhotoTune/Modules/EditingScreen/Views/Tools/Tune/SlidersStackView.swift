//
//  SlidersStackView.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 24.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class SlidersStackView: UIStackView
{
	private let radiusSlider = ToolSlider()
	private let intensitySlider = ToolSlider()
	private let cancel = UIButton(type: .system)
	private let done = UIButton(type: .system)

	weak var mainView: EditingScreenMainView?

	init() {
		super.init(frame: .zero)
		initialSetup()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func initialSetup() {
		addArrangedSubview(radiusSlider)
		addArrangedSubview(intensitySlider)
		buttonConfigure()

		axis = .vertical
		distribution = .equalSpacing
		alignment = .fill
	}

	private func buttonConfigure() {
		cancel.setTitle("Cancel", for: .normal)
		done.setTitle("Save", for: .normal)
		done.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
		cancel.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)

		cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
		done.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

		if #available(iOS 13.0, *) {
			cancel.setTitleColor(.label, for: .normal)
			done.setTitleColor(.label, for: .normal)
		}
		else {
			cancel.setTitleColor(.black, for: .normal)
			done.setTitleColor(.black, for: .normal)
		}

		let horizontalStack = UIStackView()
		horizontalStack.addArrangedSubview(cancel)
		horizontalStack.addArrangedSubview(done)
		horizontalStack.axis = .horizontal
		horizontalStack.distribution = .equalSpacing
		addArrangedSubview(horizontalStack)
	}

	override func layoutSubviews() {
		anchor(top: superview?.topAnchor,
			   leading: superview?.leadingAnchor,
			   bottom: superview?.bottomAnchor,
			   trailing: superview?.trailingAnchor,
			   padding: .init(top: 0, left: 20, bottom: 10, right: 20))
	}

	private func resetSliders() {
		intensitySlider.value = 0
		radiusSlider.value = 0
	}

	@objc func cancelTapped() {
		resetSliders()
		self.isHidden = true
		mainView?.hideAllToolsViews(except: .tune)
	}

	@objc func doneTapped() {
		self.isHidden = true
		mainView?.hideAllToolsViews(except: .tune)
		//save image and tool state
	}
}
