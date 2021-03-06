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

	private let throttler = Throttler(minimumDelay: EditingScreenMetrics.sliderThrottlingDelay)
	private let haptics = UIImpactFeedbackGenerator(style: .light)

	var savedTuneSettings: TuneSettings? {
		didSet {
			guard let settings = savedTuneSettings else { return }
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
		distribution = .fillProportionally
		alignment = .fill
	}

	private func buttonConfigure() {
		cancel.setTitle("Cancel".localized, for: .normal)
		done.setTitle("Done".localized, for: .normal)
		done.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
		cancel.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)

		cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
		done.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

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
		intensitySlider.tuneSettings = currentTuneSettings
		switch currentTuneTool {
		case .brightness:
			intensitySlider.configureForBrightness()
		case .contrast:
			intensitySlider.configureForContrast()
		case .saturation:
			intensitySlider.configureForSaturation()
		case .sharpness:
			intensitySlider.configureForSharpness()
		case .vignette:
			intensitySlider.configureForVignetteIntensity()
			intensityChanged() //for immediately applying vignette effect
		case .none: break
		}
	}

	@objc func intensityChanged() {
		switch currentTuneTool {
		case .vignette:
			intensitySlider.updateLabel(convertValues: false)
		default:
			intensitySlider.updateLabel()
		}

		throttler.throttle {
			self.changeSettings()
			if self.intensitySlider.isHapticsNeeded {
				self.haptics.impactOccurred()
			}
		}
	}

	private func changeSettings() {
		switch currentTuneTool {
		case .brightness:
			currentTuneSettings.brightnessIntensity = intensitySlider.value
		case .contrast:
			currentTuneSettings.contrastIntensity = intensitySlider.value
		case .saturation:
			currentTuneSettings.saturationIntensity = intensitySlider.value
		case .sharpness:
			currentTuneSettings.sharpnessIntensity = intensitySlider.value
		case .vignette:
			currentTuneSettings.vignetteIntensity = intensitySlider.value
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
		case .sharpness:
			currentTuneSettings.sharpnessIntensity = savedTuneSettings?.sharpnessIntensity
				?? TuneSettingsDefaults.sharpnessIntensity
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
