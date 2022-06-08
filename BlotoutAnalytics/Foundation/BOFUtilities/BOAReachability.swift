//
//  BOAReachability.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 12/05/22.
//

import Foundation
import UIKit
import SystemConfiguration
import Network

public class BOAReachability:ObservableObject {
    enum ReachabilityStatus {
            case notReachable
            case reachableViaWWAN
            case reachableViaWiFi
        }

    var monitor: NWPathMonitor?
    var isMonitoring = false
    static let sharedInstance = BOAReachability()
    
    var didStartMonitoringHandler: (() -> Void)?
     
    var didStopMonitoringHandler: (() -> Void)?
     
    var netStatusChangeHandler: (() -> Void)?

    private init() {
        startMonitoring()
    }
    
    
    func startMonitoring() {
        guard !isMonitoring else { return }
         
            monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetStatus_Monitor")
            monitor?.start(queue: queue)
         
            monitor?.pathUpdateHandler = { _ in
               // self.getNetStatusUpdate()
               // print("poo is net connected: \(self.isConnected)")
                self.netStatusChangeHandler?()
            }
         
            isMonitoring = true
            didStartMonitoringHandler?()
    }
    
    func getNetStatusUpdate()
    {
        print("poo is net connected: \(self.isConnected)")
    }
    
    func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else { return }
        monitor.cancel()
        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
    
    deinit {
        stopMonitoring()
    }

    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    
    var interfaceType: NWInterface.InterfaceType? {
        guard let monitor = monitor else { return nil }
     
        return monitor.currentPath.availableInterfaces.filter {
            monitor.currentPath.usesInterfaceType($0.type) }.first?.type
    }
    
    var availableInterfacesTypes: [NWInterface.InterfaceType]? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map { $0.type }
    }
    
    var isExpensive: Bool {
        return monitor?.currentPath.isExpensive ?? false
    }
    
    
    /*
    func updateReachabilityStatus()->ReachabilityStatus
    {
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
    
    */
}
