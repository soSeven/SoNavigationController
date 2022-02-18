//
//  BarConfiguration.swift
//  NormalNavigationBar
//
//  Created by liqi on 2022/1/6.
//

import UIKit

public class BarConfiguration {
    
    public static let shared = BarConfiguration()
    
    /// 设置模糊效果样式
    /// 默认为没有模糊效果
    public var blurStyle: UIBlurEffect.Style?
    
    /// 设置背景图片
    /// 默认没有背景图片
    public var backgroundImage: ImageIdentifier?
    
    /// 设置背景颜色
    public var backgroundColor: UIColor = .white
    
    /// 设置子类渲染颜色
    public var tintColor: UIColor = .systemBlue
    
    /// 设置阴影颜色
    public var shadowColor: UIColor = .systemGray
    
    /// 设置透明度
    public var alpha: CGFloat = 1
    
    /// 是否隐藏
    public var isHidden: Bool = false
    
    /// 是否隐藏阴影
    public var isShadowHidden: Bool = false
    
    /// 标题文字样式
    public var titleTextAttributes: [NSAttributedString.Key: Any]?
    public var titleColor: UIColor?
    public var titleFont: UIFont?
    
    /// 是否允许滑动返回
    public var isInteractivePopEnabled = true
    public var isInteractiveShouldPop: ((UIPanGestureRecognizer) -> Bool)?
    
    /// 允许滑动返回时，离左边的距离限制，默认为`0`，没有限制
    public var interactivePopMaxDistanceToLeftEdge: CGFloat = 0

}

extension BarConfiguration: NSCopying {
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BarConfiguration()
        copy.blurStyle = blurStyle
        copy.backgroundImage = backgroundImage
        copy.backgroundColor = backgroundColor
        copy.shadowColor = shadowColor
        copy.tintColor = tintColor
        copy.alpha = alpha
        copy.isHidden = isHidden
        copy.isShadowHidden = isShadowHidden
        copy.titleTextAttributes = titleTextAttributes
        copy.titleFont = titleFont
        copy.titleColor = titleColor
        copy.isInteractiveShouldPop = isInteractiveShouldPop
        copy.isInteractivePopEnabled = isInteractivePopEnabled
        copy.interactivePopMaxDistanceToLeftEdge = interactivePopMaxDistanceToLeftEdge
        return copy
    }
    
}

public struct ImageIdentifier {
    /// 图片
    public let image: UIImage
    /// 用于区分图片是否相同的标识
    public let identifier: String
    
    public init(image: UIImage, identifier: String) {
        self.image = image
        self.identifier = identifier
    }
}

