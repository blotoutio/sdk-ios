//
//  BOARouter.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 04/05/22.
//

import Foundation


public enum BOUrlEndPoint : Int {
     case eventPublish = 0
     case manifestPull
 }

enum BOARouter {
    
    case getManifest
    case postEventData
    

    var scheme: String {
        switch self {
        case .getManifest, .postEventData:
            return "https"
        }
    }

    
    func getBaseServerUrl() -> String {
        return BlotoutAnalytics.sharedInstance.endPointUrl ?? ""
    }

    
    var host: String {
        switch self {
        case .getManifest, .postEventData:
            return getBaseServerUrl()
        }
    }

    var path: String {
        switch self {
        case .getManifest:
            return "/sdk/v1/manifest/pull" //TODO: update this later to include "/" BO_SDK_REST_API_MANIFEST_PULL_PATH
       case . postEventData:
            return "/admin/collects.json"
           
        }
    }

    var parameters: [URLQueryItem] {
        let token = BlotoutAnalytics.sharedInstance.token ?? ""
        switch self {
        case .getManifest,.postEventData:
            return [
                URLQueryItem(name: "token", value: token)]
      
        }
    }

    var method: String {
        switch self {
        case .getManifest, .postEventData:
            return "POST"
        }
    }
    
    //add this in request
    var headerFields:[String : String]{
        switch self {
        case .getManifest, .postEventData:
           return [
                BO_ACCEPT: "application/json",
                BO_CONTENT_TYPE: "application/json"
            ]
        }
    }
    
    public func resolveAPIEndPoint(_ endPoint: BOUrlEndPoint) -> String {
        var url: String
        switch self {
        case .getManifest:
            url = "\(getBaseServerUrl())/\(BO_SDK_REST_API_MANIFEST_PULL_PATH)"
            break
        case .postEventData:
            url = "\(getBaseServerUrl())/\(BO_SDK_REST_API_EVENTS_PUSH_PATH)"

        }
        
        let token = BlotoutAnalytics.sharedInstance.token ?? ""
        return "\(url)?token=\(token)"
        
    }
    
}
