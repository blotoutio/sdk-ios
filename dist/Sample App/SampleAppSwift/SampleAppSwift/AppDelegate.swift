//
//  AppDelegate.swift
//  SampleAppSwift
//
//  Created by Shefali Shrivastava on 26/03/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func boSDKInit() throws -> Void {
        let boaSDK : BlotoutAnalytics
        boaSDK =  BlotoutAnalytics.sharedInstance()!
        let config = BlotoutAnalyticsConfiguration.init(token: "B6PSYZ355NS383V", withUrl: "https://stage.blotout.io")
        
        boaSDK.`init`(config) { (isSuccess : Bool, errorObj:Error?) in
            if isSuccess{
                print("Integration Successful.")
                boaSDK.capture("AppLaunchedWithBOSDK", withInformation: nil)
            }else{
                print("Unexpected error:.")
            }
            boaSDK.capture("AppLaunchedWithBOSDK", withInformation: nil)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try boSDKInit()
        } catch {
            print("Unexpected error: \(error).")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

