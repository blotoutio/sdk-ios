//
//  BOManifestAPI.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation


class BOManifestAPI:BOBaseAPI {
    func getManifestDataModel(_ success: @escaping (_ responseObject: Any?, _ data: Any?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
            
            let apiEndPoint = resolveAPIEndPoint(BOUrlEndPoint.manifestPull)
            var urlRequest: NSMutableURLRequest? = nil
            if let url = URL(string: apiEndPoint) {
                urlRequest = NSMutableURLRequest(url: url)
            }
            urlRequest?.httpMethod = EPAPostAPI
            urlRequest?.allHTTPHeaderFields = prepareRequestHeaders() as? [String : String]
            
            BONetworkManager.asyncRequest(urlRequest as URLRequest?, success: { data, dataResponse in
                
                var blockData = data
                BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {
                    blockData = self.check(forNullValue: blockData as? Data)
                    var manifestReadError: Error?
                    
                    var sdkManifestM: BOASDKManifest? = nil
                    do {
                        sdkManifestM = try BOASDKManifest.fromData(data: blockData as? Data, error: manifestReadError)
                    } catch let manifestReadError {
                        BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, manifestReadError.localizedDescription)
                        
                        let error = BOErrorAdditions.boError(forCode: BOErrorCodes.boErrorParsingError.rawValue, withMessage: "")
                        failure(error)
                    }
                    if manifestReadError == nil {
                        success(sdkManifestM, blockData)
                        return
                    }
                    
                    let error = BOErrorAdditions.boError(forCode: BOErrorCodes.boErrorParsingError.rawValue, withMessage: "")
                    failure(error)
                })
            }, failure: { data, dataResponse, error in
                failure(error)
            })
    }
}
