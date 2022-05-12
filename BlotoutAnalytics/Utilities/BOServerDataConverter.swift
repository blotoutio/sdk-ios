//
//  BOServerDataConverter.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 18/04/22.
//

import Foundation
import WebKit

private var appInfo: [AnyHashable : Any] = [AnyHashable : Any]()


class BOServerDataConverter:NSObject {
    
//    override class func load() {
//        appInfo = [AnyHashable : Any]()
//    }
    //TODO: test the alternate to load nby doing initialize
//    override class func initialize() {
//       var onceToken : dispatch_once_t = 0;
//       dispatch_once(&onceToken) {
//           appInfo = [AnyHashable : Any]()
//       }
//    }
    
    class func recordAppInformation() -> [AnyHashable : Any]? {
        
            let launchTimeStamp = BOAUtilities.get13DigitNumberObjTimeStamp()
            
            appInfo["launchTimeStamp"] = launchTimeStamp
            // appInfo.set(launchTimeStamp, forKey: "launchTimeStamp")
            
            let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            let appBuildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            let versionAndBundle = "\(appVersionString ?? "").\(appBuildString ?? "")"
            appInfo["version"] = versionAndBundle
            //appInfo.set(versionAndBundle, forKey: "version")
            
            let sdkVersion = "\(BOSDK_MAJOR_VERSION).\(BOSDK_MINOR_VERSION).\(BOSDK_PATCH_VERSION)"
            appInfo["sdkVersion"] = sdkVersion
            // appInfo.set(sdkVersion, forKey: "sdkVersion")
            
            let bundleInfo = Bundle.main.infoDictionary
            let prodName = bundleInfo?["CFBundleName"] as? String
            appInfo["name"] = prodName
            //appInfo.set(prodName, forKey: "name") //Check this, coming as SalesDemoApp, which is app name
            
            let isProxied = BOADeviceAndAppFraudController.isConnectionProxied() ? 1 : 0
            appInfo["vpnStatus"] = NSNumber(value: isProxied)
            // appInfo.set(NSNumber(value: Bool(isProxied)), forKey: "vpnStatus")
            
            let jbnStatus = BOADeviceAndAppFraudController.isDeviceJailbroken() ? 1 : 0
            appInfo["jbnStatus"] = NSNumber(value: jbnStatus)
            //  appInfo.set(NSNumber(value: Bool(jbnStatus)), forKey: "jbnStatus")
            
            let isDyLibInjected = BOADeviceAndAppFraudController.isDylibInjectedToProcess(withName: "dylib_name") && BOADeviceAndAppFraudController.isDylibInjectedToProcess(withName: "libcycript")
            let dcomp = (isDyLibInjected || (jbnStatus != 0)) ? 1 : 0
            let acomp = isDyLibInjected ? 1 : 0
            appInfo["dcompStatus"] = NSNumber(value: dcomp)
            appInfo["acompStatus"] = NSNumber(value: acomp)
            //            appInfo.set(NSNumber(value: Bool(dcomp)), forKey: "dcompStatus")
            //            appInfo.set(NSNumber(value: Bool(acomp)), forKey: "acompStatus")
            
            let timeoOffset = BOAUtilities.getCurrentTimezoneOffsetInMin()
            appInfo["timeZoneOffset"] = NSNumber(value: Int32(timeoOffset))
            // appInfo.set(NSNumber(value: Int32(timeoOffset)), forKey: "timeZoneOffset")
            
            DispatchQueue.main.async(execute: {
                let userAgent = WKWebView().value(forKey: "userAgent") as? String
                appInfo["userAgent"] = userAgent
                // appInfo.set(userAgent, forKey: "userAgent")
            })
            
            return appInfo
        
    }
    
    class func prepareMetaData() -> [AnyHashable : Any] {
            var appInfoCurrentDict: [AnyHashable : Any]? = nil
        if (appInfo != nil) && (appInfo.values.count > 0) {
                appInfoCurrentDict = appInfo
            } else {
                appInfoCurrentDict = self.recordAppInformation()
            }
            
            let screenName = BOSharedManager.sharedInstance.currentScreenName
            var metaInfo: [AnyHashable : Any]? = nil
            metaInfo = [
                "jbrkn": appInfoCurrentDict?["jbnStatus"],
                "vpn": appInfoCurrentDict?["vpnStatus"],
                "dcomp": appInfoCurrentDict?["dcompStatus"],
                "acomp": appInfoCurrentDict?["acompStatus"],
                "sdkv": appInfoCurrentDict?["sdkVersion"],
                "tz_offset": appInfoCurrentDict?["timeZoneOffset"],
                "user_agent": appInfoCurrentDict?["userAgent"],
                "referrer": BOSharedManager.sharedInstance.referrer,
                "page_title": screenName
            ]

            return metaInfo!
       
    }
}
