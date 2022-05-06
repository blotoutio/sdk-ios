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
    
    //newly added
    var manifestModel:ManifestModel?
    
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
            
            //TODO: have removed model null & refill scenario, add again if needed

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
        
        api.getManifestModel { responseObject in
            
            if (responseObject == nil) {
                self.isSyncedNow = false
                callback(false, nil)
                return
            }
            
            self.manifestModel = responseObject
            
            //TODO: change the storage methods used here
            
            do{
                let manifestData = try JSONEncoder().encode(responseObject)
                let manifestJSONStr = String(data: manifestData , encoding: .utf8)
                self.sdkManifestPath(afterWriting: manifestJSONStr ?? "")
                self.isSyncedNow = true
                callback(true, nil)
            }
            catch
            {
                self.isSyncedNow = false
                callback(false, error)
            }
            
            
        } failure: { error in
            self.isSyncedNow = false
            callback(false, error)
        }

    }
    
    
    func getManifestVariableModel(manifest:ManifestModel,  forID: Int)-> ManifestVariableModel?
    {
        //TODO:test this
        if let match = manifest.variables.first( where: { forID == Int($0.variableId)} ) {
            return match
        }
        return nil
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
           
           if manifestModel == nil {
               return
           }
           
           //TODO: remove this code later, looks unreachable
//           if manifestModel == nil && (manifestStr != ""){
//
//               let sdkManifestM = try BOASDKManifest.fromJSON(json: manifestStr, encoding: String.Encoding.utf8, error: manifestReadError)
//               manifestModel = sdkManifestM
//           }
           
           let systemEvents = getManifestVariableModel(manifest: manifestModel!, forID: MANIFEST_SYSTEM_EVENTS)
           if let systemEvents = systemEvents {
               enabledSystemEvents = systemEvents.value.components(separatedBy: ",")
           }

           /*
            let piiKey = getManifestVariable(sdkManifestModel!, forID: MANIFEST_PII_PUBLIC_KEY)
            if let piiKey = piiKey {
                piiPublicKey = piiKey.value
            }
            
            let phiKey = getManifestVariable(sdkManifestModel!, forID: MANIFEST_PHI_PUBLIC_KEY)
            if let phiKey = phiKey {
                phiPublickey = phiKey.value
            }
            */
            
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
