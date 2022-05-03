//
//  BOBaseAPI.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation


public enum BOUrlEndPoint : Int {
     case eventPublish = 0
     case manifestPull
 }

let EPAPostAPI = "POST"
let EPAGetAPI = "GET"
let EPAContentApplicationJson = "application/json"

class BOBaseAPI:NSObject {
    
    func getJsonData(_ data: Data?) -> [AnyHashable : Any]? {
        var dict: [AnyHashable : Any]? = nil
        if let data = data {
            do {
                dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [AnyHashable : Any]
            } catch {
                BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription)
            }
        }
        return dict
    }
    
    func getBaseServerUrl() -> String {
        return BlotoutAnalytics.sharedInstance.endPointUrl ?? ""
    }
    
    public func resolveAPIEndPoint(_ endPoint: BOUrlEndPoint) -> String {
        var url: String
        switch endPoint {
        case BOUrlEndPoint.eventPublish:
            url = "\(getBaseServerUrl())/\(BO_SDK_REST_API_EVENTS_PUSH_PATH)"
            break
            
        case BOUrlEndPoint.manifestPull:
            url = "\(getBaseServerUrl())/\(BO_SDK_REST_API_MANIFEST_PULL_PATH)"
            break
        }
        
        let token = BlotoutAnalytics.sharedInstance.token ?? ""
        return "\(url)?token=\(token)"
        
    }
    
    func prepareRequestHeaders() -> [AnyHashable : Any] {
        return [
            BO_ACCEPT: "application/json",
            BO_CONTENT_TYPE: "application/json"
        ]
    }
    
    // This Method check for null value in response data and replace it with empty string, Temp fix for Manifest Response
    func check(forNullValue data: Data?) -> Data? {
        var responseString: String? = nil
        if let data = data {
            responseString = String(data: data, encoding: .utf8)
        }

        if responseString?.contains("null,") ?? false {
            responseString = responseString?.replacingOccurrences(of: "null,", with: "")
        }

        return responseString?.data(using: .utf8)
    }
}
