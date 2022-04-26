//
//  BOFNetworkPromiseExecutor.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 11/04/22.
//

import Foundation




private let sBOFSharedInstance: Any? = nil
//VAST specific session shared instance
private var sBOFSharedInstanceForCampaign: Any? = nil

protocol BOFNetworkPromiseExecutorDelegate: NSObjectProtocol {
    func bofNetworkPromiseExecutor(_ networkPromiseExecutor: BOFNetworkPromiseExecutor, didBecomeInvalidWithError error: Error?)
}

class BOFNetworkPromiseExecutor:NSObject, URLSessionDelegate {
    
    let kNSURLNetworkConfigurationIdentifier = "BOFNetworkUrlSessionConfigurationIdentifier"
    let kNSURLNetworkConfigurationIdentifierForCampaign = "BOFNetworkUrlSessionConfigurationIdentifierForCampaign"
    
    var isNetworkSyncEnabled = false
    var isSDKEnabled = false
    weak var delegate: BOFNetworkPromiseExecutorDelegate?
    
    var session: URLSession?
    var taskPromiseObjectMap : NSMutableDictionary?
    static let sharedInstance = BOFNetworkPromiseExecutor()
    //TODO: need to confirm this
    lazy var sharedInstanceForCampaign = BOFNetworkPromiseExecutor(backgroundIdentifier: kNSURLNetworkConfigurationIdentifierForCampaign)
    
    //    class func sharedInstance() -> Self {
    //        // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
    //        SwiftTryCatch.try({
    //            // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
    //            { [self] in
    //                sBOFSharedInstance = self.init()
    //            }
    //
    //            return sBOFSharedInstance
    //        } catch {
    //            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
    //        })
    //        return nil
    //    }
    
    //
    //    let sharedInstanceForCampaign:() = {
    //        sBOFSharedInstanceForCampaign = init(backgroundIdentifier: kNSURLNetworkConfigurationIdentifierForCampaign)}()
    //  //  var _ = sharedInstanceForCampaign
    
    
    func executorConfiguration() {
        let sessionConfiguration =  URLSessionConfiguration.default
        sessionConfiguration.allowsCellularAccess = true
        session =  URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        taskPromiseObjectMap?.removeAllObjects()
    }
    
    
    func executorConfiguration(withBackgroundIdentifier identifier: String) {
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: identifier )
        sessionConfiguration.allowsCellularAccess = true
        session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        taskPromiseObjectMap?.removeAllObjects()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(BOFNetworkPromiseDidCompleteExecution), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(BOFNetworkPromiseCreatedNewTask), object: nil)
        session?.invalidateAndCancel()
    }
    
    @objc func sessionTaskDidComplete(_ notificationObj: Notification) {
        taskPromiseObjectMap?.removeObject(forKey: notificationObj.object as Any)
    }
    
    @objc func sessionTaskDidCreate(_ notificationObj: Notification) {
        
        let sessionTask = notificationObj.object as? URLSessionTask
        let networkPromise = notificationObj.userInfo?["BOFNetworkPromiseObject"] as? BOFNetworkPromise
        if sessionTask != nil && networkPromise != nil {
            taskPromiseObjectMap?[sessionTask] = networkPromise
        }
    }
    
    override init() {
        
        super.init()
        taskPromiseObjectMap = NSMutableDictionary()
        executorConfiguration()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionTaskDidComplete(_:)), name: Notification.Name(BOFNetworkPromiseDidCompleteExecution), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionTaskDidCreate(_:)), name: Notification.Name(BOFNetworkPromiseDidCompleteExecution), object: nil)
        
        isSDKEnabled = true
        isNetworkSyncEnabled = true
    }
    
    init?(backgroundIdentifier identifier: String?) {
        
        super.init()
        taskPromiseObjectMap = NSMutableDictionary()
        if identifier != nil && ((identifier?.count ?? 0) > 0) {
            executorConfiguration(withBackgroundIdentifier: identifier!)
        } else {
            executorConfiguration()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionTaskDidComplete(_:)), name: Notification.Name(BOFNetworkPromiseDidCompleteExecution), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionTaskDidCreate(_:)), name: Notification.Name(BOFNetworkPromiseDidCompleteExecution), object: nil)
        
        isSDKEnabled = true
        isNetworkSyncEnabled = true
        return nil
    }
    
    
    //TODO:fix this method
    func execute(_ networkPromise: BOFNetworkPromise) {
        
        if isNetworkSyncEnabled && isSDKEnabled {
            let sessionTask = networkPromise.start(with: session)
            if sessionTask != nil && networkPromise != nil {
                taskPromiseObjectMap?[sessionTask] = networkPromise
            }
        }
        //            else {
        //                BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        //            }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //TODO: need to verify this change
        if let promiseExecutor = taskPromiseObjectMap?[downloadTask]
        {
            (promiseExecutor as! BOFNetworkPromise).bofurlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        //TODO: need to verify this change
        if let promiseExecutor = taskPromiseObjectMap?[task]{
            (promiseExecutor as! BOFNetworkPromise).bofurlSession(session, task: task, didCompleteWithError: error)
            taskPromiseObjectMap?.removeObject(forKey: task)
        }
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data ) //TODO: need to verify this change
    {
        if let promiseExecutor = taskPromiseObjectMap?[dataTask]{
            (promiseExecutor as! BOFNetworkPromise).bofurlSession(session, dataTask: dataTask, didReceive: data)
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //TODO: need to verify this change
        if let promiseExecutor = taskPromiseObjectMap?[downloadTask]
        {
            (promiseExecutor as! BOFNetworkPromise).bofurlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
        if let promiseExecutor = taskPromiseObjectMap?[downloadTask]
        {
            (promiseExecutor as! BOFNetworkPromise).bofurlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
        }
    }
    
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
         self.delegate?.bofNetworkPromiseExecutor(self, didBecomeInvalidWithError: error)
        
    }
}
