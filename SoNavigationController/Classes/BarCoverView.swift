//
//  BarCoverView.swift
//  NormalNavigationBar
//
//  Created by liqi on 2022/1/6.
//

import UIKit

class BarCoverView: UIView {
    
    lazy var backgroundImageView: UIImageView = {
        let v = UIImageView()
        v.contentScaleFactor = UIScreen.main.scale
        v.contentMode = .scaleToFill
        return v
    }()
    
    lazy var backgroundBlurView: UIVisualEffectView = {
        let v = UIVisualEffectView()
        return v
    }()
    
    lazy var shadowView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        [backgroundImageView, backgroundBlurView, shadowView].forEach{ self.addSubview($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.frame = bounds
        backgroundBlurView.frame = bounds
        let h = 1 / UIScreen.main.scale
        let w = bounds.width
        let x: CGFloat = 0
        let y = bounds.height - h
        shadowView.frame = .init(x: x, y: y, width: w, height: h)
    }
    
}

extension BarCoverView {
    
    func reloadData(_ configuration: BarConfiguration) {
        if let style = configuration.blurStyle {
            backgroundBlurView.effect = UIBlurEffect(style: style)
        } else {
            backgroundBlurView.effect = nil
        }
        backgroundImageView.image = configuration.backgroundImage?.image
        shadowView.backgroundColor = configuration.shadowColor
        shadowView.isHidden = configuration.isShadowHidden
        backgroundColor = configuration.backgroundColor
        tintColor = configuration.tintColor
        alpha = configuration.alpha
        isHidden = configuration.isHidden
    }
    
}

