//
//  BOADeveloperEvents.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 22/03/22.
//

import Foundation
import UIKit
class BOADeveloperEvents: NSObject {
    
    class func captureEvent(_ payload: BOACaptureModel?) -> EventModel? {
      //  return BOADeveloperEvents.createEventObject(eventName: payload?.event ?? "", withType: payload?.type ?? "", withScreenName: payload?.screenName ?? "", withEventInfo: payload?.properties ?? [:])
        
        return BOADeveloperEvents.createEventModel(eventName: payload?.event ?? "", withType: payload?.type ?? "", withScreenName: payload?.screenName ?? "", withEventInfo: payload?.properties ?? [:])
        
    }
    
//    class func capturePersonalEvent(_ payload: BOACaptureModel?, isPHI phiEvent: Bool) -> [AnyHashable : Any]? {
//        return BOADeveloperEvents.preparePersonalEvent(payload?.event ?? "", withScreenName: payload?.screenName ?? "", withEventSubcode: payload?.eventSubCode ?? 0 , withEventInfo: payload?.properties ?? [:], isPHI: phiEvent)
//        //TODO: check event subcode default value
//    }
    
    
    class func prepareServerPayload(events: [EventModel]) -> [AnyHashable : Any]? {
            var eventData: [AnyHashable] = []
            let metaInfo = BOServerDataConverter.prepareMetaData()
            
            for event in events {
                var eventDict = [String:AnyHashable]()
               // if let value = event{//eventDict[BO_EVENTS]{
                   // eventData.insert(event, at: 0)
                eventDict =  prepareEventDict(fromEventModel: event)
                eventData.append(eventDict)
                //insert(eventDict, at: 0)
               // }
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
    
    class func prepareEventDict(fromEventModel:EventModel)->[String:AnyHashable]
    {
        /*var evn:String?
         var evt:NSNumber?
         var mid : String?
         var scrn : String?
         var session_id : String?
         var type:String?
         var userid:String?
         var additionalData : [AnyHashable : Any]?
         var screen : [AnyHashable : Any]?*/
        var eventDict:Dictionary = [String:AnyHashable]()
        eventDict["evn"] = fromEventModel.evn
        eventDict["evt"] = fromEventModel.evt
        eventDict["mid"] = fromEventModel.mid
        eventDict["scrn"] = fromEventModel.scrn
        eventDict["session_id"] = fromEventModel.session_id
        eventDict["type"] = fromEventModel.type
        eventDict["userid"] = fromEventModel.userid
        eventDict["additionalData"] = fromEventModel.additionalData as! AnyHashable
        eventDict["screen"] = fromEventModel.screen as! AnyHashable
        
        return eventDict
    }
    
    
    
    class func createEventObject( eventName: String, withType type: String, withScreenName screenName: String, withEventInfo eventInfo: [AnyHashable : Any]) -> [AnyHashable : Any]? {

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
                properties[BO_PATH] = screenName
                
              //  for var element in properties { element.BO_PATH = screenName }
            }
            event[BO_SESSION_ID] = BOSharedManager.sharedInstance.sessionId
           // for var element in event { element.BO_SESSION_ID = BOSharedManager.sharedInstance.sessionId }
            event["additionalData"] = properties
            return [
                BO_EVENTS: event
            ]

    }
    
    
    class func createEventModel( eventName: String, withType type: String, withScreenName screenName: String, withEventInfo eventInfo: [AnyHashable : AnyHashable]) -> EventModel
    {
        var properties: [AnyHashable : AnyHashable] = [:]
        for (k, v) in eventInfo { properties[k] = v }
        let screenName = (screenName.count > 0) ? screenName : BOSharedManager.sharedInstance.currentScreenName
       
        let eventTime = BOAUtilities.get13DigitNumberObjTimeStamp()
        let messageID = BOAUtilities.getMessageID(forEvent: eventName)
        
        let userID = BOAUtilities.getDeviceId()
        let session_id = BOSharedManager.sharedInstance.sessionId
        let screen = BOADeveloperEvents.getScreenPayload()
        if type == "system" {
            properties[BO_PATH] = screenName
        }
        
        var event:EventModel = EventModel(evn: eventName, evt: eventTime, mid: messageID, scrn: screenName, session_id: session_id, type: type, userid: userID, additionalData: properties, screen: screen)
        return event
    }
    
    class func getScreenPayload() -> [AnyHashable : AnyHashable]? {
        var screenInfo: [AnyHashable : AnyHashable] = [:]
            let screenSize = UIScreen.main.bounds.size
            screenInfo["width"] = NSNumber(value: Float(screenSize.width))
            screenInfo["height"] = NSNumber(value: Float(screenSize.height))
        
        return screenInfo
    }
    
}
