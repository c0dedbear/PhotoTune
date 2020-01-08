//
//  SlidersStackView.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 24.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class ToolSliderView: UIStackView
{
	weak var parentView: EditingView?

	private let intensitySlider = ToolSlider()
	private let cancel = UIButton(type: .system)
	private let done = UIButton(type: .system)

	var savedTuneSettings: TuneSettings? {
		didSet {
			guard let settings = savedTuneSettings else {
				currentTuneSettings = TuneSettings()
				return
			}
			currentTuneSettings = settings
		}
	}

	private var currentTuneSettings: TuneSettings {
		didSet {
			parentView?.toolsDelegate?.applyTuneSettings(currentTuneSettings)
		}
	}

	var currentTuneTool: TuneTool? { didSet { showControls() } }

	init() {
		currentTuneSettings = parentView?.toolsDelegate?.loadTuneSettings() ?? TuneSettings()
		super.init(frame: .zero)
		initialSetup()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func initialSetup() {
		intensitySlider.addTarget(self, action: #selector(intensityChanged), for: .valueChanged)
		addArrangedSubview(intensitySlider)
		buttonConfigure()

		axis = .vertical
		distribution = .equalSpacing
		alignment = .fill
	}

	private func buttonConfigure() {
		cancel.setTitle("Cancel", for: .normal)
		done.setTitle("Done", for: .normal)
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
			   padding: .init(top: 40, left: 20, bottom: 10, right: 20))
	}

	private func showControls() {
		currentTuneSettings = parentView?.toolsDelegate?.loadTuneSettings() ?? TuneSettings()
		switch currentTuneTool {
		case .brightness:
			intensitySlider.configureForBrightness(withValue: savedTuneSettings?.brightnessIntensity
				?? TuneSettingsDefaults.brightnessIntensity)
		case .contrast:
			intensitySlider.configureForContrast(withValue: savedTuneSettings?.contrastIntensity
				?? TuneSettingsDefaults.contrastIntensity)
		case .saturation:
			intensitySlider.configureForSaturation(withValue: savedTuneSettings?.saturationIntensity
				?? TuneSettingsDefaults.saturationIntensity )
		case .vignette:
			intensitySlider.configureForVignetteIntensity(withValue: savedTuneSettings?.vignetteIntensity
				?? TuneSettingsDefaults.vignetteIntensity)
			intensityChanged()
		case .none: break
		}
	}

	@objc func intensityChanged() {
		switch currentTuneTool {
		case .brightness:
			currentTuneSettings.brightnessIntensity = intensitySlider.value
			intensitySlider.updateLabel()
		case .contrast:
			currentTuneSettings.contrastIntensity = intensitySlider.value
			intensitySlider.updateLabel()
		case .saturation:
			currentTuneSettings.saturationIntensity = intensitySlider.value
			intensitySlider.updateLabel()
		case .vignette:
			currentTuneSettings.vignetteIntensity = intensitySlider.value
			currentTuneSettings.vignetteRadius = intensitySlider.value + 1
			intensitySlider.updateLabel(convertValues: false)
		case .none: break
		}
	}

	@objc func cancelTapped() {
		switch currentTuneTool {
		case .brightness:
			currentTuneSettings.brightnessIntensity = savedTuneSettings?.brightnessIntensity
				?? TuneSettingsDefaults.brightnessIntensity
		case .contrast:
			currentTuneSettings.contrastIntensity = savedTuneSettings?.contrastIntensity
				?? TuneSettingsDefaults.contrastIntensity
		case .saturation:
			currentTuneSettings.saturationIntensity = savedTuneSettings?.saturationIntensity
				?? TuneSettingsDefaults.saturationIntensity
		case .vignette:
			currentTuneSettings.vignetteIntensity = savedTuneSettings?.vignetteIntensity
				?? TuneSettingsDefaults.vignetteIntensity
			currentTuneSettings.vignetteRadius = savedTuneSettings?.vignetteRadius
				?? TuneSettingsDefaults.vignetteRadius
		case .none: break
		}
		self.isHidden = true
		parentView?.hideAllToolsViews(except: .tune)
	}

	@objc func doneTapped() {
		savedTuneSettings = currentTuneSettings
		savedTuneSettings?.resetToActualSettings()
		self.isHidden = true
		parentView?.hideAllToolsViews(except: .tune)
	}
}
