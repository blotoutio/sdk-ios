//
//  BOADeveloperEvents.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 22/03/22.
//

import Foundation
class BOADeveloperEvents: NSObject {
    
    class func captureEvent(_ payload: BOACaptureModel?) -> [AnyHashable : Any]? {
        do{
            return BOADeveloperEvents.createEventObject(payload?.event, withType: payload?.type, withScreenName: payload?.screenName, withEventInfo: payload?.properties)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    class func capturePersonalEvent(_ payload: BOACaptureModel?, isPHI phiEvent: Bool) -> [AnyHashable : Any]? {
        do{
            return BOADeveloperEvents.preparePersonalEvent(payload?.event, withScreenName: payload?.screenName, withEventSubcode: payload?.eventSubCode, withEventInfo: payload?.properties, isPHI: phiEvent)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    
    class func prepareServerPayload(_ events: [AnyHashable]?) -> [AnyHashable : Any]? {
        do{
            var eventData: [AnyHashable] = []
            let metaInfo = BOServerDataConverter.prepareMetaData()
            
            for event in events {
                if let value = event[BO_EVENTS] {
                    eventData.add(value)
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
        } catch {
            BOFLogDebug(frmt: "%@", args: error.localizedDescription)
        }
    }
    
    
    class func createEventObject(_ eventName: String?, withType type: String?, withScreenName screenName: String?, withEventInfo eventInfo: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        do{
            
            var properties: [AnyHashable : Any] = [:]
            for (k, v) in eventInfo { properties[k] = v }
            
            let screenName = (screenName != nil && screenName.count > 0) ? screenName : BOSharedManager.sharedInstance().currentScreenName
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
            for var element in event { element.BO_SESSION_ID = BOSharedManager.sharedInstance().sessionId }
            event.setValue(properties, forKey: "additionalData")
            return [
                BO_EVENTS: event
            ]
        } catch {
            BOFLogDebug(frmt: "%@", args: error.localizedDescription)
        }
    }
    
    class func getEncryptedEvent(_ publicKey: String?, withSecretKey secretKey: String?, withDictionary event: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        do{
            let personalEncryptedData: String? = nil
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
            
            if personalEncryptedSecretKey != nil && personalEncryptedSecretKey.length > 0 && personalEncryptedData != nil && personalEncryptedData.length > 0 {
                return personalPayload
            }
            
        } catch{
            BOFLogDebug(frmt: "%@", args: error.localizedDescription)
        }
        return nil
    }
    
    class func preparePersonalEvent(_ eventName: String?, withScreenName screenName: String?, withEventSubcode eventSubcode: NSNumber?, withEventInfo eventInfo: [AnyHashable : Any]?, isPHI phiEvent: Bool) -> [AnyHashable : Any]? {
        do{
            var secretKey = BOAUtilities.getUUIDString()
            secretKey = secretKey.replacingOccurrences(of: "-", with: "")
            let encryptedData: [AnyHashable : Any]? = nil
            var publicKey: String?
            var eventType: String?
            if phiEvent {
                publicKey = BOASDKManifestController.sharedInstance().phiPublickey
                eventType = BO_PHI
            } else {
                publicKey = BOASDKManifestController.sharedInstance().piiPublicKey
                eventType = BO_PII
            }
            encryptedData = getEncryptedEvent(publicKey, withSecretKey: secretKey, withDictionary: eventInfo)
            return BOADeveloperEvents.createEventObject(eventName, withType: eventType, withScreenName: screenName, withEventInfo: encryptedData)
        } catch {
            BOFLogDebug(frmt: "%@", args: error.localizedDescription)
        }
        return nil
    }
    
    class func getScreenPayload() -> [AnyHashable : Any]? {
        var screenInfo: [AnyHashable : Any] = [:]
        do{
            let screenSize = UIScreen.main.bounds.size
            screenInfo["width"] = NSNumber(value: Float(screenSize.width))
            screenInfo["height"] = NSNumber(value: Float(screenSize.height))
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return screenInfo
    }
    
}
