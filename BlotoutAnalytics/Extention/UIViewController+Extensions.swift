//
//  UIViewController+Extensions.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 18/04/22.
//

import Foundation
import UIKit

func loadAsUIViewControllerBOFoundationCat() {
}
extension UIViewController {
    //TODO:check what open does
    //TODO: all classes check how to correctly try catch
    open override class func load() {
        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
        do {
            let viewDidAppearSelector = #selector(viewDidAppear(_:))
            let viewDidAppearLoggerSelector = Selector("logged_viewDidAppear:")

            let originalMethod = class_getInstanceMethod(self, viewDidAppearSelector)
            let extendedMethod = class_getInstanceMethod(self, viewDidAppearLoggerSelector)
            if let originalMethod = originalMethod, let extendedMethod = extendedMethod {
                method_exchangeImplementations(originalMethod, extendedMethod)
            }

            let viewWillDisappearSelector = #selector(UIViewController.viewWillDisappear(_:))
            
            let viewWillDisappearLoggerSelector = Selector("logged_viewWillDisappear:")
            let originalDisappearMethod = class_getInstanceMethod(self, viewWillDisappearSelector)
            let extendedDisappearMethod = class_getInstanceMethod(self, viewWillDisappearLoggerSelector)
            if let originalDisappearMethod = originalDisappearMethod, let extendedDisappearMethod = extendedDisappearMethod {
                method_exchangeImplementations(originalDisappearMethod, extendedDisappearMethod)
            }
        }
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
        var name = type(of: viewController).description().replacingOccurrences(of: "ViewController", with: "")
        if name == nil || name.count == 0 {
            name = viewController?.title ?? ""
            if name.count == 0 {
                name = "Unknown"
            }
        }
        return name
    }
    
    func logged_viewWillDisappear(_ animated: Bool) {
        do{

            let top = UIViewController.getRootViewController(from: view)

            if top == nil {
                return
            }
            logged_viewWillDisappear(animated)
            BOSharedManager.sharedInstance.isViewDidAppeared = false

            if BlotoutAnalytics.sharedInstance.eventManager == nil {
                return
            }

            let screen = getScreenName(top)
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {
                let model = BOACaptureModel(event: BO_VISIBILITY_HIDDEN, properties: nil, screenName: screen, withType: BO_SYSTEM)
                BlotoutAnalytics.sharedInstance.eventManager.capture(model)
            })

        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func logged_viewDidAppear(_ animated: Bool) {
        do{
            
            let top = UIViewController.getRootViewController(from: view)

            if top == nil {
                return
            }

            logged_viewDidAppear(animated)

            if BOSharedManager.sharedInstance.isViewDidAppeared {
                return
            }
            
            BOSharedManager.sharedInstance.isViewDidAppeared = true

            if BlotoutAnalytics.sharedInstance.eventManager == nil {
                return
            }

            let screenName = getScreenName(top)
            BOSharedManager.sharedInstance.currentScreenName = screenName
            
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {
                let model = BOACaptureModel(event: BO_SDK_START, properties: nil, screenName: screenName, withType: BO_SYSTEM)
                BlotoutAnalytics.sharedInstance.eventManager.capture(model)
            })
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
}
