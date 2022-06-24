//
//  UIViewController+Extensions.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 08/06/22.
//

import Foundation
import UIKit

extension UIViewController {
    
//    @objc func newViewWillAppear(_ animated: Bool) {
//        self.newViewWillAppear(animated) //Incase we need to override this method
//        let viewControllerName = String(describing: type(of: self)).replacingOccurrences(of: "ViewController", with: "", options: .literal, range: nil)
//        print("Swizzled viewWillAppear", viewControllerName)
//    }
//
//    static func swizzleViewWillAppear() {
//        //Make sure This isn't a subclass of UIViewController, So that It applies to all UIViewController childs
//        if self != UIViewController.self {
//            return
//        }
//        let _: () = {
//            let originalSelector = #selector(UIViewController.viewDidAppear(_:))
//            let swizzledSelector = #selector(UIViewController.logged_viewDidAppear(_:))
//            let originalMethod = class_getInstanceMethod(self, originalSelector)
//            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
//            method_exchangeImplementations(originalMethod!, swizzledMethod!);
//        }()
//    }
    
    
   static func swizzleVCLoggingMethods()
    {
        let _: () = {
            let originalSelector = #selector(UIViewController.viewDidAppear(_:))
            let swizzledSelector = #selector(UIViewController.logged_viewDidAppear(_:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            method_exchangeImplementations(originalMethod!, swizzledMethod!);

            
            let originalSelector2 = #selector(UIViewController.viewWillDisappear(_:))
            let swizzledSelector2 = #selector(UIViewController.logged_viewWillDisappear(_:))
            let originalMethod2 = class_getInstanceMethod(self, originalSelector2)
            let swizzledMethod2 = class_getInstanceMethod(self, swizzledSelector2)
            method_exchangeImplementations(originalMethod2!, swizzledMethod2!);
        }()
    }
    
    class func getRootViewController(from view: UIView?) -> UIViewController? {

        let root = view?.window?.rootViewController
        return self.topViewController(root)

    }
    
    class func topViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        let nextRootViewController = self.nextRootViewController(rootViewController)
        if let nextRootViewController = nextRootViewController {
            return self.topViewController(nextRootViewController)
        }

        return rootViewController
    }
    
    class func nextRootViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        let presentedViewController = rootViewController?.presentedViewController
        if let presentedViewController = presentedViewController {
            return presentedViewController
        }
        if rootViewController is UINavigationController {
            let lastViewController = (rootViewController as? UINavigationController)?.viewControllers.last
            return lastViewController
        }
        if rootViewController is UITabBarController {
            let currentTabViewController = (rootViewController as? UITabBarController)?.selectedViewController
            if let currentTabViewController = currentTabViewController {
                return currentTabViewController
            }
        }
        return nil
    }
    
    func getScreenName(_ viewController: UIViewController) -> String? {
        var name = type(of: viewController).typeName
        if  name.count == 0 {
            name = viewController.title ?? ""
            if name.count == 0 {
                name = "Unknown"
            }
        }
        return name
    }

    
    @objc func logged_viewWillDisappear(_ animated: Bool) {

            let top = UIViewController.getRootViewController(from: view)
            
            if top == nil {
                return
            }
            
        //TODO: understand why same method is recursively called???
        
            logged_viewWillDisappear(animated)
        
        //TODO: viewDidAppeared logic fails in case of present, so commenting, lets change if we see the usecase for this
           // BOSharedManager.sharedInstance.isViewDidAppeared = false
            
            if BlotoutAnalytics.sharedInstance.eventManager == nil {
                return
            }
            
            let screen = getScreenName(top!)
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {
                let model = BOACaptureModel(event: BO_VISIBILITY_HIDDEN, properties: nil, screenName: screen, withType: BO_SYSTEM)
                BlotoutAnalytics.sharedInstance.eventManager.capture(model)
            })
    }
    
    @objc func logged_viewDidAppear(_ animated: Bool) {

            let top = UIViewController.getRootViewController(from: view)

            if top == nil {
                return
            }

        //TODO: understand why same method is recursively called???
            logged_viewDidAppear(animated)

        //TODO: viewDidAppeared logic fails in case of present, so commenting, lets change if we see the usecase for this
//            if BOSharedManager.sharedInstance.isViewDidAppeared {
//                return
//            }
          //  BOSharedManager.sharedInstance.isViewDidAppeared = true

            if BlotoutAnalytics.sharedInstance.eventManager == nil {
                return
            }
            let screenName = getScreenName(top!)
            BOSharedManager.sharedInstance.currentScreenName = screenName

            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {
                let model = BOACaptureModel(event: BO_SDK_START, properties: nil, screenName: screenName, withType: BO_SYSTEM)
                BlotoutAnalytics.sharedInstance.eventManager.capture(model)
            })
        
    }
}

// Bridge to Obj-C
extension NSObject {
    class var typeName: String {
        let type = String(describing: self)
        return type
    }
}
