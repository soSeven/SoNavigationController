//
//  ScreenEdgePanGestureRecognizer.swift
//  NormalNavigationBar
//
//  Created by liqi on 2022/2/15.
//

import UIKit

class FullScreenRecognizerDelegate: NSObject {

    weak var navigationController: NavigationController?
    
    init(controller: NavigationController) {
        navigationController = controller
        super.init()
    }
    
}

extension FullScreenRecognizerDelegate: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        guard let navigationController = navigationController else { return false }
        
        if navigationController.viewControllers.count <= 1 {
            return false
        }
        
        guard let topViewController = navigationController.viewControllers.last else { return false }
        
        if !topViewController.barConfiguration.isInteractivePopEnabled {
            return false
        }
        
        let beginningLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        let maxAllowedInitialDistance = topViewController.barConfiguration.interactivePopMaxDistanceToLeftEdge
        if maxAllowedInitialDistance > 0, beginningLocation.x > maxAllowedInitialDistance {
            return false
        }
        
        if let isTransitioning = navigationController.value(forKey: "_isTransitioning") as? Bool, isTransitioning {
            return false
        }
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if translation.x * multiplier <= 0 {
            return false
        }
        
        if let shouldPop = topViewController.barConfiguration.isInteractiveShouldPop {
            return shouldPop(gestureRecognizer)
        }
    
        return true
    }
    
}
