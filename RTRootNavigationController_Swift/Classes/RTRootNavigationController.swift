//
//  RTRootNavigationController.swift
//  Pods-RTRootNavigationController_Swift_Example
//
//  Created by xujie on 2018/3/14.
//

import UIKit

public extension Array {
    
    public func rt_any(operate: (Any) -> Bool) -> Bool {
        var result: Bool = false
        for item in self {
            if operate(item){
                result = true
                break
            }
        }
        return result
    }
    
}

// MARK:  - -------------------*****RTContainerController*****----------------------- -

private func RTSafeWrapViewController(controller: UIViewController, navigationBarClass: AnyClass?, withPlaceholder: Bool = false, backItem: UIBarButtonItem? = nil, backTitle: String? = nil) -> UIViewController {
    return RTContainerController(controller:controller,navigationBarClass:navigationBarClass,withPlaceholder:withPlaceholder,backItem:backItem,backTitle:backTitle)
}

private func RTSafeUnwrapViewController(wrapVC controller: UIViewController?) -> UIViewController?{
    if let contentVC = (controller as? RTContainerController)?.contentViewController{
        return contentVC
    }
    return controller
}

open class RTContainerController: UIViewController {
    
    open private(set) var contentViewController: UIViewController?
    fileprivate var containerNavigationController: UINavigationController?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate init(controller: UIViewController, navigationBarClass: AnyClass?, withPlaceholder: Bool, backItem: UIBarButtonItem?, backTitle: String?) {
        
        super.init(nibName:nil,bundle:nil)
        
        self.contentViewController = controller
        self.containerNavigationController = RTContainerNavigationController(navigationBarClass:navigationBarClass,toolbarClass:nil)
        
        if withPlaceholder {
            let vc = UIViewController()
            vc.title = backTitle
            vc.navigationItem.backBarButtonItem = backItem
            self.containerNavigationController?.viewControllers = [vc,controller]
        }else{
            self.containerNavigationController?.viewControllers = [controller]
        }
        
        self.addChildViewController(self.containerNavigationController!)
        self.containerNavigationController?.didMove(toParentViewController: self)
    }
    
    fileprivate init(contentController: UIViewController) {
        super.init(nibName:nil,bundle:nil)
        self.contentViewController = contentController
        self.addChildViewController(self.contentViewController!)
        self.contentViewController?.didMove(toParentViewController: self)
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let containerNav = self.containerNavigationController{
            containerNav.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            self.view.addSubview(containerNav.view)
            containerNav.view.frame = self.view.bounds
        }else{
            self.contentViewController?.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            self.contentViewController?.view.frame = self.view.bounds
            self.view.addSubview((self.contentViewController?.view)!)
        }
    }
    
    open override var shouldAutorotate: Bool {
        return (self.contentViewController?.shouldAutorotate)!
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (self.contentViewController?.supportedInterfaceOrientations)!
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return (self.contentViewController?.preferredInterfaceOrientationForPresentation)!
    }
    
    
    
    open override func becomeFirstResponder() -> Bool {
        return (self.contentViewController?.becomeFirstResponder())!
    }
    
    open override var canBecomeFirstResponder: Bool {
        return (self.contentViewController?.canBecomeFirstResponder)!
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return (self.contentViewController?.preferredStatusBarStyle)!
    }
    
    open override var prefersStatusBarHidden: Bool {
        return (self.contentViewController?.prefersStatusBarHidden)!
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation
    {
        return (self.contentViewController?.preferredStatusBarUpdateAnimation)!
    }
    
    @available(iOS 11.0, *)
    open override func prefersHomeIndicatorAutoHidden() -> Bool {
        return (self.contentViewController?.prefersHomeIndicatorAutoHidden())!
    }
    
    @available(iOS 11.0, *)
    open override func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return self.contentViewController
    }
    
