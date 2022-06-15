//
//  BOASystemEvents.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 22/03/22.
//

import Foundation
import UIKit
class BOASystemEvents:NSObject {
    
    class func captureAppLaunchingInfo(withConfiguration launchOptions: [AnyHashable : Any]?) {

            let analytics = BlotoutAnalytics.sharedInstance
            let analyticsRootUD = BOFUserDefaults(product: BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY)
            let sdkManifesCtrl = BOASDKManifestController.sharedInstance
            
            
        let previousBuildV1 = (analyticsRootUD.object(forKey: BO_BUILD_KEYV1)as? NSNumber)?.intValue ?? 0
        //(analyticsRootUD.value(forKey: BO_BUILD_KEYV1) as? NSNumber)?.intValue ?? 0
            if previousBuildV1 != 0 {
                
                //TODO:check if this needs to be a string type
                analyticsRootUD.setObject(previousBuildV1, forKey: BO_BUILD_KEYV2)
                //(NSNumber(object: previousBuildV1).stringValue, forKey: BO_BUILD_KEYV2)
                analyticsRootUD.removeObjectForKey(aKey: BO_BUILD_KEYV1)
            }
            let previousVersion = analyticsRootUD.object(forKey:BO_VERSION_KEY) as? String
            let previousBuildV2 = analyticsRootUD.object(forKey:BO_BUILD_KEYV2) as? String
            
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            
            if (previousBuildV2 == nil) && sdkManifesCtrl.isSystemEventEnabled(BO_APPLICATION_INSTALLED) {
                analytics.capture(
                    "Application Installed",
                    withInformation: [
                        "version": currentVersion ?? "",
                        "build": currentBuild ?? ""
                    ],
                    withType: BO_SYSTEM,
                    withEventCode: NSNumber(value: BO_APPLICATION_INSTALLED))
            }
            else if (currentBuild != previousBuildV2) && sdkManifesCtrl.isSystemEventEnabled(BO_APPLICATION_UPDATED) {
                analytics.capture(
                    "Application Updated",
                    withInformation: [
                        "previous_version": previousVersion ?? "",
                        "previous_build": previousBuildV2 ?? "",
                        "version": currentVersion ?? "",
                        "build": currentBuild ?? ""
                    ],
                    withType: BO_SYSTEM,
                    withEventCode: NSNumber(value: BO_APPLICATION_UPDATED))
            }
            
        
        var referringApplication:String = ""
        if launchOptions?[UIApplication.LaunchOptionsKey.sourceApplication] != nil
        {
            referringApplication = launchOptions?[UIApplication.LaunchOptionsKey.sourceApplication] as? String ?? ""
        }
        
        var urlValue :String = ""
        if launchOptions?[UIApplication.LaunchOptionsKey.url] != nil
        {
            urlValue = launchOptions?[UIApplication.LaunchOptionsKey.url] as? String ?? ""
        }
            if sdkManifesCtrl.isSystemEventEnabled(BO_APPLICATION_OPENED) {
                analytics.capture(
                    "Application Opened",
                    withInformation: [
                        "from_background": NSNumber(value: false),
                        "version": currentVersion ?? "",
                        "build": currentBuild ?? "",
                        "referring_application": referringApplication,
                        "url": urlValue
                    ],
                    withType: BO_SYSTEM,
                    withEventCode: NSNumber(value: BO_APPLICATION_OPENED))
            }
            analyticsRootUD.setObject(currentVersion, forKey: BO_VERSION_KEY)
            analyticsRootUD.setObject(currentBuild, forKey: BO_BUILD_KEYV2)
    }
}
