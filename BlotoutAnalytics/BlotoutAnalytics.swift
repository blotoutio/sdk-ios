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

public class BlotoutAnalytics:NSObject {
    
    //TODO: have remove uiviewcontroller + extensions, test if it is needed anywhere
    
    public static let sharedInstance = BlotoutAnalytics()
    /// Enable the sending of analytics data. Enabled by default. Set NO to stop sending data
    var enable = false
    /// Enable SDK Log Information
    public var enableSDKLog = false
    var isEnabled = false
    
    var config: BlotoutAnalyticsConfiguration!
    var eventManager: BOAEventsManager!
    var storeKitController: BOAStoreKitController!
    var endPointUrl: String?
    var token: String?
         
    override init() {
        super.init()
        isEnabled = true
        //TODO: understand this
        BOSharedManager.sharedInstance
    }
     
    
    func setIsEnabled(_ isEnabled: Bool) {

        self.isEnabled = isEnabled
      //  BOFNetworkPromiseExecutor.sharedInstance.isSDKEnabled = isEnabled
        //BOFNetworkPromiseExecutor.sharedInstanceForCampaign?.isSDKEnabled = isEnabled
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
   public func initandCompletionHandler(configuration: BlotoutAnalyticsConfiguration, andCompletionHandler completionHandler:@escaping ((_ isSuccess: Bool, _ error: Error?) -> Void)) {

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
                let remoteNotification = configuration.launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : AnyHashable]
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
        
        let sdkManifest = try BOASDKManifestController.sharedInstance
        sdkManifest.serverSyncManifestAndAppVerification({ isSuccess, error in
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
    
    func mapID(_ mapIDData: BOAMapIDDataModel, withInformation eventInfo: [AnyHashable : AnyHashable]?) {
            if !isEnabled {
                return
            }
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                var mapIdInfo: [AnyHashable : AnyHashable]? = nil
                if let array = [BO_EVENT_MAP_ID, BO_EVENT_MAP_PROVIDER] as? [String] {
                    mapIdInfo = Dictionary(uniqueKeysWithValues: zip(array, [mapIDData.externalID, mapIDData.provider]))
                  //  mapIdInfo = NSDictionary(objects:[mapIDData.externalID, mapIDData.provider], forKeys:array) as! Dictionary<AnyHashable, AnyHashable>
                }
                
                let model = BOACaptureModel(event: BO_EVENT_MAP_ID, properties: mapIdInfo, screenName: nil, withType: BO_CODIFIED)
                eventManager.capture(model)
                
            })

    }
    
  public  func capture(_ eventName: String, withInformation eventInfo: [AnyHashable : Any]?) {

      var eventInformation:[AnyHashable:AnyHashable] = [:]
      if eventInfo != nil
      {
          eventInformation = eventInfo as NSDictionary? as! [AnyHashable : AnyHashable]
      }
      
      
             BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                capture(eventName, withInformation: eventInformation, withType: BO_CODIFIED, withEventCode: NSNumber(value: 0))
            })
        
    }
    
    public func capture(_ eventName: String, withInformation eventInfo: [AnyHashable : AnyHashable]?, withType type: String?, withEventCode eventCode: NSNumber?) {
            if !isEnabled {
                return
            }
            let model =  BOACaptureModel(event: eventName, properties: eventInfo, screenName: nil, withType: type)
            eventManager.capture(model)
        
    }
    
    
    
    @available(*, deprecated, message: "Capture Personal will not be supported in the future")
    func capturePersonal(_ eventName: String, withInformation eventInfo: [AnyHashable : Any], isPHI phiEvent: Bool) {

        return
    }
    
    func getUserId() -> String? {
        return BOAUtilities.getDeviceId()
    }
    
    func trackPushNotification(_ properties: [AnyHashable : AnyHashable]?, fromLaunch launch: Bool) {
        
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
    
    func receivedRemoteNotification(_ userInfo: [AnyHashable : AnyHashable]?) {
       
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
                    var properties: [AnyHashable : AnyHashable] = [:]
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
                var properties: [AnyHashable : AnyHashable] = [:]
                 
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
                var properties = [AnyHashable : AnyHashable](minimumCapacity: activity.userInfo?.count ?? 0 + 2)
               
//                guard let userInfo = activity.userInfo as NSDictionary? as? [String: AnyHashable] else {
//                    properties = [:] as [AnyHashable:AnyHashable]
//                }
                
                if activity.userInfo != nil
                {
                    properties = activity.userInfo as NSDictionary? as! [String: AnyHashable]
                }
                else
                {
                    properties = [:]
                }

               // properties = userInfo
                //TODO: test these values
               // for (k, v) in activity?.userInfo { properties[k] = v }
                properties["url"] = activity.webpageURL?.absoluteString ?? ""
                properties["title"] = activity.title ?? ""
                //TODO:Maybe not doing any change in this
               // properties = BOAUtilities.traverseJSON(properties) as! [AnyHashable : Any]
                refreshSessionAndReferrer(activity.webpageURL?.absoluteString)
                capture("Deep Link Opened", withInformation: properties, withType: BO_SYSTEM, withEventCode: NSNumber(value: BO_DEEP_LINK_OPENED))
            })
 
    }
    
    func openURL(url: URL?, options: [AnyHashable : Any]?) {
            let sdkManifesCtrl = BOASDKManifestController.sharedInstance
            if !isEnabled || !sdkManifesCtrl.isSystemEventEnabled(BO_DEEP_LINK_OPENED) {
                return
            }
            
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                var properties = [AnyHashable : AnyHashable](minimumCapacity: options?.count ?? 0 + 2)
                //TODO: test these values
                
//                guard let userOptions = options as NSDictionary? as? [String: AnyHashable] else {
//                    properties = [:] as [AnyHashable:AnyHashable]
//                }
                
                if options != nil
                {
                    properties = options as NSDictionary? as! [String: AnyHashable]
                }
                else
                {
                    properties = [:]
                }
                
              //  properties = userOptions
               // for (k, v) in options { properties[k] = v }
                properties["url"] = url?.absoluteString
                //TODO:Maybe not doing any change in this
                //properties = BOAUtilities.traverseJSON(properties) as! [AnyHashable : Any]
                refreshSessionAndReferrer(url?.absoluteString)
                capture("Deep Link Opened", withInformation: properties, withType: BO_SYSTEM, withEventCode: NSNumber(value: BO_DEEP_LINK_OPENED))
            })

    }
    
    func refreshSessionAndReferrer(_ referrerUrl: String?) {
        if BOSharedManager.sharedInstance.referrer?.count ?? 0 > 0 && (BOSharedManager.sharedInstance.referrer != referrerUrl) {
            BOSharedManager.refreshSession()
        }
        
        BOSharedManager.sharedInstance.referrer = referrerUrl
    }
    
    func registerApplicationStates() {
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
                guard let name = name.rawValue as? String else {
                    continue
                }
                nc.addObserver(self, selector: #selector(handleAppStateNotification(_:)), name: NSNotification.Name(name), object: nil)
            }
    }
    
    @objc func handleAppStateNotification(_ note: Notification?) {
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
            if !isEnabled {
                return
            }
             BOASystemEvents.captureAppLaunchingInfo(withConfiguration: launchOptions)
    }
    
    func _applicationWillEnterForeground() {
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
            
            let model = BOACaptureModel(event: BO_VISIBILITY_VISIBLE, properties: nil, screenName: nil, withType: BO_SYSTEM)
            eventManager.capture(model)
    }
    
    func _applicationDidEnterBackground() {

            if !isEnabled {
                return
            }
            
            let model =  BOACaptureModel(event: BO_VISIBILITY_HIDDEN, properties: nil, screenName: nil, withType: BO_SYSTEM)
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
    
   public func captureTransaction(_ transactionData: TransactionData, withInformation eventInfo: [AnyHashable : AnyHashable]?) {

            if !isEnabled {
                return
            }
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                let keyArray = ["transaction_id", "transaction_currency", "transaction_total", "transaction_discount", "transaction_shipping", "transaction_tax"] as [AnyHashable]
                
                let transactionID = transactionData.transaction_id
                
                let transactionCurrency = transactionData.transaction_currency ?? ""
                let transactionTotal = transactionData.transaction_total ?? 0
                let transactionDiscount = transactionData.transaction_discount ?? 0
                let transactionShipping = transactionData.transaction_shipping ?? 0
                let transactionTax = transactionData.transaction_tax ?? 0
                
                let valueArray = [transactionID, transactionCurrency, transactionTotal, transactionDiscount, transactionShipping, transactionTax] as [AnyHashable]
                var transactionInfo = Dictionary(uniqueKeysWithValues: zip(keyArray,valueArray))
                if (eventInfo != nil) {
                   // for (k, v) in eventInfo! { transactionInfo[k as AnyHashable] = v as AnyHashable }
                    eventInfo!.forEach {
                        transactionInfo[$0.key] = $0.value
                    }
                }
                
                let model = BOACaptureModel(event: BO_EVENT_TRANSACTION_NAME, properties: transactionInfo, screenName: nil, withType: BO_CODIFIED)
                eventManager.capture(model)
            })

    }
    
   public func captureItem(_ itemData: Item, withInformation eventInfo: [AnyHashable : AnyHashable]?) {

            if !isEnabled {
                return
            }
            
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                
                let keyArray = ["item_id", "item_name", "item_sku", "item_category", "item_price", "item_currency", "item_quantity"] as [AnyHashable]
                
                let itemID = itemData.item_id
                let itemName = itemData.item_name ?? ""
                let itemSKU =  itemData.item_sku ?? ""
                let itemCategory = itemData.item_category ?? []
                let itemPrice = itemData.item_price ?? 0
                let itemCurrency =  itemData.item_currency ?? ""
                let itemQuantity = itemData.item_quantity ?? 0
                
                let valueArray = [itemID,itemName , itemSKU, itemCategory , itemPrice, itemCurrency, itemQuantity] as [AnyHashable]
                
                var itemInfo = Dictionary(uniqueKeysWithValues: zip(keyArray,valueArray))

                if (eventInfo != nil) {
                    for (k, v) in eventInfo! { itemInfo[k as AnyHashable] = v as AnyHashable }
                }
                
                let model = BOACaptureModel(event: BO_EVENT_ITEM_NAME, properties: itemInfo, screenName: nil, withType: BO_CODIFIED)
                eventManager.capture(model)
            })

    }
    
  public  func capturePersona(_ personaData: Persona, withInformation eventInfo: [AnyHashable : AnyHashable]?) {

            if !isEnabled {
                return
            }
            
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                
                let keyArray = ["persona_id", "persona_firstname", "persona_middlename", "persona_lastname", "persona_username", "persona_dob", "persona_email", "persona_number", "persona_address", "persona_city", "persona_state", "persona_zip", "persona_country", "persona_gender", "persona_age"] as [AnyHashable]
                
                let personaID = personaData.persona_id
                let personaFirstName = personaData.persona_firstname ?? ""
                let personaMiddleName = personaData.persona_middlename ?? ""
                let personaLastName = personaData.persona_lastname ?? ""
                let personaUserName = personaData.persona_username ?? ""
                let personaDOB = personaData.persona_dob ?? ""
                let personaEmail = personaData.persona_email ?? ""
                let personaNumber = personaData.persona_number ?? ""
                let personaAddress = personaData.persona_address ?? ""
                let personaCity = personaData.persona_city ?? ""
                let personaState = personaData.persona_state ?? ""
                let personaZip = personaData.persona_zip ?? 0
                let personaCountry = personaData.persona_country ?? ""
                let personaGender = personaData.persona_gender ?? ""
                let personaAge = personaData.persona_age ?? 0
                
                
                let valueArray = [personaID, personaFirstName, personaMiddleName, personaLastName, personaUserName, personaDOB, personaEmail, personaNumber, personaAddress, personaCity, personaState, personaZip, personaCountry, personaGender, personaAge] as [AnyHashable]
                var personaInfo = Dictionary(uniqueKeysWithValues: zip(keyArray,valueArray))
                
                if (eventInfo != nil) {
                    for (k, v) in eventInfo! { personaInfo[k as AnyHashable] = v as AnyHashable }
                }
                
                let model = BOACaptureModel(event: BO_EVENT_PERSONA_NAME, properties: personaInfo, screenName: nil, withType: BO_CODIFIED)
                eventManager.capture(model)
            })

    }
}
                                                                      
                                                                      
                                                                      
