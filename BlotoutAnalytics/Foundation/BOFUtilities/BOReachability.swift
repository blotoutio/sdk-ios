/*
     File: Reachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
  Version: 3.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

import Foundation
import SystemConfiguration

var kBOReachabilityChangedNotification = "kNetworkBOReachabilityChangedNotification"
var BOWebServiceInternetConnectionAvailableNotification = "BOWebServiceInternetConnectionAvailableNotification"


class BOReachability:NSObject {
    
    
    var localWiFiRef = false
    var reachabilityRef: SCNetworkReachability?
    
    enum BONetworkStatus : Int {
        case boNotReachable = 0
        case boReachableViaWiFi
        case boReachableViaWWAN
    }
    
    let kShouldPrintReachabilityFlags = 0
    
    private func PrintReachabilityFlags(_ flags: SCNetworkReachabilityFlags, _ comment: UnsafePointer<Int8>?) {
#if kShouldPrintReachabilityFlags
        
        BOFLogDebug(
            "Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
            (flags.rawValue & SCNetworkReachabilityFlags.isWWAN.rawValue) != 0 ? "W" : "-",
            (flags.rawValue & SCNetworkReachabilityFlags.reachable.rawValue) != 0 ? "R" : "-",
            (flags & SCNetworkReachabilityFlags.transientConnection.rawValue) != 0 ? "t" : "-",
            (flags & SCNetworkReachabilityFlags.connectionRequired.rawValue) != 0 ? "c" : "-",
            (flags & SCNetworkReachabilityFlags.connectionOnTraffic.rawValue) != 0 ? "C" : "-",
            (flags & SCNetworkReachabilityFlags.interventionRequired.rawValue) != 0 ? "i" : "-",
            (flags & SCNetworkReachabilityFlags.connectionOnDemand.rawValue) != 0 ? "D" : "-",
            (flags & SCNetworkReachabilityFlags.isLocalAddress.rawValue) != 0 ? "l" : "-",
            (flags & SCNetworkReachabilityFlags.isDirect.rawValue) != 0 ? "d" : "-",
            comment)
#endif
    }
    
    static func BOReachabilityCallback(target: SCNetworkReachability, flags: SCNetworkReachabilityFlags,info: Void) {
        //#pragma unused (target, flags)
        assert(info != nil, "info was NULL in BOReachabilityCallback")
        assert(((info as? NSObject) is BOReachability), "info was wrong class in BOReachabilityCallback")
        let noteObject = info as! BOReachability
        // Post a notification to notify the client that the network reachability changed.
        NotificationCenter.default.post(name: Notification.Name(kBOReachabilityChangedNotification), object: noteObject)
        noteObject.notifyInternetAvailability()
    }
    
    
    
    
    class func reachability(withAddress hostAddress: sockaddr_in) -> Self {
        var reachability: SCNetworkReachability? = nil
        
        var zeroAddress = hostAddress
       // var defaultRouteReachability: SCNetworkReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &zeroAddress)

    //TODO: find a fix for this
   /*     var addr: sockaddr = zeroAddress
        let addr_in = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                $0.pointee
            }
        }
        
       // if let address = hostAddress as? sockaddr {
            reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer <zeroAddress>)
            //SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer<address>)
       // }
       */
        
        var returnValue: BOReachability? = nil
        if let reachability = reachability {
        //todo check this    returnValue = self.init()
            if let returnValue = returnValue {
                returnValue.reachabilityRef = reachability
                returnValue.localWiFiRef = false
            }
        }
        return returnValue as! Self
    }
    
    
    //TODO: need to add code here
    //TODO: maybe doesnt need to be private
    static private var sharedInstance: BOReachability = BOReachability()
    //    +reachabilityForInternetConnection as? Self!
    //    do {
    //
    //        // `dispatch_once()` call was converted to a static variable initializer
    //
    //
    //        return sharedInstance
    //    }
    
    /* not being used
    class func reachabilityForLocalWiFi() -> Self {
        var localWifiAddress: sockaddr_in
        bzero(&localWifiAddress, MemoryLayout.size(ofValue: localWifiAddress))
        localWifiAddress.sin_len = __uint8_t(MemoryLayout.size(ofValue: localWifiAddress))
        localWifiAddress.sin_family = sa_family_t(AF_INET)
        localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM)
        
        let returnValue:BOReachability = self.reachability(withAddress: localWifiAddress)
        if returnValue != nil {
            returnValue.localWiFiRef = true
        }
        
        return returnValue as! Self
    }
    */
    override init() {
        super.init()
    }
    
    
    func startNotifier() -> Bool {
        var returnValue = false
      //  var context = SCNetworkReachabilityContext(version: CFIndex(0), info: (__bridge void *)(self), retain: nil, release: nil, copyDescription: nil)
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)

      //  SCNetworkReachabilityContext() context = {0, (__bridge void *)(self), NULL, NULL, NULL};

        
        if reachabilityRef == nil {
            return returnValue
        }
        
      //TODO: find a fix for this
     /*   if SCNetworkReachabilitySetCallback(reachabilityRef!, BOReachability.BOReachabilityCallback, &context) {
            if SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
                returnValue = true
            }
        }
        
        */
        
        return returnValue
    }
    
    func stopNotifier() {
        if let reachabilityRef = reachabilityRef {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode!.rawValue)
        }
    }
    
    deinit {
        stopNotifier()
//        if let reachabilityRef = reachabilityRef {
//        }
    }
    
    func notifyInternetAvailability() {
        let status = currentReachabilityStatus()
        if status != BONetworkStatus.boNotReachable {
            NotificationCenter.default.post(name: Notification.Name(BOWebServiceInternetConnectionAvailableNotification), object: self)
        }
    }
    
    func localWiFiStatusForFlags(flags: SCNetworkReachabilityFlags) -> BONetworkStatus {
        PrintReachabilityFlags(flags, "localWiFiStatusForFlags")
        var returnValue:BONetworkStatus = BONetworkStatus.boNotReachable
        
        if (flags.rawValue & SCNetworkReachabilityFlags.reachable.rawValue) != 0 && (flags.rawValue & SCNetworkReachabilityFlags.isDirect.rawValue) != 0 {
            returnValue = BONetworkStatus.boReachableViaWiFi
        }
        
        return returnValue
    }
    
    
    func networkStatus(for flags: SCNetworkReachabilityFlags) -> BONetworkStatus {
        PrintReachabilityFlags(flags, "networkStatusForFlags")
        if (flags.rawValue & SCNetworkReachabilityFlags.reachable.rawValue) == 0 {
            // The target host is not reachable.
            return BONetworkStatus.boNotReachable
        }
        
        var returnValue:BONetworkStatus = BONetworkStatus.boNotReachable
        if (flags.rawValue & SCNetworkReachabilityFlags.connectionRequired.rawValue) == 0 {
            /*
             If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
             */
            returnValue = BONetworkStatus.boReachableViaWiFi
        }
        if ((flags.rawValue & SCNetworkReachabilityFlags.connectionOnDemand.rawValue) != 0) || (flags.rawValue & SCNetworkReachabilityFlags.connectionOnTraffic.rawValue) != 0 {
            if (flags.rawValue & SCNetworkReachabilityFlags.interventionRequired.rawValue) == 0 {
                
                returnValue = BONetworkStatus.boReachableViaWiFi
            }
        }
        if (flags.rawValue & SCNetworkReachabilityFlags.isWWAN.rawValue) == SCNetworkReachabilityFlags.isWWAN.rawValue {
            /*
             ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
             */
            returnValue = BONetworkStatus.boReachableViaWWAN
        }
        //TODO: test this upodated from bool to networkstatus here
        return returnValue
    }
    
    func currentReachabilityStatus() -> BONetworkStatus {
        //todo uncomment later   assert(reachabilityRef != nil, "currentNetworkStatus called with NULL reachabilityRef")
        var returnValue = BONetworkStatus.boNotReachable
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags()
        //TOD
        
        if reachabilityRef != nil{
            if SCNetworkReachabilityGetFlags(reachabilityRef!, &flags) {
                if localWiFiRef {
                    returnValue = localWiFiStatusForFlags(flags: flags)
                } else {
                    returnValue = networkStatus(for: flags)
                }
            }
        }
        return returnValue
    }
    
    func isDeviceOnline() -> Bool {
        return currentReachabilityStatus() != BONetworkStatus.boNotReachable
    }
}
