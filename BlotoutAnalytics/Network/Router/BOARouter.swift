//
//  BOARouter.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 04/05/22.
//

import Foundation
enum BOARouter {
    
    case getManifest
    //case getProductIds
    //case getProductInfo

    var scheme: String {
        switch self {
        case .getManifest://, .getProductIds, .getProductInfo:
            return "https"
        }
    }

    
    func getBaseServerUrl() -> String {
        return BlotoutAnalytics.sharedInstance.endPointUrl ?? ""
    }
    
    var host: String {
        switch self {
        case .getManifest://, .getProductIds, .getProductInfo:
            return getBaseServerUrl()//"shopicruit.myshopify.com"
        }
    }

    var path: String {
        switch self {
        case .getManifest:
            return "/sdk/v1/manifest/pull" //TODO: update this later to include "/" BO_SDK_REST_API_MANIFEST_PULL_PATH
            

      /*  case .getProductIds:
            return "/admin/collects.json"
        case .getProductInfo:
            return "/admin/products.json"*/
        }
    }

    var parameters: [URLQueryItem] {
        let token = BlotoutAnalytics.sharedInstance.token ?? ""
        switch self {
        case .getManifest:
            return [
                URLQueryItem(name: "token", value: token)]
       /* case .getProductIds:
            return [URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "collection_id", value: "68424466488"),
                URLQueryItem(name: "access_token", value: accessToken)]
        case .getProductInfo:
            return [URLQueryItem(name: "ids", value: "2759162243,2759143811"),
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "access_token", value: accessToken)]*/
        }
    }

    var method: String {
        switch self {
        case .getManifest://, .getProductIds, .getProductInfo:
            return "POST"
        }
    }
    
    //add this in request
    var headerFields:[String : String]{
        switch self {
        case .getManifest://, .getProductIds, .getProductInfo:
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
        }
        
        let token = BlotoutAnalytics.sharedInstance.token ?? ""
        return "\(url)?token=\(token)"
        
    }
    
}
