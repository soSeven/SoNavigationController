//
//  UIViewController+Extension.swift
//  NormalNavigationBar
//
//  Created by liqi on 2021/12/23.
//

import UIKit
import ObjectiveC

public struct SoWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol SoCompatibleValue: AnyObject {}

public extension SoCompatibleValue {
    var so: SoWrapper<Self> {
        get { return SoWrapper(self) }
        set { }
    }
}

extension UIViewController: SoCompatibleValue {}

public extension SoWrapper where Base: UIViewController {
    
    var barConfiguration: BarConfiguration {
        get {
            base.barConfiguration
        }
        set {
            base.barConfiguration = newValue
        }
    }
    
}

private var barConfigurationKey: Void?
extension UIViewController {
    
    var barConfiguration: BarConfiguration {
        get {
            if let configuration = objc_getAssociatedObject(self, &barConfigurationKey) as? BarConfiguration {
                return configuration
            }
            let configuration = BarConfiguration()
            objc_setAssociatedObject(self, &barConfigurationKey, configuration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return configuration
        }
        set {
            objc_setAssociatedObject(self, &barConfigurationKey, newValue.copy(), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}



