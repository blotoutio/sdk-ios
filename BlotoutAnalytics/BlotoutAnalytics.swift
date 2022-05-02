//
//  BlotoutAnalytics.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 15/04/22.
//

import Foundation
import UIKit
import AppTrackingTransparency
import AdSupport

class BlotoutAnalytics:NSObject {
    
    static let sharedInstance = BlotoutAnalytics()
    /// Enable the sending of analytics data. Enabled by default. Set NO to stop sending data
    var enable = false
    /// Enable SDK Log Information
    var enableSDKLog = false
    var isEnabled = false
    
    var config: BlotoutAnalyticsConfiguration!
    var eventManager: BOAEventsManager!
    var storeKitController: BOAStoreKitController!
    var endPointUrl: String?
    var token: String?
    
    /*
     //TODO : looks like this is not used anymore
     
     init() {
     super.init()
     isEnabled = true
     loadAsUIViewControllerBOFoundationCat()
     loadAsNSDataBase64FoundationCat()
     loadAsNSDataCommonDigestFoundationCat()
     loadAsNSStringBase64FoundationCat()
     BOSharedManager.sharedInstance()
     }
     */
    
    func setIsEnabled(_ isEnabled: Bool) {

        self.isEnabled = isEnabled
        BOFNetworkPromiseExecutor.sharedInstance.isSDKEnabled = isEnabled
        BOFNetworkPromiseExecutor.sharedInstanceForCampaign?.isSDKEnabled = isEnabled
        BOFFileSystemManager.setIsSDKEnabled(isSDKEnabled: isEnabled)

    }
    
    func setEnable(_ enable: Bool) {
        isEnabled = enable
    }
    
    func setEnableSDKLog(_ enableSDKLog: Bool) {

        self.enableSDKLog =  enableSDKLog
        BOFLogs.sharedInstance.isSDKLogEnabled = enableSDKLog
    }
    
    //TODO: fix name properly
    func initandCompletionHandler(configuration: BlotoutAnalyticsConfiguration, andCompletionHandler completionHandler:@escaping ((_ isSuccess: Bool, _ error: Error?) -> Void)) {

            if !validateData(configuration) {
                let initError = NSError(domain: "io.blotout.analytics", code: 100002, userInfo: [
                    "userInfo": "Token and EndPoint Url can't be empty !"
                ])
                completionHandler(false, initError)
                return
            }
            
#if os(tvOS)
            let storage = BOAUserDefaultsStorage(defaults: UserDefaults.standard, namespacePrefix: nil, crypto: getCrypto(configuration))
#else
            
            //TODO: have updated method name here, need to check
            let storage = BOAFileStorage(folder: URL(fileURLWithPath: BOFFileSystemManager.getBOSDKRootDirectory() ?? ""))
#endif
            
            eventManager = BOAEventsManager(configuration: configuration, storage: storage)
            token = configuration.token
            endPointUrl = configuration.endPointUrl
            registerApplicationStates()
            
#if !TARGET_OS_TV
            
            if configuration.launchOptions != nil {
                let remoteNotification = configuration.launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any]
                if let remoteNotification = remoteNotification {
                    trackPushNotification(remoteNotification, fromLaunch: true)
                }
            }

            
            storeKitController = BOAStoreKitController.trackTransactions(for: configuration)
#endif
            
            BOEventsOperationExecutor.sharedInstance.dispatchInitialization(inBackground: { [self] in
                checkManifestAndInitAnalytics() { isSuccess, error in
                    completionHandler(isSuccess, error)
                }
            })
            
