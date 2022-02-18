//
//  NormalNavigationController.swift
//  NormalNavigationBar
//
//  Created by liqi on 2021/12/22.
//

import UIKit

public class NavigationController: UINavigationController {
    
    private var toCoverView: BarCoverView = {
        let v = BarCoverView()
        return v
    }()
    
    private var fromCoverView: BarCoverView =  {
        let v = BarCoverView()
        return v
    }()
    
    private lazy var screenEdgePan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.maximumNumberOfTouches = 1
        return pan
    }()
    
    private lazy var panDelegate: FullScreenRecognizerDelegate = {
        let panDelegate = FullScreenRecognizerDelegate(controller: self)
        return panDelegate
    }()
    
    public weak var navigationControllerDelegate: UINavigationControllerDelegate?
    public override var delegate: UINavigationControllerDelegate? {
        get {
            self
        }
        set {
            super.delegate = self
        }
    }
    
    override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        viewControllers = [rootViewController]
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        assert(navigationBarClass?.isSubclass(of: NavigationBar.self) ?? false,
               "navigationBarClass必须是 NavigationBar 类或子类")
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        addScreenEdge()
    }
    
}

private extension NavigationController {
    
    func addScreenEdge() {
        guard let interactivePopGestureRecognizer = interactivePopGestureRecognizer else { return }
        interactivePopGestureRecognizer.view?.addGestureRecognizer(screenEdgePan)
        screenEdgePan.delegate = panDelegate
        screenEdgePan.addTarget(self, action: #selector(handleNavigationTransition(_:)))
        interactivePopGestureRecognizer.isEnabled = false
    }
    
    @objc
    func handleNavigationTransition(_ pan: UIPanGestureRecognizer) {
        guard let interactivePopGestureRecognizer = interactivePopGestureRecognizer else { return }
        guard let internalTargets = interactivePopGestureRecognizer.value(forKey: "targets") as? [AnyObject] else {
            return
        }
        guard let interTarget = internalTargets.first?.value(forKey: "target") else { return }
        let internalAction = NSSelectorFromString("handleNavigationTransition:")
        let _ = (interTarget as AnyObject).perform(internalAction, with: screenEdgePan)
        
        guard let navigationBar = navigationBar as? NavigationBar else { return }
        guard let coordinator = transitionCoordinator else { return }
        guard let fromViewController = coordinator.viewController(forKey: .from) else { return }
        guard let toViewController = coordinator.viewController(forKey: .to) else { return }
        let fromConfiguration = fromViewController.barConfiguration
        let toConfiguration = toViewController.barConfiguration
        if pan.state == .began || pan.state == .changed {
            if !toConfiguration.isHidden, !fromConfiguration.isHidden {
                navigationBar.tintColor = fromConfiguration.tintColor.blend(to: toConfiguration.tintColor, percent: coordinator.percentComplete)
            }
        }
    }
    
}

extension NavigationController {
    
    func updateNavigationBar(for viewController: UIViewController) {
        guard let navigationBar = navigationBar as? NavigationBar else { return }
        if !viewController.barConfiguration.isHidden {
            if let titleTextAttributes = viewController.barConfiguration.titleTextAttributes {
                navigationBar.titleTextAttributes = titleTextAttributes
            } else {
                var titleTextAttributes = [NSAttributedString.Key: Any]()
                if let titleColor = viewController.barConfiguration.titleColor {
                    titleTextAttributes[.foregroundColor] = titleColor
                }
                if let titleFont = viewController.barConfiguration.titleFont {
                    titleTextAttributes[.font] = titleFont
                }
                if titleTextAttributes.count > 0 {
                    navigationBar.titleTextAttributes = titleTextAttributes
                }
            }
            navigationBar.tintColor = viewController.barConfiguration.tintColor
            navigationBar.coverView.reloadData(viewController.barConfiguration)
        }
    }
    
}

private extension NavigationController {
    
    func removeBar() {
        fromCoverView.removeFromSuperview()
        toCoverView.removeFromSuperview()
    }
    
    func addFromBar(to fromViewController: UIViewController) {
        fromCoverView.frame = convertBarFrame(to: fromViewController)
        fromViewController.view.addSubview(fromCoverView)
        fromCoverView.reloadData(fromViewController.barConfiguration)
    }
    
    func addToBar(to toViewController: UIViewController) {
        toCoverView.frame = convertBarFrame(to: toViewController)
        toViewController.view.addSubview(toCoverView)
        toCoverView.reloadData(toViewController.barConfiguration)
    }
    
