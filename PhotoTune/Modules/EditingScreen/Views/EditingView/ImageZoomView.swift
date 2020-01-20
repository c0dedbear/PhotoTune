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
	private var imageView: UIImageView?

	private lazy var doubleTap: UITapGestureRecognizer = {
		let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
		zoomingTap.numberOfTapsRequired = 2
		return zoomingTap
	}()

	var currentImage: UIImage? { imageView?.image }
	var previousImageSize: CGSize?

	func setImage(_ image: UIImage?) {
		guard let image = image else { return }
		if let prevImageSize = previousImageSize, prevImageSize == image.size {
			imageView?.image = image
			configureFor(imageSize: image.size, scale: zoomScale)
		}
		else {
			imageView?.removeFromSuperview()
			imageView = nil
			imageView = UIImageView(image: image)

			if let imageView = imageView {
				addSubview(imageView)
				configureFor(imageSize: image.size, scale: minimumZoomScale)
				previousImageSize = image.size
			}
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		centerImage()
	}

	init() {
		super.init(frame: .zero)
		setupScrollView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
// MARK: - Private Methods
private extension ImageZoomView
{
	func configureFor(imageSize: CGSize, scale: CGFloat) {
		contentSize = imageSize
		setActualMaxAndMinZoonScaling()
		zoomScale = scale
		imageView?.addGestureRecognizer(doubleTap)
		imageView?.isUserInteractionEnabled = true
	}

	func setupScrollView() {
		showsVerticalScrollIndicator = false
		showsHorizontalScrollIndicator = false
		bouncesZoom = true
		bounces = true
		delegate = self
	}

	func setActualMaxAndMinZoonScaling() {
		guard let imageView = imageView else { return }
		let boundsSize = bounds.size
		let imageSize = imageView.bounds.size

		let xScale = boundsSize.width / imageSize.width
		let yScale = boundsSize.height / imageSize.height

		let minScale = min(xScale, yScale)

		var maxScale: CGFloat = 1.0

		if minScale < 0.1 {
			maxScale = 0.3
		}
		if minScale >= 0.1 && minScale < 0.5 {
			maxScale = 0.7
		}
		if minScale >= 0.5 {
			maxScale = max(1.0, minScale)
		}

		minimumZoomScale = minScale
		maximumZoomScale = maxScale
	}

	func centerImage() {
		guard let imageView = imageView else { return }
		let boundsSize = bounds.size
		var frameToCenter = imageView.frame

		if frameToCenter.size.width < boundsSize.width {
			frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
		}
		else {
			frameToCenter.origin.x = 0
		}

		if frameToCenter.size.height < boundsSize.height {
			frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
		}
		else {
			frameToCenter.origin.y = 0
		}

		imageView.frame = frameToCenter
	}

	func zoom(point: CGPoint, animated: Bool) {
		let currectScale = self.zoomScale
		let minScale = self.minimumZoomScale
		let maxScale = self.maximumZoomScale

		if minScale == maxScale && minScale > 1 {
			return
		}

		let toScale = maxScale
		let finalScale = (currectScale == minScale) ? toScale : minScale
		let zoomRect = self.zoomRect(scale: finalScale, center: point)
		self.zoom(to: zoomRect, animated: animated)
	}

	func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
		var zoomRect = CGRect.zero
		let bounds = self.bounds

		zoomRect.size.width = bounds.size.width / scale
		zoomRect.size.height = bounds.size.height / scale
		zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
		zoomRect.origin.y = center.y - (zoomRect.size.height / 2)

		return zoomRect
	}

	@objc private  func handleDoubleTap() {
		let location = doubleTap.location(in: doubleTap.view)
		zoom(point: location, animated: true)
	}
}

// MARK: UIScrollViewDelegate
extension ImageZoomView: UIScrollViewDelegate
{
	func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
	func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImage() }
}