    open override func rotatingFooterView() -> UIView? {
        guard #available(iOS 8.0, *) else{
            let footerView = self.contentViewController?.rotatingFooterView()
            return footerView
        }
        return nil
    }
    
    open override func rotatingHeaderView() -> UIView? {
        guard #available(iOS 8.0, *) else{
            let headerView = self.contentViewController?.rotatingHeaderView()
            return headerView
        }
        return nil
    }
    
    
    open override func forUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any?) -> UIViewController? {
        guard #available(iOS 9.0, *) else{
            let viewController = self.contentViewController?.forUnwindSegueAction(_:action,from:fromViewController,withSender:sender)
            return viewController
        }
        return nil
    }
    
    @available(iOS 9.0, *)
    open override func allowedChildViewControllersForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        return self.contentViewController?.allowedChildViewControllersForUnwinding(from:source) ?? []
    }
    
    open override var hidesBottomBarWhenPushed: Bool {
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
        get {
            return (contentViewController?.hidesBottomBarWhenPushed)!
        }
    }
    
    open override var title: String? {
        set{
            super.title = newValue
        }
        get{
            return contentViewController?.title
        }
    }
    
    
    open override var tabBarItem: UITabBarItem! {
        set{
            super.tabBarItem = newValue
        }
        get{
            return contentViewController?.tabBarItem
        }
    }
}


// MARK:  - -------------------*****RTContainerNavigationController*****----------------------- -


