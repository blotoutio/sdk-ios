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
    
    func serverSyncManifestAndAppVerification(_ callback:@escaping ((_ isSuccess: Bool, _ error: Error?) -> Void)) {
        
        fetchAndPrepareSDKModel() { isSuccess, error in
            
            if isSuccess {
                self.reloadManifestData()
            }
            if (self.sdkManifestModel == nil) {
                var manifestReadError: Error? = nil
                var sdkManifestM:BOASDKManifest? = nil
                
                do{
                    sdkManifestM = try BOASDKManifest.fromJSON(json: self.latestSDKManifestJSONString(), encoding: String.Encoding.utf8, error: manifestReadError)
                    self.sdkManifestModel = sdkManifestM
                }
                catch
                {
                    BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
                    
                    if let errorString = (error as? NSError)?.userInfo
                    {
                        callback(false, BOErrorAdditions.boError(forDict: errorString))
                    }
                    else
                    {
                        callback(false, BOErrorAdditions.boError(forDict:[:]))
                    }
                }
            }
            callback(isSuccess,error)
        }
    }
    
    
    func latestSDKManifestPath() -> String {
        
        let fileName = "sdkManifest"
        let sdkManifestDir = BOFFileSystemManager.getSDKManifestDirectoryPath()
        let sdkManifestFilePath = "\(sdkManifestDir ?? "")/\(fileName).txt"
        return sdkManifestFilePath
    }
    
    func latestSDKManifestJSONString() -> String? {
       do{
            let sdkManifestFilePath = latestSDKManifestPath()
            var fileReadError: Error?
           let sdkManifestStr = try BOFFileSystemManager.contentOfFile(atPath: sdkManifestFilePath, with: String.Encoding.utf8)//, andError: &fileReadError)
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
           
           try BOFFileSystemManager.pathAfterWriting(contentString: sdkManifest, toFilePath: sdkManifestFilePath)//, writingError: &error)
          //  BOFFileSystemManager.path(afterWriting: sdkManifest, toFilePath: sdkManifestFilePath, writingError: &error)
            
            return sdkManifestFilePath
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    func fetchAndPrepareSDKModel(with callback: @escaping ((_ isSuccess: Bool, _ error: Error?) -> Void)) {
        
        let api = BOManifestAPI()
        
        api.getManifestDataModel { responseObject, data in
            
            if (responseObject == nil) {
                self.isSyncedNow = false
                callback(false, nil)
                return
            }
            let sdkManifestM = responseObject as? BOASDKManifest
            self.sdkManifestModel = sdkManifestM
            let manifestJSONStr = String(data: data as! Data, encoding: .utf8)
            self.sdkManifestPath(afterWriting: manifestJSONStr ?? "")
            self.isSyncedNow = true
            callback(true, nil)
            
        } failure: { error in
            self.isSyncedNow = false
            callback(false, error)
        }
    }
    
    func getManifestVariable(_ manifest: BOASDKManifest, forID ID: Int) -> BOASDKVariable? {
            var oneVar: BOASDKVariable? = nil
            if let variables = manifest.variables {
                for oneVariableDict in variables {
//                    guard let oneVariableDict = oneVariableDict else {
//                        continue
//                    }
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
                let sdkManifestM = try BOASDKManifest.fromJSON(json: manifestStr, encoding: String.Encoding.utf8, error: manifestReadError)
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
