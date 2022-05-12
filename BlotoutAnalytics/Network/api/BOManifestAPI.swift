//
//  BOManifestAPI.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation


class BOManifestAPI:NSObject {
    
    
    func getManifestModel(_ success: @escaping (_ responseObject: ManifestModel?) -> Void, failure: @escaping (_ error: Error?) -> Void)
    {
        ServiceLayer.requestToGetModel(router: BOARouter.getManifest, body: nil) { (result: Result<ManifestModel?, Error>) in
            switch result {
            case .success(let manifestModel):
                success(manifestModel)
                print(result)
            case .failure(let manifestError):
                failure(manifestError)
                print(result)
            }
        }
    }
}
