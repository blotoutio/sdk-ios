//
//  BOADeveloperEvents.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 22/03/22.
//

import Foundation
import UIKit
class BOADeveloperEvents: NSObject {
    
    class func captureEvent(_ payload: BOACaptureModel?) -> [AnyHashable : Any]? {
        return BOADeveloperEvents.createEventObject(eventName: payload?.event ?? "", withType: payload?.type ?? "", withScreenName: payload?.screenName ?? "", withEventInfo: payload?.properties ?? [:])
        
    }
    
    class func capturePersonalEvent(_ payload: BOACaptureModel?, isPHI phiEvent: Bool) -> [AnyHashable : Any]? {
        return BOADeveloperEvents.preparePersonalEvent(payload?.event ?? "", withScreenName: payload?.screenName ?? "", withEventSubcode: payload?.eventSubCode ?? 0 , withEventInfo: payload?.properties ?? [:], isPHI: phiEvent)
        //TODO: check event subcode default value
    }
    
    
    class func prepareServerPayload(events: [AnyHashable]) -> [AnyHashable : Any]? {
            var eventData: [AnyHashable] = []
            let metaInfo = BOServerDataConverter.prepareMetaData()
            
            for event in events {
                let eventDict:Dictionary = event as! Dictionary <AnyHashable, AnyHashable>
                if let value = eventDict[BO_EVENTS]{
                    eventData.insert(value, at: 0)
                }
            }
            if metaInfo != nil && eventData != nil {
                return [
                    BO_META: metaInfo,
                    BO_EVENTS: eventData
                ]
            } else {
                return [:]
            }
    }
    
    
    class func createEventObject( eventName: String, withType type: String, withScreenName screenName: String, withEventInfo eventInfo: [AnyHashable : Any]) -> [AnyHashable : Any]? {
        do{
            
            var properties: [AnyHashable : Any] = [:]
            for (k, v) in eventInfo { properties[k] = v }
            
            let screenName = (screenName.count > 0) ? screenName : BOSharedManager.sharedInstance.currentScreenName
            var event: [AnyHashable : Any] = [:]
            event[BO_EVENT_NAME_MAPPING] = eventName
            event[BO_EVENTS_TIME] = BOAUtilities.get13DigitNumberObjTimeStamp()
            event[BO_MESSAGE_ID] = BOAUtilities.getMessageID(forEvent: eventName)
            
            event[BO_USER_ID] = BOAUtilities.getDeviceId()
            event[BO_SCREEN_NAME] = screenName
            event[BO_SCREEN] = BOADeveloperEvents.getScreenPayload()
            event[BO_TYPE] = type
            if type == "system" {
                for var element in properties { element.BO_PATH = screenName }
            }
            for var element in event { element.BO_SESSION_ID = BOSharedManager.sharedInstance.sessionId }
            event["additionalData"] = properties
            return [
                BO_EVENTS: event
            ]
        } catch {
            BOFLogDebug(frmt: "%@", args: error.localizedDescription)
        }
    }
    
    class func getEncryptedEvent(_ publicKey: String?, withSecretKey secretKey: String?, withDictionary event: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        do{
            var personalEncryptedData: String? = nil
            let personalEncryptedSecretKey: String? = nil
            if event == nil {
                return nil
            }
            var dataToEncryptPII: Data? = nil
            do {
                dataToEncryptPII = try JSONSerialization.data(withJSONObject: event, options: .fragmentsAllowed)
            } catch {
            }
            
            personalEncryptedData = BOCrypt.encryptDataWithoutHash(dataToEncryptPII, key: secretKey, iv: BO_CRYPTO_IVX)
            personalEncryptedSecretKey = BOEncryptionManager.encryptString(secretKey, publicKey: publicKey)
            
            var personalPayload: [AnyHashable : Any] = [:]
            personalPayload[BO_KEY] = personalEncryptedSecretKey
            personalPayload[BO_IV] = BO_CRYPTO_IVX
            personalPayload[BO_DATA] = personalEncryptedData
            
            if personalEncryptedSecretKey != nil && personalEncryptedSecretKey?.count ?? 0 > 0 && personalEncryptedData != nil && personalEncryptedData?.count ?? 0 > 0 {
                return personalPayload
            }
            
        } catch{
            BOFLogDebug(frmt: "%@", args: error.localizedDescription)
        }
        return nil
    }
    
    class func preparePersonalEvent(_ eventName: String, withScreenName screenName: String, withEventSubcode eventSubcode: NSNumber, withEventInfo eventInfo: [AnyHashable : Any], isPHI phiEvent: Bool) -> [AnyHashable : Any]? {
            var secretKey = BOAUtilities.getUUIDString()
            secretKey = secretKey?.replacingOccurrences(of: "-", with: "")
            var encryptedData: [AnyHashable : Any]? = nil
            var publicKey: String?
            var eventType: String?
            if phiEvent {
                publicKey = BOASDKManifestController.sharedInstance.phiPublickey
                eventType = BO_PHI
            } else {
                publicKey = BOASDKManifestController.sharedInstance.piiPublicKey
                eventType = BO_PII
            }
            encryptedData = getEncryptedEvent(publicKey, withSecretKey: secretKey, withDictionary: eventInfo)
            return BOADeveloperEvents.createEventObject(eventName: eventName, withType: eventType!, withScreenName: screenName, withEventInfo: encryptedData ?? [:])
        
    }
    
    class func getScreenPayload() -> [AnyHashable : Any]? {
        var screenInfo: [AnyHashable : Any] = [:]
            let screenSize = UIScreen.main.bounds.size
            screenInfo["width"] = NSNumber(value: Float(screenSize.width))
            screenInfo["height"] = NSNumber(value: Float(screenSize.height))
        
        return screenInfo
    }
    
}
