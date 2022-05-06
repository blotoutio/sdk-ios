//
//  BONetworkManager.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation
//
//public enum BOErrorCodes : Int {
//     case boErrorUnknownn = 10001
//     case boErrorNoInternetConnection
//     case boErrorParsingError
//     case boManifestSyncError
// }

class BONetworkManager:NSObject{
    
    
    
    class func asyncRequest(
        _ request: URLRequest?,
        success successBlock_: @escaping (Any?, URLResponse?) -> Void,
        failure failureBlock_: @escaping (Any?, URLResponse?, Error?) -> Void) {
            
            if BOReachability().currentReachabilityStatus() == .boNotReachable {
                let error = BOErrorAdditions.boError(forCode: BOErrorCodes.boErrorNoInternetConnection.rawValue, withMessage: "Network Not Reachable")
                failureBlock_(nil, nil, error)
                return
            }
            
            //TODO: fix this, always failing
            
            let netpromise = BOFNetworkPromise(urlRequest: request, completionHandler: { urlResponse, dataOrLocation, error in
                let httpRes = urlResponse as? HTTPURLResponse
                if httpRes?.statusCode == 200 {
                    successBlock_(dataOrLocation, urlResponse)
                } else {
                    failureBlock_(dataOrLocation, urlResponse, error)
                }
                BOFLogDebug(frmt: "urlResponse:%@  dataOrLocation:%@ error:%@ urlResponse_statusCode:%ld allHeaderFields:%@", args: urlResponse as! CVarArg, dataOrLocation as! CVarArg , error?.localizedDescription as! CVarArg, httpRes?.statusCode as! CVarArg, httpRes?.allHeaderFields as! CVarArg)
            })
            //                                                   else {
            //                    return failureBlock_(dataOrLocation, urlResponse, error)
            //
            //                }
            
            BOFNetworkPromiseExecutor.sharedInstance.execute(netpromise!)
            
        }
}
