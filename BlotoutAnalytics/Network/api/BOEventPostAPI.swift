//
//  BOEventPostAPI.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation


class BOEventPostAPI:NSObject {
    func postEventDataModel(_ eventData: Data?, withAPICode urlEndPoint: BOUrlEndPoint, success: @escaping (_ responseObject: Any?) -> Void, failure: @escaping (_ urlResponse: URLResponse?, _ dataOrLocation: Any?, _ error: Error?) -> Void) {
        do{
            
            let apiEndPoint = resolveAPIEndPoint(urlEndPoint)
            var urlRequest: NSMutableURLRequest? = nil
            if let url = URL(string: apiEndPoint) {
                urlRequest = NSMutableURLRequest(url: url)
            }
            urlRequest?.httpMethod = EPAPostAPI
            urlRequest?.allHTTPHeaderFields = prepareRequestHeaders()
            
            
            if let eventData = eventData {
                urlRequest?.httpBody = eventData
            }

            BOFLogDebug(frmt: "DebugAPI_payload Event Data in Body %@", args: String(data: eventData, encoding: .utf8))
            
            
            
            BONetworkManager.asyncRequest(urlRequest as URLRequest?, success: { data, dataResponse in
                if data == nil {
                    success(dataResponse)
                    return
                }
                var dict: [AnyHashable : Any]? = nil
                   do {
                       if let data = data as? Data {
                           dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [AnyHashable : Any]
                       }
                   } catch {
                   }
                   success(dict)
               }, failure: { data, dataResponse, error in
                   var dict1: [AnyHashable : Any]? = nil
                   do {
                       if let data = data as? Data {
                           dict1 = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [AnyHashable : Any]
                       }
                   }
                   BOFLogDebug("%@", dict1)
                   failure(dataResponse, data, error)
               })
            //tODO: check condition here
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription)
            let error = BOErrorAdditions.boError(forCode: BOErrorCodes.boErrorParsingError, withMessage: nil)
            failure(nil, nil, error!)
        }
    }
}