open class RTContainerNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: rootViewController.rt_navigationBarClass(), toolbarClass: nil)
        self.pushViewController(rootViewController, animated: false)
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.isEnabled = false
        
        if let _  = self.rt_navigationController?.transferNavigationBarAttributes {
            self.navigationBar.isTranslucent   = (self.navigationController?.navigationBar.isTranslucent)!;
            self.navigationBar.tintColor       = self.navigationController?.navigationBar.tintColor;
            self.navigationBar.barTintColor    = self.navigationController?.navigationBar.barTintColor;
            self.navigationBar.barStyle        = (self.navigationController?.navigationBar.barStyle)!;
            self.navigationBar.backgroundColor = self.navigationController?.navigationBar.backgroundColor;
            
            self.navigationBar.setBackgroundImage(self.navigationController?.navigationBar.backgroundImage(for: .`default`), for: .`default`)
            self.navigationBar.setTitleVerticalPositionAdjustment((self.navigationController?.navigationBar.titleVerticalPositionAdjustment(for: .`default`))!, for: .`default`)
            
            self.navigationBar.titleTextAttributes              = self.navigationController?.navigationBar.titleTextAttributes;
            self.navigationBar.shadowImage                      = self.navigationController?.navigationBar.shadowImage;
            self.navigationBar.backIndicatorImage               = self.navigationController?.navigationBar.backIndicatorImage;
            self.navigationBar.backIndicatorTransitionMaskImage = self.navigationController?.navigationBar.backIndicatorTransitionMaskImage;
        }
        self.view.layoutIfNeeded()
    }
    
    
    open override var tabBarController: UITabBarController? {
        let tabbarController: UITabBarController? = super.tabBarController
        let navigationController: UINavigationController? = self.rt_navigationController
        
        if tabbarController != nil {
            if navigationController?.tabBarController != nil {
                return tabbarController!
            }else{
               let isHidden = navigationController?.viewControllers.rt_any{ (item) -> Bool in
                    return (item as! UIViewController).hidesBottomBarWhenPushed
                }
                return (!(tabbarController?.tabBar.isTranslucent)! || isHidden ?? false) ? nil : tabbarController!
            }
        }
        return nil
    }
    
    open override var viewControllers: [UIViewController] {
        
        set {
            if self.navigationController != nil{
                self.navigationController?.viewControllers = newValue
            }else{
                super.viewControllers = newValue
            }
        }
        
        get {
            if self.navigationController != nil {
                if self.navigationController is RTRootNavigationController {
                    return (self.rt_navigationController?.rt_viewControllers)!
                }
            }
            return super.viewControllers
        }
    }
    
    
    open override func forUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any?) -> UIViewController? {
        guard #available(iOS 9.0, *) else{
            if(self.navigationController != nil) {
                return self.navigationController?.forUnwindSegueAction(_:action,from:fromViewController,withSender:sender)
            }
            return super.forUnwindSegueAction(_:action,from:fromViewController,withSender:sender)
        }
        return nil
    }
    
    @available(iOS 9.0, *)
    open override func allowedChildViewControllersForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        if(self.navigationController != nil) {
            return self.navigationController?.allowedChildViewControllersForUnwinding(from:source) ?? []
        }
        return super.allowedChildViewControllersForUnwinding(from:source)
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if(self.navigationController != nil) {
            self.navigationController?.pushViewController(viewController, animated: animated)
        }else{
            super.pushViewController(viewController, animated: animated)
        }
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        if(self.navigationController != nil) {
            return self.navigationController?.popViewController(animated: animated)
        }
        return super.popViewController(animated: animated)
    }
    
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if(self.navigationController != nil) {
            return self.navigationController?.popToRootViewController(animated: animated)
        }
        return super.popToRootViewController(animated: animated)
    }
    
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if(self.navigationController != nil) {
            return self.navigationController?.popToViewController(viewController,animated: animated)
        }
        return super.popToViewController(viewController,animated: animated)
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let _ = self.navigationController?.responds(to: aSelector) {
            return self.navigationController
        }
        return nil
    }
    
    open override var delegate: UINavigationControllerDelegate? {
        set {
            if(self.navigationController != nil){
                self.navigationController?.delegate = newValue
            }else{
                super.delegate = newValue
            }
        }
        
        get {
            return  (self.navigationController != nil) ? self.navigationController?.delegate : super.delegate
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return (self.topViewController?.preferredStatusBarStyle)!
    }
    
    open override var prefersStatusBarHidden: Bool {
        return (self.topViewController?.prefersStatusBarHidden)!
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation
    {
        return (self.topViewController?.preferredStatusBarUpdateAnimation)!
    }
    
}

// MARK:  - -------------------*****RTRootNavigationController*****----------------------- -

open class RTRootNavigationController: UINavigationController {

    fileprivate var rt_delegate: UINavigationControllerDelegate?
    fileprivate var animationComplete: ((Bool)->Swift.Void)?
    // MARK: override
    
    open override var delegate: UINavigationControllerDelegate? {
        set {
            self.rt_delegate = delegate
        }
        get {
            return self.delegate
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.viewControllers = super.viewControllers
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.commonInit()
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.commonInit()
    }
    
    init(rootViewControllerNoWrapping: UIViewController) {
        super.init(rootViewController: RTContainerController(contentController: rootViewControllerNoWrapping))
        self.commonInit()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        super.delegate = self
        super.setNavigationBarHidden(true, animated: false)
    }
    
    
    open override func forUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any?) -> UIViewController? {
        guard #available(iOS 9.0, *) else{
            var controller: UIViewController? = super.forUnwindSegueAction(action, from: fromViewController, withSender: sender)
            
            if controller == nil {
                let index = self.viewControllers.index(of: fromViewController)
                if index != NSNotFound {
                    for i in (index! - 1)...0  {
                        controller = self.viewControllers[i].forUnwindSegueAction(action, from: fromViewController, withSender: sender)
                        
                        if controller != nil {break}
                    }
                }
                
            }
            return controller
        }
        return nil
    }
    
   @available(iOS 9.0, *)
    open override func allowedChildViewControllersForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        var controller: [UIViewController]? = super.allowedChildViewControllersForUnwinding(from: source)
        
        if controller?.count == 0 {
            let index = self.viewControllers.index(of: source.source)
            if index != NSNotFound {
                for i in (index! - 1)...0  {
                    controller = self.viewControllers[i].allowedChildViewControllersForUnwinding(from: source)
                    
                    if controller?.count != 0 {break}
                }
            }
            
        }
        return controller ?? []
    }
    
    open override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        // Override to protect
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            let currentLast = RTSafeUnwrapViewController(wrapVC: self.viewControllers.last!)!

            super.pushViewController(RTSafeWrapViewController(controller: viewController, navigationBarClass: viewController.rt_navigationBarClass(), withPlaceholder: self.useSystemBackBarButtonItem,backItem: currentLast.navigationItem.backBarButtonItem, backTitle: currentLast.navigationItem.title), animated: animated)
        }else {
            super.pushViewController(RTSafeWrapViewController(controller: viewController, navigationBarClass: viewController.rt_navigationBarClass()), animated: animated)
        }
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        return RTSafeUnwrapViewController(wrapVC: super.popViewController(animated: animated)!)
    }
    
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated)?.map{
            return RTSafeUnwrapViewController(wrapVC: $0)!
        }
    }
    
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        var controllerToPop :UIViewController?
        
        for vc in super.viewControllers {
            if(RTSafeUnwrapViewController(wrapVC: vc) == viewController) {
                controllerToPop = vc
                break
            }
        }
        
        if let ctp = controllerToPop {
            return super.popToViewController(ctp, animated: animated)?.map{
                return RTSafeUnwrapViewController(wrapVC: $0)!
            }
        }
        return nil
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        
        super.setViewControllers(viewControllers.enumerated().map{(index,item)
            in
            if self.useSystemBackBarButtonItem && index > 0 {
                return RTSafeWrapViewController(controller: item, navigationBarClass: item.rt_navigationBarClass(), withPlaceholder: self.useSystemBackBarButtonItem, backItem: viewControllers[index - 1].navigationItem.backBarButtonItem, backTitle: viewControllers[index - 1].navigationItem.title)
            }else{
                return RTSafeWrapViewController(controller: item, navigationBarClass: item.rt_navigationBarClass())
            }
            
        }, animated: animated)
    }
    
    open override var shouldAutorotate: Bool {
        return (self.topViewController?.shouldAutorotate)!
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (self.topViewController?.supportedInterfaceOrientations)!
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return (self.topViewController?.preferredInterfaceOrientationForPresentation)!
    }
    
    open override func rotatingFooterView() -> UIView? {
        guard #available(iOS 8.0, *) else{
            let footerView = self.topViewController?.rotatingFooterView()
            return footerView
        }
        return nil
    }
    
    open override func rotatingHeaderView() -> UIView? {
        guard #available(iOS 8.0, *) else{
            let headerView = self.topViewController?.rotatingHeaderView()
            return headerView
        }
        return nil
    }
    
    open override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector){
            return true
        }
        return self.rt_delegate?.responds(to:aSelector) ?? false
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return self.rt_delegate
    }

    
    // MARK: Public
    var transferNavigationBarAttributes: Bool = false
    var useSystemBackBarButtonItem: Bool = false
    
    var rt_topViewController: UIViewController? {
        return RTSafeUnwrapViewController(wrapVC: super.topViewController)
        
    }
    
    var rt_visibleViewController: UIViewController? {
        return RTSafeUnwrapViewController(wrapVC: super.visibleViewController)
    }
    
    var rt_viewControllers: [UIViewController]? {
        return super.viewControllers.map{
            return RTSafeUnwrapViewController(wrapVC: $0)!
        }
    }
    
    func removeViewController(controller: UIViewController, animated flag: Bool = false) {
        
        var viewControllers: [UIViewController] = super.viewControllers
        var controllerToRemove :UIViewController?
        
        for vc in viewControllers {
            if(RTSafeUnwrapViewController(wrapVC: vc) == controller) {
                controllerToRemove = vc
                break
            }
        }
        
        if let ctp = controllerToRemove, let index = viewControllers.index(of: ctp){
            viewControllers.remove(at: index)
            super.setViewControllers(viewControllers, animated: flag)
        }
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool,complete: @escaping (Bool)->Swift.Void){
        if self.animationComplete != nil{
            self.animationComplete!(false)
        }
        self.animationComplete = complete
        self.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool, complete: @escaping (Bool)->Swift.Void) ->UIViewController? {
        
        if self.animationComplete != nil{
            self.animationComplete!(false)
        }
        self.animationComplete = complete
        
        let vc = self.popViewController(animated: animated)
        
        if vc != nil {
            if self.animationComplete != nil{
                self.animationComplete!(true)
                self.animationComplete = nil
            }
        }
        return vc
    }
    
    func popToViewController(viewController: UIViewController,animated: Bool,complete: @escaping (Bool)->Swift.Void) ->[UIViewController]?{
        
        if self.animationComplete != nil{
            self.animationComplete!(false)
        }
        self.animationComplete = complete
        
        let vcs = self.popToViewController(viewController, animated: animated)
        
        if let count = vcs?.count,count > 0 {
            if self.animationComplete != nil{
                self.animationComplete!(true)
                self.animationComplete = nil
            }
        }
        return vcs
    }
    
    
    func popToRootViewController(animated: Bool,complete: @escaping (Bool)->Swift.Void) ->[UIViewController]? {
        
        if self.animationComplete != nil{
            self.animationComplete!(false)
        }
        self.animationComplete = complete
        
        let vcs = self.popToRootViewController(animated: animated)
        
        if let count = vcs?.count,count > 0 {
            if self.animationComplete != nil{
                self.animationComplete!(true)
                self.animationComplete = nil
            }
        }
        return vcs
    }
}