            //check for app tracking and fetch IDFA
            checkAppTrackingStatus()
    }
    
    
    func checkManifestAndInitAnalytics(withCompletionHandler completionHandler:@escaping ((_ isSuccess: Bool, _ error: Error?) -> Void)) {

            let sdkManifesCtrl = BOASDKManifestController.sharedInstance
            if sdkManifesCtrl.isManifestAvailable() {
                sdkManifesCtrl.reloadManifestData()
            }
            
            
            fetchManifest({ isSuccess, error in
                if !isSuccess {
                    let serverInitError = NSError(domain: "io.blotout.analytics", code: 100003, userInfo: [
                        "userInfo": "Server Sync failed, check your keys & network connection"
                    ])
                    completionHandler(false, serverInitError)
                    return
                }
                completionHandler(isSuccess, error)
            })
    }
    
    func fetchManifest(_ callback: ((_ isSuccess: Bool, _ error: Error?) -> Void)? = nil) {

            let sdkManifest = try BOASDKManifestController.sharedInstance
            sdkManifest.serverSyncManifestAndAppVerification({ isSuccess, error in
                callback?(isSuccess, error)
            })
    }

    
    func validateData(_ configuration: BlotoutAnalyticsConfiguration?) -> Bool {
        //Confirm and perform 15 character length check if needed
        let token = configuration?.token.trimmingCharacters(in: CharacterSet.whitespaces)
        let endPointUrl = configuration?.endPointUrl.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if token == nil || (token == "") || endPointUrl == nil || (endPointUrl == "") {
            return false
        }
        return true
    }
    
    //TODO : looks like this is not used anymore
    func sdkVersion() -> String? {
            return  "\(BOSDK_MAJOR_VERSION).\(BOSDK_MINOR_VERSION).\(BOSDK_PATCH_VERSION)"
        
    }
    
    func mapID(_ mapIDData: BOAMapIDDataModel, withInformation eventInfo: [AnyHashable : Any]?) {
        do{
            
            if !isEnabled {
                return
            }
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                var mapIdInfo: [AnyHashable : Any]? = nil
                if let array = [BO_EVENT_MAP_ID, BO_EVENT_MAP_PROVIDER] as? [NSCopying] {
                    mapIdInfo = NSDictionary(objects:[mapIDData.externalID, mapIDData.provider], forKeys:array) as Dictionary
                }
                
                let model = BOACaptureModel(event: BO_EVENT_MAP_ID, properties: mapIdInfo, screenName: nil, withType: BO_CODIFIED)
                eventManager.capture(model)
                
            })
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func capture(_ eventName: String, withInformation eventInfo: [AnyHashable : Any]?) {

             BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                capture(eventName, withInformation: eventInfo, withType: BO_CODIFIED, withEventCode: NSNumber(value: 0))
            })
        
    }
    
    func capture(_ eventName: String, withInformation eventInfo: [AnyHashable : Any]?, withType type: String?, withEventCode eventCode: NSNumber?) {
            if !isEnabled {
                return
            }
            let model =  BOACaptureModel(event: eventName, properties: eventInfo, screenName: nil, withType: type)
            eventManager.capture(model)
        
    }
    
    
    
    //TODO: we might remove this completely
    @available(*, deprecated, message: "Capture Personal will not be supported in the future")
    func capturePersonal(_ eventName: String, withInformation eventInfo: [AnyHashable : Any], isPHI phiEvent: Bool) {

        return
//            if !isEnabled {
//                return
//            }
//              BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
//                let type = phiEvent ? BO_PHI : BO_PII
//                let model = BOACaptureModel(event: eventName, properties: eventInfo, screenName: nil, withType: type)
//                eventManager.capturePersonal(model, isPHI: phiEvent)
//            })
    }
    
    func getUserId() -> String? {
        return BOAUtilities.getDeviceId()
    }
    
    func trackPushNotification(_ properties: [AnyHashable : Any]?, fromLaunch launch: Bool) {
        
            let sdkManifesCtrl = BOASDKManifestController.sharedInstance
            
            if !isEnabled {
                return
            }
            if launch && sdkManifesCtrl.isSystemEventEnabled(BO_PUSH_NOTIFICATION_TAPPED) {
                capture("Push Notification Tapped", withInformation: properties, withType: BO_SYSTEM, withEventCode: NSNumber(value: BO_PUSH_NOTIFICATION_TAPPED))
            } else if sdkManifesCtrl.isSystemEventEnabled(BO_PUSH_NOTIFICATION_RECEIVED) {
                capture("Push Notification Received", withInformation: properties, withType: BO_SYSTEM, withEventCode: NSNumber(value: BO_PUSH_NOTIFICATION_RECEIVED))
            }
            
        
    }
    
    func receivedRemoteNotification(_ userInfo: [AnyHashable : Any]?) {
       
            if !isEnabled {
                return
            }
             BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                trackPushNotification(userInfo, fromLaunch: false)
            })
        
    }
    
    func failedToRegisterForRemoteNotificationsWithError(_ error: Error?) {
      
            if !isEnabled {
                return
            }
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                let sdkManifesCtrl = BOASDKManifestController.sharedInstance
                if sdkManifesCtrl.isSystemEventEnabled(BO_REGISTER_FOR_REMOTE_NOTIFICATION) {
                    var properties: [AnyHashable : Any] = [:]
                    properties["deviceRegistered"] = NSNumber(value: 0)
                    capture("Register For Remote Notification", withInformation: properties, withType: BO_SYSTEM, withEventCode: NSNumber(value: BO_REGISTER_FOR_REMOTE_NOTIFICATION))
                }
            })
            
        
    }
    
    func registeredForRemoteNotifications(withDeviceToken deviceToken: Data) {
            if !isEnabled {
                return
            }
            
             BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {
                var properties: [AnyHashable : Any] = [:]
                 
                 let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

                properties["token"] = token
                properties["deviceRegistered"] = NSNumber(value: 1)
                // properties.setValue(token, forKey: "token")
                //properties.setValue(NSNumber(value: 1), forKey: "deviceRegistered")
                
                let sdkManifesCtrl = BOASDKManifestController.sharedInstance
                if sdkManifesCtrl.isSystemEventEnabled(BO_REGISTER_FOR_REMOTE_NOTIFICATION) {
                    self.capture("Remote Notification Register", withInformation: properties, withType: BO_SYSTEM, withEventCode: NSNumber(value: BO_REGISTER_FOR_REMOTE_NOTIFICATION))
                    
                }
            })
       
    }
    
    func continueUserActivity(activity: NSUserActivity) {
            let sdkManifesCtrl =  BOASDKManifestController.sharedInstance
            if !isEnabled || (activity.activityType != NSUserActivityTypeBrowsingWeb) || !sdkManifesCtrl.isSystemEventEnabled(BO_DEEP_LINK_OPENED) {
                return
            }
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                var properties = [AnyHashable : Any](minimumCapacity: activity.userInfo?.count ?? 0 + 2)
               
                properties = activity.userInfo ?? [:]
                //TODO: test these values
               // for (k, v) in activity?.userInfo { properties[k] = v }
                properties["url"] = activity.webpageURL?.absoluteString ?? ""
                properties["title"] = activity.title ?? ""
                properties = BOAUtilities.traverseJSON(properties) as! [AnyHashable : Any]
                refreshSessionAndReferrer(activity.webpageURL?.absoluteString)
                capture("Deep Link Opened", withInformation: properties, withType: BO_SYSTEM, withEventCode: NSNumber(value: BO_DEEP_LINK_OPENED))
            })
 
    }
    
    func openURL(url: URL?, options: [AnyHashable : Any]?) {
        do{
            let sdkManifesCtrl = BOASDKManifestController.sharedInstance
            if !isEnabled || !sdkManifesCtrl.isSystemEventEnabled(BO_DEEP_LINK_OPENED) {
                return
            }
            
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                var properties = [AnyHashable : Any](minimumCapacity: options?.count ?? 0 + 2)
                //TODO: test these values
                properties = options ?? [:]
               // for (k, v) in options { properties[k] = v }
                properties["url"] = url?.absoluteString
                properties = BOAUtilities.traverseJSON(properties) as! [AnyHashable : Any]
                refreshSessionAndReferrer(url?.absoluteString)
                capture("Deep Link Opened", withInformation: properties, withType: BO_SYSTEM, withEventCode: NSNumber(value: BO_DEEP_LINK_OPENED))
            })
            
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func refreshSessionAndReferrer(_ referrerUrl: String?) {
        if BOSharedManager.sharedInstance.referrer?.count ?? 0 > 0 && (BOSharedManager.sharedInstance.referrer != referrerUrl) {
            BOSharedManager.refreshSession()
        }
        
        BOSharedManager.sharedInstance.referrer = referrerUrl
    }
    
    func registerApplicationStates() {
        do{
            // Attach to application state change hooks
            let nc = NotificationCenter.default
            for name in [
                UIApplication.didEnterBackgroundNotification,
                UIApplication.didFinishLaunchingNotification,
                UIApplication.willEnterForegroundNotification,
                UIApplication.willTerminateNotification,
                UIApplication.willResignActiveNotification,
                UIApplication.didBecomeActiveNotification]
            {
                guard let name = name as? String else {
                    continue
                }
                nc.addObserver(self, selector: Selector("handleAppStateNotification:"), name: NSNotification.Name(name), object: nil)
            }
            
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func handleAppStateNotification(_ note: Notification?) {
        BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
            if note?.name == UIApplication.didFinishLaunchingNotification {
                _applicationDidFinishLaunching(withOptions: note?.userInfo)
            }
            else  if note?.name == UIApplication.willEnterForegroundNotification {
                _applicationWillEnterForeground()
            }
            else if note?.name == UIApplication.didEnterBackgroundNotification {
                _applicationDidEnterBackground()
            } else if note?.name == UIApplication.willTerminateNotification {
                _applicationWillTerminate()
            }
        })
    }
    
    func _applicationWillTerminate() {
        eventManager.applicationWillTerminate()
    }
    
    func _applicationDidFinishLaunching(withOptions launchOptions: [AnyHashable : Any]?) {
        do{
            if !isEnabled {
                return
            }
            try BOASystemEvents.captureAppLaunchingInfo(withConfiguration: launchOptions)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func _applicationWillEnterForeground() {
        do{
            if !isEnabled {
                return
            }
            let sdkManifesCtrl = BOASDKManifestController.sharedInstance
            if sdkManifesCtrl.isSystemEventEnabled(BO_APPLICATION_OPENED) {
                capture(
                    "Application Opened",
                    withInformation: [
                        "from_background": NSNumber(value: true)
                    ],
                    withType: BO_SYSTEM,
                    withEventCode: NSNumber(value: BO_APPLICATION_OPENED))
            }
            
            let model = try BOACaptureModel(event: BO_VISIBILITY_VISIBLE, properties: nil, screenName: nil, withType: BO_SYSTEM)
            eventManager.capture(model)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func _applicationDidEnterBackground() {

            if !isEnabled {
                return
            }
            
            let model = try BOACaptureModel(event: BO_VISIBILITY_HIDDEN, properties: nil, screenName: nil, withType: BO_SYSTEM)
            eventManager.capture(model)
            
            let sdkManifesCtrl = BOASDKManifestController.sharedInstance
            if sdkManifesCtrl.isSystemEventEnabled(BO_APPLICATION_BACKGROUNDED) {
                capture("Application Backgrounded", withInformation: nil, withType: BO_SYSTEM, withEventCode: NSNumber(value: BO_APPLICATION_BACKGROUNDED))
            }
            
            
            eventManager.applicationDidEnterBackground()
        
    }
    
    func checkAppTrackingStatus() {

            if !isEnabled {
                return
            }
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {
                
                let sdkManifesCtrl = BOASDKManifestController.sharedInstance
                if !sdkManifesCtrl.isSystemEventEnabled(BO_APP_TRACKING) {
                    return
                }
                
                
                var statusString = ""
                var idfaString = ""
                if #available(iOS 14, *) {
                    let status = ATTrackingManager.trackingAuthorizationStatus
                    switch status {
                    case .authorized:
                        statusString = "Authorized"
                        idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    case .denied:
                        statusString = "Denied"
                    case .restricted:
                        statusString = "Restricted"
                    case .notDetermined:
                        statusString = "Not Determined"
                    default:
                        statusString = "Unknown"
                        
                    }
                }else {
                    // Fallback on earlier version
                    if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                        statusString = "Authorized"
                    idfaString =  ASIdentifierManager.shared().advertisingIdentifier.uuidString

                        //BOAUtilities.getIDFA() ?? ""
                    } else {
                        statusString = "Denied"
                    }
                }
                let model = BOACaptureModel(event: "App Tracking", properties: [
                    "status": statusString,
                    "idfa": idfaString
                ], screenName: nil, withType: BO_SYSTEM)
                self.eventManager.capture(model)
                
            })
       
    }
    
    func captureTransaction(_ transactionData: TransactionData, withInformation eventInfo: [AnyHashable : Any]?) {

            if !isEnabled {
                return
            }
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                var transactionInfo = NSDictionary(objects:[transactionData.transaction_id, transactionData.transaction_currency, transactionData.transaction_total, transactionData.transaction_discount, transactionData.transaction_shipping, transactionData.transaction_tax], forKeys:["transaction_id", "transaction_currency", "transaction_total", "transaction_discount", "transaction_shipping", "transaction_tax"] as [NSCopying]) as Dictionary
                
                if (eventInfo != nil) {
                    for (k, v) in eventInfo! { transactionInfo[k as NSObject] = v as AnyObject }
                }
                
                let model = BOACaptureModel(event: BO_EVENT_TRANSACTION_NAME, properties: transactionInfo, screenName: nil, withType: BO_CODIFIED)
                eventManager.capture(model)
            })

    }
    
    func capture(_ itemData: Item, withInformation eventInfo: [AnyHashable : Any]?) {

            if !isEnabled {
                return
            }
            
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                var itemInfo = NSDictionary(objects:[itemData.item_id, itemData.item_name, itemData.item_sku, itemData.item_category, itemData.item_price, itemData.item_currency, itemData.item_quantity], forKeys:["item_id", "item_name", "item_sku", "item_category", "item_price", "item_currency", "item_quantity"] as [NSCopying]) as Dictionary
                if (eventInfo != nil) {
                    for (k, v) in eventInfo! { itemInfo[k as NSObject] = v as AnyObject }
                }
                
                let model = BOACaptureModel(event: BO_EVENT_ITEM_NAME, properties: itemInfo, screenName: nil, withType: BO_CODIFIED)
                eventManager.capture(model)
            })

    }
    
    func capture(_ personaData: Persona, withInformation eventInfo: [AnyHashable : Any]?) {

            if !isEnabled {
                return
            }
            
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                
                //TODO: make proper dictionary
                var personaInfo = NSDictionary(objects:[personaData.persona_id, personaData.persona_firstname, personaData.persona_middlename, personaData.persona_lastname, personaData.persona_username, personaData.persona_dob, personaData.persona_email, personaData.persona_number, personaData.persona_address, personaData.persona_city, personaData.persona_state, personaData.persona_zip, personaData.persona_country, personaData.persona_gender, personaData.persona_age], forKeys:["persona_id", "persona_firstname", "persona_middlename", "persona_lastname", "persona_username", "persona_dob", "persona_email", "persona_number", "persona_address", "persona_city", "persona_state", "persona_zip", "persona_country", "persona_gender", "persona_age"] as [NSCopying]) as Dictionary
                
                if (eventInfo != nil) {
                    for (k, v) in eventInfo! { personaInfo[k as NSObject] = v as AnyObject }
                }
                
                let model = BOACaptureModel(event: BO_EVENT_PERSONA_NAME, properties: personaInfo, screenName: nil, withType: BO_CODIFIED)
                eventManager.capture(model)
            })

    }
}
                                                                      
                                                                      
                                                                      
