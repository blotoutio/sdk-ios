//
//  NSError+BOAdditions.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 18/04/22.
//

import Foundation



public enum BOErrorCodes : Int {
    case boErrorUnknownn = 10001
    case boErrorNoInternetConnection
    case boErrorParsingError
    case boManifestSyncError
}

class BOErrorAdditions: Error {
//}
//extension Error {

    
   static var BOErrorDomain:String {
        return "com.blotout.sdk"
    }
    static var BOUnknownErrorMsg:String {
        return "Unable to process the request. Unknown error occurred from server. Please try again later"
    }
    static var BONoInternetConnectionErrorMsg:String {
        return "The Internet connection appears to be offline."
    }
    static var BOParsingErrorMsg:String {
        return "Parsing Error."
    }
    static var BOManifestSyncErrorMsg:String {
        return "Server Sync failed, check your keys & network connection"
    }
    
//     let BOErrorDomain = "com.blotout.sdk"
//    let BOUnknownErrorMsg = "Unable to process the request. Unknown error occurred from server. Please try again later"
//    let BONoInternetConnectionErrorMsg = "The Internet connection appears to be offline."
//    let BOParsingErrorMsg = "Parsing Error."
//    let BOManifestSyncErrorMsg = "Server Sync failed, check your keys & network connection"
    
    class func boError(forCode errorCode: Int, withMessage msg: String?) -> Error? {
            var errorDesc = msg
            if errorDesc == nil {
                errorDesc = Self.boErrorMsg(forCode: BOErrorCodes(rawValue: errorCode) ?? .boErrorUnknownn, withMessage: msg ?? "")
            }
            
            let error = NSError(domain: BOErrorDomain, code: errorCode, userInfo: [
                NSLocalizedDescriptionKey: errorDesc ?? ""
            ])
            return error
    }
    
    static func boError(forDict userInfo: [AnyHashable : Any]?) -> Error? {
        return NSError(domain: BOErrorDomain, code: Int(BOErrorCodes.boErrorUnknownn.rawValue), userInfo: userInfo as? [String : Any])
    }
    
    static func boErrorMsg(forCode code: BOErrorCodes, withMessage msg: String?) -> String? {
        var errorDesc = msg
        switch code {
        case BOErrorCodes.boErrorNoInternetConnection:
            errorDesc = BONoInternetConnectionErrorMsg
        case BOErrorCodes.boErrorParsingError:
            errorDesc = BOParsingErrorMsg
        case BOErrorCodes.boManifestSyncError:
            errorDesc = BOManifestSyncErrorMsg
        case BOErrorCodes.boErrorUnknownn:
            fallthrough
        default:
            errorDesc = BOUnknownErrorMsg
        }
        
        return errorDesc
    }
}
