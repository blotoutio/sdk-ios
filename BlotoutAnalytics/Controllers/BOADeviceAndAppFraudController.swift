//
//  BOADeviceAndAppFraudController.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 23/03/22.
//

import Foundation
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

class BOADeviceAndAppFraudController {
    init() {
        super.init()
    }
    
    
    class func sharedInstance() -> Self {
        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
        { [self] in
            sBOAsdkFraudCheckSharedInstance = self.init()
        }
        return sBOAsdkFraudCheckSharedInstance
    }
    
    class func getCurrentBinaryInfo() -> [AnyHashable : Any]? {
       do{
            var dictionary: [AnyHashable : Any] = [:]
#if os(iOS) && targetEnvironment(simulator)
            dictionary["unit_type"] = "Simulator"
#else
            dictionary["unit_type"] = "Device"
#endif
            if HardwareIs64BitArch() {
                dictionary.set("x64", forKey: "device_arch")
                dictionary.set(String(format: "%x", LC_ENCRYPTION_INFO_64), forKey: "lc_info")
            } else {
                dictionary.set("x32", forKey: "device_arch")
                dictionary.set(String(format: "%x", LC_ENCRYPTION_INFO), forKey: "lc_info")
            }
            return dictionary
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func isDylibInjectedToProcess(withName dylib_name: String?) -> Bool {
        do{
            let max = dyld_image_count()
            for i in 0..<max {
                let name = dyld_get_image_name(i)
                if let name = name {
                    let namens = String(utf8String: name)
                    let compare = dylib_name
                    if namens?.contains(compare) ?? false {
                        return true
                    }
                }
            }
            return false
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func isConnectionProxied() -> Bool {
       do{
            if (self.proxy_host() != "") && (self.proxy_port() != "") {
                return true
            } else {
                return false
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        
        return false
    }
    
    class func proxy_host() -> String? {
       do{
            let dicRef = CFNetworkCopySystemProxySettings() as? CFDictionary
            let proxyCFstr = CFDictionaryGetValue(dicRef, &kCFNetworkProxiesHTTPProxy) as? CFString
            let tmp = proxyCFstr as String
            if (tmp == "") || (tmp == "(null)") || tmp.length() < 1 {
#if os(macOS)
                let socksproxyCFstr = CFDictionaryGetValue(dicRef, &kCFNetworkProxiesSOCKSProxy) as? CFString
                tmp = socksproxyCFstr as String
#endif
            }
            return tmp
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func proxy_port() -> String? {
        do{
            let dicRef = CFNetworkCopySystemProxySettings() as? CFDictionary
            let portCFnum = CFDictionaryGetValue(dicRef, &kCFNetworkProxiesHTTPPort) as? CFNumber
            let port: Int32
            let tmp = ""
            if portCFnum && CFNumberGetValue(portCFnum, .sInt32Type, &port) {
                tmp = String(format: "%i", Int(port))
            } else {
#if os(macOS)
                let portCFnumSocks = CFDictionaryGetValue(dicRef, &kCFNetworkProxiesSOCKSPort) as? CFNumber
                if portCFnumSocks != nil && CFNumberGetValue(portCFnumSocks, .sInt32Type, &port) {
                    tmp = String(format: "%i", Int(port))
                }
#endif
            }
            return tmp
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func isDeviceJailbroken() -> Bool {
        do{
            
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
            var error: Error?
            let stringToBeWritten = "if this string is saved, then device is jailbroken"
            do {
                try stringToBeWritten.write(toFile: "/private/test", atomically: true, encoding: .utf8)
            } catch {
            }
            do {
                try FileManager.default.removeItem(atPath: "/private/test")
            } catch {
            }
            if error == nil {
                return true
            }
        } catch{
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    class func ttyWayIsDebuggerConnected() -> Bool {
       do{
            let fd = STDERR_FILENO
            if fcntl(fd, F_GETFD, 0) < 0 {
                return false
            }
            let buf = [Int8](repeating: 0, count: MAXPATHLEN + 1)
            if fcntl(fd, F_GETPATH, buf) >= 0 {
                if strcmp(buf, "/dev/null") == 0 {
                    return false
                }
                
                if strncmp(buf, "/dev/tty", 8) == 0 {
                    return true
                }
            }
            
            var type: Int
            if ioctl(fd, FIODTYPE, &type) < 0 {
                return false
            }
            return type != D_DISK
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func isDebuggerConnected() -> Bool {
        do{
            let mib = [Int](repeating: 0, count: 4)
            var info: kinfo_proc
            info.kp_proc.p_flag = 0
            mib[0] = CTL_KERN
            mib[1] = KERN_PROC
            mib[2] = KERN_PROC_PID
            mib[3] = getpid()
            var size = MemoryLayout.size(ofValue: info)
            let junk = sysctl(mib, MemoryLayout.size(ofValue: mib) / MemoryLayout.size(ofValue: mib), &info, &size, nil, 0)
            assert(junk == 0)
            return (info.kp_proc.p_flag & P_TRACED) != 0
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    func main(_ argc: Int, _ argv: [Int8]?) -> Int {
    }
    
    var HardwareIs64BitArchSHardwareChecked = false
    let HardwareIs64BitArchSIs64bitHardware = false
    
    private func HardwareIs64BitArch() -> Bool {
       do{
#if __LP64__
            return true
            if HardwareIs64BitArchSHardwareChecked {
                return HardwareIs64BitArchSIs64bitHardware
            }
            
            HardwareIs64BitArchSHardwareChecked = true
#if os(iOS) && targetEnvironment(simulator)
            sIs64bitHardware = DeviceIs64BitSimulator()
#else
            var host_basic_info: host_basic_info
            var count: UInt
            let returnValue = host_info(mach_host_self(), HOST_BASIC_INFO, (&host_basic_info) as? host_info_t, &count)
            if returnValue != KERN_SUCCESS {
                sIs64bitHardware = false
            }
            sIs64bitHardware = (host_basic_info.cpu_type == CPU_TYPE_ARM64)
#endif
            return HardwareIs64BitArchSIs64bitHardware
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    
    private func DeviceIs64BitSimulator() -> Bool {
        do{
            
            let is64bitSimulator = false
            let mib = [0, 0, 0, 0, 0, 0]
            mib[0] = CTL_KERN
            mib[1] = KERN_PROC
            mib[2] = KERN_PROC_ALL
            let numberOfRunningProcesses = 0
            let BSDProcessInformationStructure: kinfo_proc? = nil
            let sizeOfBufferRequired: size_t = 0
            let successfullyGotProcessInformation = false
            let error = 0

            while successfullyGotProcessInformation == false {
                error = sysctl(mib, 3, nil, &sizeOfBufferRequired, nil, 0)
                if error != nil {
                    return nil
                }
                if let proc = malloc(sizeOfBufferRequired) as? kinfo_proc {
                    BSDProcessInformationStructure = proc
                }
                if BSDProcessInformationStructure == nil {
                    return nil
                }
            }
            error = sysctl(mib, 3, BSDProcessInformationStructure, &sizeOfBufferRequired, nil, 0)
            if error == 0 {
                successfullyGotProcessInformation = true
            } else {
                free(BSDProcessInformationStructure)
            }
            
            numberOfRunningProcesses = sizeOfBufferRequired / MemoryLayout.size(ofValue: kinfo_proc)
            for i in 0..<numberOfRunningProcesses {
                let name = BSDProcessInformationStructure[i].kp_proc.p_comm
                if strcmp(name, "SimulatorBridge") == 0 {
                    let p_flag = BSDProcessInformationStructure[i].kp_proc.p_flag
                    is64bitSimulator = (p_flag & P_LP64) == P_LP64
                    break
                }
            }
            
            free(BSDProcessInformationStructure)
            return is64bitSimulator
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
}

