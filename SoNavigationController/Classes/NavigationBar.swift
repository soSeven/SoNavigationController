//
//  NavigationBar.swift
//  NavigationBar
//
//  Created by liqi on 2021/12/22.
//

import UIKit

/*
 NavigationBar:
 - _UIBarBackground
   - BarCoverView
 - _UINavigationBarContentView
 - UIView
 */

class NavigationBar: UINavigationBar {
    
    lazy var coverView: BarCoverView = {
        let v = BarCoverView()
        return v
    }()
    
    /// 获取 _UIBarBackground
    var uiBarBackground: UIView? {
        return subviews.first
    }
    
    /// 获取 _UINavigationBarContentView
    private var uiNavigationBarContentView: UIView? {
        if subviews.count >= 2 {
            return subviews[1]
        }
        return nil
    }
    
    override var titleTextAttributes: [NSAttributedString.Key : Any]? {
        get {
            super.titleTextAttributes
        }
        set {
            super.titleTextAttributes = newValue
            if #available(iOS 13.0, *) {
                standardAppearance.titleTextAttributes = newValue ?? [:]
                scrollEdgeAppearance?.titleTextAttributes = newValue ?? [:]
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isTranslucent = true
        shadowImage = UIImage()
        if #available(iOS 13.0, *) {
            standardAppearance.configureWithTransparentBackground()
            scrollEdgeAppearance?.configureWithTransparentBackground()
            compactAppearance?.configureWithTransparentBackground()
            if #available(iOS 15.0, *) {
                compactScrollEdgeAppearance?.configureWithTransparentBackground()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCoverView()
    }
    
    private func layoutCoverView() {
        super.setBackgroundImage(UIImage(), for: .default)
        if coverView.superview == nil {
            uiBarBackground?.addSubview(coverView)
        }
        coverView.frame = uiBarBackground?.bounds ?? .zero
    }
    
}
