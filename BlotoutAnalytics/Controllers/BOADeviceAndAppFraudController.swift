//
//  BOADeviceAndAppFraudController.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 23/03/22.
//

import Foundation
import UIKit
import MachO

class BOADeviceAndAppFraudController:NSObject {
    
#if TARGET_IPHONE_SIMULATOR && !LC_ENCRYPTION_INFO
let LC_ENCRYPTION_INFO = 0x21
struct encryption_info_command {
    var cmd: UInt32
    var cmdsize: UInt32
    var cryptoff: UInt32
    var cryptsize: UInt32
    var cryptid: UInt32
}
#endif

#if TARGET_IPHONE_SIMULATOR && !LC_ENCRYPTION_INFO_64
let LC_ENCRYPTION_INFO_64 = 0x2c
struct encryption_info_command {
    var cmd: UInt32
    var cmdsize: UInt32
    var cryptoff: UInt32
    var cryptsize: UInt32
    var cryptid: UInt32
}
#endif

private var sBOAsdkFraudCheckSharedInstance: Any? = nil
    
    override init() {
        super.init()
    }
    
    static let sharedInstance = BOADeviceAndAppFraudController()
    
    class func isDylibInjectedToProcess(withName dylib_name: String?) -> Bool {

            let max = _dyld_image_count()
            for i in 0..<max {
                let name = _dyld_get_image_name(i)
                if let name = name {
                    let namens = String(utf8String: name)
                    let compare = dylib_name ?? ""
                    if namens?.contains(compare) ?? false {
                        return true
                    }
                }
            }
            return false
    }
    
    class func isConnectionProxied() -> Bool {
           /* if (self.proxy_host() != "") && (self.proxy_port() != "") {
                return true
            } else {
                return false
            }*/
      return VpnChecker.isVpnActive()
        //Updated to swift
    }
    
    class func isDeviceJailbroken() -> Bool {
        
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app") {
            return true
        } else if FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") {
            return true
        } else if FileManager.default.fileExists(atPath: "/bin/bash") {
            return true
        } else if FileManager.default.fileExists(atPath: "/usr/sbin/sshd") {
            return true
        }
        else if FileManager.default.fileExists(atPath: "/etc/apt") {
            return true
        } else if FileManager.default.fileExists(atPath: "/private/var/lib/apt/") {
            return true
        } else if !FileManager.default.fileExists(atPath: "/Applications/AppStore.app") {
            //if PSProtector activated -- Tested on iOS 11.0.1
            return true
        } else if !FileManager.default.fileExists(atPath: "/Applications/MobileSafari.app") {
            return true
        }
        
        var f = fopen("/bin/bash", "r")
        if let f = f {
            fclose(f)
            return true
        }
        fclose(f)
        f = fopen("/Applications/Cydia.app", "r")
        if let f = f {
            fclose(f)
            return true
        }
        fclose(f)
        f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")
        if let f = f {
            fclose(f)
            return true
        }
        fclose(f)
        f = fopen("/usr/sbin/sshd", "r")
        if let f = f {
            fclose(f)
            return true
        }
        fclose(f)
        f = fopen("/etc/apt", "r")
        if let f = f {
            fclose(f)
            return true
        }
        fclose(f)
        let error: Error?
        let stringToBeWritten = "if this string is saved, then device is jailbroken"
        var jailBroken = false
        do {
            jailBroken = true
            try stringToBeWritten.write(toFile: "/private/test", atomically: true, encoding: .utf8)
        } catch {
            jailBroken = false
            BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription);
        }
        do {
            try FileManager.default.removeItem(atPath: "/private/test")
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription);
        }
       
        return jailBroken
    }
}

struct VpnChecker {

    private static let vpnProtocolsKeysIdentifiers = [
        "tap", "tun", "ppp", "ipsec", "utun"
    ]

    static func isVpnActive() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }
        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary,
            let allKeys = keys.allKeys as? [String] else { return false }

        // Checking for tunneling protocols in the keys
        for key in allKeys {
            for protocolId in vpnProtocolsKeysIdentifiers
                where key.starts(with: protocolId) {
                return true
            }
        }
        return false
    }
}
