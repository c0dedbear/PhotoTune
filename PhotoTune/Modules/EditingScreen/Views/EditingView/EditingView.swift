//
//  EditingView.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 23.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

protocol IToolViewDelegate: AnyObject
{
	func applyFilterToImageWith(index: Int)
	func applyTuneSettings(_ settings: TuneSettings)
	func loadTuneSettings() -> TuneSettings?
	func rotateClockwise()
	func rotateAntiClockwise()
}

final class EditingView: UIView
{
	private let imageView = UIImageView()
	private let editingView = UIView()

	private let filtersTools = ToolsCollectionView()
	private let tuneTools = ToolsCollectionView()
	private let rotationTool = RotationView()
	private let slidersStack = ToolSliderView()

	weak var toolsDelegate: IToolViewDelegate?
	weak var toolCollectionViewDataSource: IToolCollectionViewDataSource?

	var currentImage: UIImage? { imageView.image }

	var heightForCell: CGFloat {
		if toolCollectionViewDataSource?.editingType == .filters {
			return imageView.bounds.height / 3.5
		}
		else {
			return imageView.bounds.height / 5
		}
	}

	init() {
		super.init(frame: .zero)
		slidersStack.parentView = self
		setDelegateWithDataSource()
		setupView()
		setConstraints()
		addTools()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func selectFilter() {
		let actualFilter = toolsDelegate?.loadTuneSettings()?.ciFilter
		for (index, filter) in Filter.photoFilters.enumerated() where actualFilter == filter.ciFilter?.name {
			filtersTools.lastSelectedFilter = IndexPath(item: index, section: 0)
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + EditingScreenMetrics.filterSelectionDelay) { [weak self] in
			self?.filtersTools.selectItem(
				at: self?.filtersTools.lastSelectedFilter,
				animated: false,
				scrollPosition: .centeredHorizontally)
		}
	}

	func setImage(_ image: UIImage?) {
		imageView.image = image
	}

	func showSlider(type: TuneTool) {
		slidersStack.isHidden = false
		slidersStack.currentTuneTool = type
	}

	func resetTuneSettings() {
		slidersStack.savedTuneSettings = nil
	}

	func hideAllToolsViews(except: EditingType) {
		editingView.subviews.forEach { $0.isHidden = true }
		switch except {
		case .filters:
			filtersTools.reloadData()
			selectFilter()
			filtersTools.animatedAppearing()
		case .tune:
			tuneTools.reloadData()
			tuneTools.animatedAppearing()
		case .rotation:
			rotationTool.animatedAppearing()
		case .none: break
		}
	}
}

	// MARK: - Private Methods
private extension EditingView
{
	func setDelegateWithDataSource() {
		filtersTools.delegate = self
		filtersTools.dataSource = self
		tuneTools.delegate = self
		tuneTools.dataSource = self
	}

	func setupView() {
		if #available(iOS 13.0, *){
			backgroundColor = .systemBackground
		}
		else { backgroundColor = .white }
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = EditingScreenMetrics.filterCellCornerRadius
		addSubview(imageView)
		addSubview(editingView)
	}

	func setConstraints() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		editingView.translatesAutoresizingMaskIntoConstraints = false

		imageView.anchor(top: safeAreaLayoutGuide.topAnchor,
						 leading: leadingAnchor,
						 bottom: nil,
						 trailing: trailingAnchor,
						 padding: .init(top: 8, left: 8, bottom: 8, right: 8))

		imageView.heightAnchor.constraint(
			equalTo: safeAreaLayoutGuide.heightAnchor,
			multiplier: 0.64).isActive = true

		editingView.anchor(top: imageView.bottomAnchor,
								  leading: leadingAnchor,
								  bottom: safeAreaLayoutGuide.bottomAnchor,
								  trailing: trailingAnchor,
								  padding: .init(top: 8, left: 0, bottom: 0, right: 0))
	}

	func addTools() {
		editingView.addSubview(filtersTools)
		filtersTools.fillSuperview()

		editingView.addSubview(tuneTools)
		tuneTools.fillSuperview()
		editingView.addSubview(slidersStack)

		editingView.addSubview(rotationTool)
		rotationTool.fillSuperview()
		rotationTool.parentView = self
	}
}
