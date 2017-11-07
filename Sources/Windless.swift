//
//  Windless.swift
//  Windless
//
//  Created by gwangbeom on 2017. 11. 5..
//  Copyright © 2017년 Windless. All rights reserved.
//

import UIKit

public class Windless {
    
    fileprivate weak var contentsView: UIView!
    fileprivate var windlessLayer: WindlessLayer?
    fileprivate var configuration = WindlessConfiguration()

    init(contentsView: UIView) {
        contentsView.layoutIfNeeded()
        self.contentsView = contentsView
        setupWindlessLayer()
    }
}

private extension Windless {
    
    func windlessableSubviews(of view: UIView) -> [UIView] {
        var subviews = [UIView]()
        view.subviews.forEach {
            subviews += windlessableSubviews(of: $0)
            if $0.isWindlessable {
                subviews.append($0)
            }
        }
        return subviews
    }
    
    func updateLayer() {
        windlessLayer?.updateGradient()
        windlessLayer?.updateCoverLayerColor(contentsView.backgroundColor ?? .white)
        windlessLayer?.updateWindlessableLayers(windlessableSubviews(of: contentsView).flatMap{ $0.layer })
    }
    
    func setupWindlessLayer() {
        let layer = WindlessLayer(frame: contentsView.bounds, configuration: configuration)
        contentsView.layer.addSublayer(layer)
        windlessLayer = layer
    }
    
    func setupScrollEnabled(_ enabled: Bool) {
        guard let scrollView = contentsView as? UIScrollView else {
            return
        }
        scrollView.isScrollEnabled = enabled
    }
}

// MARK: setup
public extension Windless {
    
    @discardableResult
    func apply(_ config: (WindlessConfiguration?) -> Void) -> Self {
        config(configuration)
        return self
    }
    
    @discardableResult
    func setupContainer(_ views: [UIView]) -> Self {
        views.forEach { $0.isWindlessable = true }
        return self
    }
}

// MARK: animation
public extension Windless {
    
    func start() {
        setupScrollEnabled(false)
        updateLayer()
        UIView.transition(with: contentsView, duration: 0.4, options: [], animations: {
            self.windlessLayer?.isHidden = false
        }) { _ in
            self.windlessLayer?.windless = true
        }
    }
    
    func end() {
        UIView.transition(with: contentsView, duration: 0.4, options: [], animations: {
            self.windlessLayer?.isHidden = true
        }) { _ in
            self.setupScrollEnabled(true)
            self.windlessLayer?.windless = false
        }
    }
}
