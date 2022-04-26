//
//  BOASDKManifestController.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 23/03/22.
//

import Foundation

private var sBOAsdkManifestSharedInstance: Any? = nil

class BOASDKManifestController:NSObject {
    
    var sdkManifestModel: BOASDKManifest?
    var isSyncedNow = false
    var piiPublicKey: String?
    var phiPublickey: String?
    var enabledSystemEvents: [AnyHashable]?
    
    static let sharedInstance = BOASDKManifestController()
    override init() {
        super.init()
    }
    
//    class func sharedInstance() -> Self {
//        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
//        { [self] in
//            sBOAsdkManifestSharedInstance = self.init()
//        }
//        return sBOAsdkManifestSharedInstance as! Self
//    }
    
    func serverSyncManifestAndAppVerification(_ callback: ((_ isSuccess: Bool, _ error: Error?) -> Void)) {
        do{
            fetchAndPrepareSDKModel(with: { [self] isSuccess, error in
                if isSuccess {
                    reloadManifestData()
                }
                if (sdkManifestModel == nil) {
                    var manifestReadError: Error? = nil
                    let sdkManifestM = BOASDKManifest.fromJSON(json: latestSDKManifestJSONString(), encoding: String.Encoding.utf8, error: &manifestReadError)
                }
                callback(isSuccess,error)
            })} catch {
                BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
                
                if let errorString = (error as? NSError)?.userInfo
                {
                    callback(false, BOErrorAdditions.boError(forDict: errorString))
                }
                else
                {
                    callback(false, BOErrorAdditions.boError(forDict: ""))
                }
            }
        }
    
    
    func latestSDKManifestPath() -> String? {
        
        let fileName = "sdkManifest"
        let sdkManifestDir = BOFFileSystemManager.getSDKManifestDirectoryPath()
        let sdkManifestFilePath = "\(sdkManifestDir ?? "")/\(fileName).txt"
        return sdkManifestFilePath
    }
    
    func latestSDKManifestJSONString() -> String? {
       do{
            let sdkManifestFilePath = latestSDKManifestPath()
            var fileReadError: Error?
            let sdkManifestStr = BOFFileSystemManager.contentOfFile(atPath: sdkManifestFilePath, with: String.Encoding.utf8, andError: &fileReadError)
            return sdkManifestStr
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    func sdkManifestPath(afterWriting sdkManifest: String) -> String? {
       do{
            if sdkManifest == nil || (sdkManifest == "") || (sdkManifest == "{}") || (sdkManifest == "{ }") {
                return nil
            }
            
            let sdkManifestFilePath = latestSDKManifestPath()
           if BOFFileSystemManager.isFileExist(atPath: sdkManifestFilePath ?? "") {
                var removeError: Error? = nil
               BOFFileSystemManager.removeFile(fromLocationPath: sdkManifestFilePath ?? "", removalError: removeError)
            }
            var error: Error?
            //else file write operation and prapare new object
            BOFFileSystemManager.path(afterWriting: sdkManifest, toFilePath: sdkManifestFilePath, writingError: &error)
            
            return sdkManifestFilePath
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    func fetchAndPrepareSDKModel(with callback: ((_ isSuccess: Bool, _ error: Error?) -> Void)) {
        do{
            let api = BOManifestAPI()
            
            api.getManifestDataModel({ [self] responseObject, data in
                if (responseObject == nil) {
                    isSyncedNow = false
                    callback(false, nil)
                    return
                }
                let sdkManifestM = responseObject as? BOASDKManifest
                sdkManifestModel = sdkManifestM
                let manifestJSONStr = String(data: data as! Data, encoding: .utf8)
                sdkManifestPath(afterWriting: manifestJSONStr ?? "")
                isSyncedNow = true
                callback(true, nil)
            }, failure: { [self] error in
                isSyncedNow = false
                callback(false, error)
            })} catch {
                BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
                callback(false, BOErrorAdditions.boError(forDict: exception.userInfo))
            }
            
        }
    
    func getManifestVariable(_ manifest: BOASDKManifest, forID ID: Int) -> BOASDKVariable? {
            var oneVar: BOASDKVariable? = nil
            if let variables = manifest.variables {
                for oneVariableDict in variables {
                    guard let oneVariableDict = oneVariableDict as? BOASDKVariable else {
                        continue
                    }
                    if oneVariableDict != nil && oneVariableDict.variableID?.intValue == ID {
                        oneVar = oneVariableDict
                        break
                    }
                }
            }
            return oneVar
    }
    
    func reloadManifestData() {
       do{
            let manifestStr = latestSDKManifestJSONString()
            if manifestStr == nil {
                return
            }
            if sdkManifestModel == nil && manifestStr != nil && (manifestStr != "") {
                var manifestReadError: Error? = nil
                let sdkManifestM = BOASDKManifest.fromJSON(json: manifestStr, encoding: String.Encoding.utf8, error: &manifestReadError)
                sdkManifestModel = sdkManifestM
            }

            if sdkManifestModel == nil {
                return
            }
            let systemEvents = getManifestVariable(sdkManifestModel!, forID: MANIFEST_SYSTEM_EVENTS)
            if let systemEvents = systemEvents {
                enabledSystemEvents = systemEvents.value?.components(separatedBy: ",")
            }

            let piiKey = getManifestVariable(sdkManifestModel!, forID: MANIFEST_PII_PUBLIC_KEY)
            if let piiKey = piiKey {
                piiPublicKey = piiKey.value
            }
            
            let phiKey = getManifestVariable(sdkManifestModel!, forID: MANIFEST_PHI_PUBLIC_KEY)
            if let phiKey = phiKey {
                phiPublickey = phiKey.value
            }
            
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func isManifestAvailable() -> Bool {

            let manifestStr = latestSDKManifestJSONString()
            if manifestStr != nil && (manifestStr != "") {
                return true
            }
            return false
    }
    
    func isSystemEventEnabled(_ eventCode: Int) -> Bool {
        if enabledSystemEvents == nil {
            return false
        }
        return ((enabledSystemEvents?.contains(NSNumber(value: eventCode).stringValue)) != nil)
    }
    
}
