//
//  BOEventPostAPI.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation


class BOEventPostAPI:NSObject {
    
    
    
    func postEventData(_ eventData: Data?,_ success: @escaping (_ success: Bool?) -> Void, failure: @escaping (_ error: Error?) -> Void)
    {
        ServiceLayer.request(router: BOARouter.postEventData, body: eventData) { (result: Result<Bool, Error>) in
        
            switch result {
            case .success:
                success(true)
                print(result)
            case .failure(let manifestError):
                failure(manifestError)
                print(result)
            }
        }
    }
    
    /*
    func postEventDataModel(_ eventData: Data?, withAPICode urlEndPoint: BOUrlEndPoint, success: @escaping (_ responseObject: Any?) -> Void, failure: @escaping (_ urlResponse: URLResponse?, _ dataOrLocation: Any?, _ error: Error?) -> Void) {
        do{
            let apiEndPoint = resolveAPIEndPoint(urlEndPoint)
            var urlRequest: NSMutableURLRequest? = nil
            if let url = URL(string: apiEndPoint) {
                urlRequest = NSMutableURLRequest(url: url)
            }
            urlRequest?.httpMethod = EPAPostAPI
            urlRequest?.allHTTPHeaderFields = prepareRequestHeaders() as? [String : String]
            
            
            if eventData != nil {
                urlRequest?.httpBody = eventData
                BOFLogDebug(frmt: "DebugAPI_payload Event Data in Body %@", args: String(data: eventData!, encoding: .utf8) as! CVarArg)
            }

            
            BONetworkManager.asyncRequest(urlRequest as URLRequest?) {  data, dataResponse in
                
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
                       BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription as! CVarArg)
                   }
                   success(dict)
            } failure: { data, dataResponse, error in
                var dict1: [AnyHashable : Any]? = nil
                do {
                    
                    if let data = data as? Data {
                        dict1 = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [AnyHashable : Any]
                    }
                }catch {
                    BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription as! CVarArg)
                }
                BOFLogDebug(frmt: "%@", args: dict1!)
                failure(dataResponse, data, error)
            }
    }
}*/
}