    func convertBarFrame(to viewController: UIViewController) -> CGRect {
        guard let navigationBar = navigationBar as? NavigationBar ,
              let uiBackgroundView = navigationBar.uiBarBackground else { return .zero}
        let frame = navigationBar.convert(uiBackgroundView.frame, to: viewController.view)
        return .init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }
    
}

private extension NavigationController {
    
    func isNeedShowCoverView(with fromConfiguration: BarConfiguration, toConfiguration: BarConfiguration) -> Bool {
        if fromConfiguration.isHidden { return false }
        if toConfiguration.isHidden { return false }
        let isSameBackgroundColor = fromConfiguration.backgroundColor.isEqualToColor(toConfiguration.backgroundColor)
        let isSameBlurStyle = fromConfiguration.blurStyle == toConfiguration.blurStyle
        let isSameImage = fromConfiguration.backgroundImage?.identifier == toConfiguration.backgroundImage?.identifier
        let isSameAlpha = fromConfiguration.alpha == toConfiguration.alpha
        let isSameShadowColor = fromConfiguration.shadowColor.isEqualToColor(toConfiguration.shadowColor)
        let isSameShadowHidden = fromConfiguration.isShadowHidden == toConfiguration.isShadowHidden
        if isSameBackgroundColor, isSameImage, isSameBlurStyle, isSameAlpha, isSameShadowColor, isSameShadowHidden {
            return false
        }
        return true
    }
    
    func transition(from fromViewController: UIViewController,
                            to toViewController: UIViewController,
                            willShow viewController: UIViewController,
                            animated: Bool) {
        guard let navigationBar = navigationBar as? NavigationBar else { return }
        let fromConfiguration = fromViewController.barConfiguration
        let toConfiguration = toViewController.barConfiguration
        let configuration = viewController.barConfiguration
        setNavigationBarHidden(configuration.isHidden, animated: animated)
        let isShowCover = isNeedShowCoverView(with: fromConfiguration, toConfiguration: toConfiguration)
        if !fromViewController.barConfiguration.isHidden, isShowCover {
            addFromBar(to: fromViewController)
        }
        if !toViewController.barConfiguration.isHidden, isShowCover {
            addToBar(to: toViewController)
        }
        if isShowCover {
            navigationBar.coverView.alpha = 0
        } else {
            updateNavigationBar(for: viewController)
        }
    }
    
    func completeTransition(for viewController: UIViewController) {
        updateNavigationBar(for: viewController)
        removeBar()
    }
    
}

extension NavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        if let coordinator = navigationController.transitionCoordinator {
            /// `push`时，并有`animated`为`true`时
            guard let fromViewController = coordinator.viewController(forKey: .from) else { return }
            guard let toViewController = coordinator.viewController(forKey: .to) else { return }
            transition(from: fromViewController, to: toViewController, willShow: viewController, animated: animated)
            coordinator.animate { context in
    
            } completion: { context in
                if context.isCancelled {
                    /// 当返回中断时，不会走`didShow`方法
                    self.completeTransition(for: fromViewController)
                }
            }
        } else {
            let children = viewControllers
            if children.count >= 2 {
                let fromViewController = children[children.count - 2]
                transition(from: fromViewController, to: viewController, willShow: viewController, animated: animated)
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        completeTransition(for: viewController)
    }
}

fileprivate extension UIColor {
    
    func convertColorToRGBSpace() -> UIColor? {
        guard let type = cgColor.colorSpace else { return nil }
        if type.model == .rgb { return self }
        if type.model == .monochrome {
            guard let oldComponets = cgColor.components else { return nil }
            let componts: [CGFloat] = [oldComponets[0], oldComponets[0], oldComponets[0], oldComponets[1]]
            guard let colorRef = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: componts) else { return nil }
            return UIColor(cgColor: colorRef)
        }
        return nil
    }
    
    func isEqualToColor(_ otherColor: UIColor) -> Bool {
        if self == otherColor { return true }
        if let rgbColor = convertColorToRGBSpace(), let otherRgbColor = otherColor.convertColorToRGBSpace() {
            return rgbColor.isEqual(otherRgbColor)
        }
        return false
    }
    
    func blend(to toColor: UIColor, percent: CGFloat) -> UIColor {
        let fromColor = self
        guard let fromRgb = fromColor.convertColorToRGBSpace() else { return toColor }
        guard let toRgb = toColor.convertColorToRGBSpace() else { return toColor }
        let (fromR, fromG, fromB, fromA) = fromRgb.rgba
        let (toR, toG, toB, toA) = toRgb.rgba
        let r = fromR + (toR - fromR) * percent
        let g = fromG + (toG - fromG) * percent
        let b = fromB + (toB - fromB) * percent
        let a = fromA + (toA - fromA) * percent
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
    
}
