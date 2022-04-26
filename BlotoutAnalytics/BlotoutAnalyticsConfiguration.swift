//
//  BlotoutAnalyticsConfiguration.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 15/04/22.
//

import Foundation
import UIKit

protocol BOAApplicationProtocol: UIApplication {
    var delegate: UIApplicationDelegate? { get set }
    func boa_beginBackgroundTask(withName taskName: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    func boa_endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication {
    func boa_beginBackgroundTask(withName taskName: String?, expirationHandler handler: (() -> Void)? = nil) -> UIBackgroundTaskIdentifier {
        do{
            return beginBackgroundTask(withName: taskName, expirationHandler: handler)
        } catch {             BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)

        }
    }
    func boa_endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        do{
            endBackgroundTask(identifier)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
}

class BlotoutAnalyticsConfiguration:NSObject {

    /// Application token that you can get in your dashboard
    private(set) var token = ""
    /// Url where you will be sending data
    private(set) var endPointUrl = ""
    /// The number of queued events that the analytics client should flush at. Setting this to `1` will not queue any events and will use more battery. `10` by default.
    var flushAt = 0
    
    /// The amount of time to wait before each tick of the flush timer.
    /// Smaller values will make events delivered in a more real-time manner and also use more battery.
    /// A value smaller than 10 seconds will seriously degrade overall performance.
    /// 30 seconds by default.
    var flushInterval: TimeInterval = 0.0
    /// Set a your own implementation for encrption/decryption local data.
    var crypto: BOACrypto?
    /// Dictionary indicating the options the app was launched with.
    var launchOptions: [AnyHashable : Any]?
    /// Leave this nil for iOS extensions, otherwise set to UIApplication.sharedApplication.
    var application: BOAApplicationProtocol?
    
    class func configuration(withToken token: String, withUrl endPointUrl: String) -> Self {
        return BlotoutAnalyticsConfiguration(token: token, withUrl: endPointUrl) as! Self
    }

    convenience init(token: String, withUrl endPointUrl: String) {
        self.init()
            self.token = token
            self.endPointUrl = endPointUrl
    }
    
    override init() {
        super.init()
            flushAt = 1
            flushInterval = 20
        let applicationClass: UIApplication? = UIApplication.shared
            if let applicationClass = applicationClass {
                //#pragma clang diagnostic push
                //#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                
                let unmanagedObject: Unmanaged<AnyObject> = (applicationClass ).perform(NSSelectorFromString("sharedApplication"))
                application = unmanagedObject.takeRetainedValue() as? BOAApplicationProtocol
                //TODO: this needs testing
                //applicationClass.perform(NSSelectorFromString("sharedApplication"))
                //#pragma clang diagnostic pop
            }
    }
}
