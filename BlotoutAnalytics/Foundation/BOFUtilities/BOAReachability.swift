//
//  BOAReachability.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 12/05/22.
//

import Foundation
import UIKit
import SystemConfiguration

public class BOAReachability {
    enum ReachabilityStatus {
            case notReachable
            case reachableViaWWAN
            case reachableViaWiFi
        }
  //  private var reachability: Reachability = Reachability()
    var reachabilityRef: BOAReachability?

    
    private init() {
        
    }
    
 /*   deinit {
        NotificationCenter.default.removeObserver(self)
        reachabilityRef?.stopNotifier()
      }

      // MARK: - Private

      private func configure() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(BOAReachability.currentReachabilityStatus(notification:)),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)
        try? reachabilityRef?.startNotifier()

      }

    
    func startNotifier() -> Bool {
        var returnValue = false
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        
        if reachabilityRef == nil {
            return returnValue
        }

        SCNetworkReachabilitySetCallback(reachabilityRef!, { (_, flags, _) in
            print(flags)
            }, &context)

       if  SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef!, CFRunLoopGetCurrent(),
                                                 CFRunLoopMode.defaultMode.rawValue)
        {
           returnValue = true
       }
        
        
      //TODO: find a fix for this
//       if SCNetworkReachabilitySetCallback(reachabilityRef!, BOReachability.BOReachabilityCallback, &context) {
//            if SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
//                returnValue = true
//            }
//        }
        
        return returnValue
    }
    
    func stopNotifier() {
        if let reachabilityRef = reachabilityRef {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode!.rawValue)
        }
    }
  */
  static var currentReachabilityStatus: ReachabilityStatus {
           
           var zeroAddress = sockaddr_in()
           zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
           zeroAddress.sin_family = sa_family_t(AF_INET)
           guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
               $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                   SCNetworkReachabilityCreateWithAddress(nil, $0)
               }
           }) else {
               return .notReachable
           }
           
           var flags: SCNetworkReachabilityFlags = []
           if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
               return .notReachable
           }
           
           if flags.contains(.reachable) == false {
               // The target host is not reachable.
               return .notReachable
           }
           else if flags.contains(.isWWAN) == true {
               // WWAN connections are OK if the calling application is using the CFNetwork APIs.
               return .reachableViaWWAN
           }
           else if flags.contains(.connectionRequired) == false {
               // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
               return .reachableViaWiFi
           }
           else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
               // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
               return .reachableViaWiFi
           }
           else {
               return .notReachable
           }
       }
    
    
}