extension RTRootNavigationController: UINavigationControllerDelegate,UIGestureRecognizerDelegate{
    
    fileprivate func onBack(sender: Any) {
        _ = self.popViewController(animated: true)
    }
    
    fileprivate func commonInit() {
        
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let isRootVC = viewController == navigationController.viewControllers.first
        let unwrapVC = RTSafeUnwrapViewController(wrapVC: viewController)!
        
        if !isRootVC {
            let hasSetLeftItem = unwrapVC.navigationItem.leftBarButtonItem != nil
            
            if hasSetLeftItem && !unwrapVC.rt_hasSetInteractivePop {
                unwrapVC.rt_disableInteractivePop = true
            }else if !unwrapVC.rt_hasSetInteractivePop {
                unwrapVC.rt_disableInteractivePop = false
            }
            
            if !self.useSystemBackBarButtonItem && !hasSetLeftItem {
                
                if unwrapVC.responds(to: Selector(("rt_customBackItemWithTarge:action:"))) {
                    unwrapVC.navigationItem.leftBarButtonItem = unwrapVC.rt_customBackItemWithTarget(target: self, action: Selector(("onBack:")))
                }else {
                    unwrapVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title:NSLocalizedString("Back", comment: ""),style:.plain,target:self,
                        action:Selector(("onBack:")))
                }
            }
        }
        self.rt_delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        let isRootVC = viewController == navigationController.viewControllers.first
        let unwrapVC = RTSafeUnwrapViewController(wrapVC: viewController)!
        
        if unwrapVC.rt_disableInteractivePop {
            self.interactivePopGestureRecognizer?.delegate = nil
            self.interactivePopGestureRecognizer?.isEnabled = false
        }else {
            self.interactivePopGestureRecognizer?.delaysTouchesBegan = true
            self.interactivePopGestureRecognizer?.delegate = self
            self.interactivePopGestureRecognizer?.isEnabled = !isRootVC
        }
        
        RTRootNavigationController.attemptRotationToDeviceOrientation()
        
        if self.animationComplete != nil {
            self.animationComplete!(true)
            self.animationComplete = nil
        }
        
        self.rt_delegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }
    
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.rt_delegate?.navigationControllerSupportedInterfaceOrientations?(_:navigationController) ?? .all
    }
    
    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return self.rt_delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(_:navigationController) ?? .portrait
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.rt_delegate?.navigationController?(navigationController,interactionControllerFor:animationController)
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.rt_delegate?.navigationController?(navigationController,animationControllerFor:operation,from:fromVC,to:toVC)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == self.interactivePopGestureRecognizer
    }
    
}

extension UIViewController {
    fileprivate var rt_hasSetInteractivePop: Bool {
        return self.rt_disableInteractivePop
    }
}




