//
//  ImageZoomView.swift
//  PhotoTune
//
//  Created by Mikhail Medvedev on 17.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class ImageZoomView: UIScrollView
{
	private let imageView = UIImageView()
	private var gestureRecognizer: UITapGestureRecognizer?

	var currentImage: UIImage? { imageView.image }

	func setImage(_ image: UIImage?) {
		imageView.image = image
	}

	init() {
		super.init(frame: .zero)
		imageView.frame = frame
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)

		setupScrollView()
		setupGestureRecognizer()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupScrollView() {
		minimumZoomScale = 1.0
		maximumZoomScale = 2.0
		delegate = self
	}

	private func setupGestureRecognizer() {
		gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
		gestureRecognizer?.numberOfTapsRequired = 2
		addGestureRecognizer(gestureRecognizer ?? UIGestureRecognizer())
	}

	private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
		var zoomRect = CGRect.zero
		zoomRect.size.height = imageView.frame.size.height / scale
		zoomRect.size.width = imageView.frame.size.width / scale
		let newCenter = convert(center, from: imageView)
		zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
		zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
		return zoomRect
	}

	@objc private  func handleDoubleTap() {
		guard let recognizer = gestureRecognizer else { return }
		if zoomScale == 1 {
			zoom(to: zoomRectForScale(maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
		}
		else {
			setZoomScale(1, animated: true)
		}
	}
}

extension ImageZoomView: UIScrollViewDelegate
{
	func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
}
