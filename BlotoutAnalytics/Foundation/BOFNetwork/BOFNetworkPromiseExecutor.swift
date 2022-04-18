//
//  BOFNetworkPromiseExecutor.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 11/04/22.
//

import Foundation


let kNSURLNetworkConfigurationIdentifier = "BOFNetworkUrlSessionConfigurationIdentifier"
let kNSURLNetworkConfigurationIdentifierForCampaign = "BOFNetworkUrlSessionConfigurationIdentifierForCampaign"

private let sBOFSharedInstance: Any? = nil
//VAST specific session shared instance
private let sBOFSharedInstanceForCampaign: Any? = nil

class BOFNetworkPromiseExecutor:NSObject {
    
    var isNetworkSyncEnabled = false
    var isSDKEnabled = false
    weak var delegate: BOFNetworkPromiseExecutorDeleagte?
    
    var session: URLSession?
    var taskPromiseObjectMap: NSMapTable<AnyObject, AnyObject>?
    static let sharedInstance = BOFNetworkPromiseExecutor()
    
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
    
    class func sharedInstanceForCampaign() -> Self {
        do{
            // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
            { [self] in
                sBOFSharedInstanceForCampaign = self.init(backgroundIdentifier: kNSURLNetworkConfigurationIdentifierForCampaign)
            }
            
            return sBOFSharedInstanceForCampaign
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    func executorConfiguration() {
        do{
            
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.allowsCellularAccess = true
            session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
            taskPromiseObjectMap?.removeAllObjects()
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    
    func executorConfiguration(withBackgroundIdentifier identifier: String?) {
        do{
            let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: identifier ?? "")
            sessionConfiguration.allowsCellularAccess = true
            session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
            taskPromiseObjectMap?.removeAllObjects()
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    deinit {
        do{
            NotificationCenter.default.removeObserver(self, name: Notification.Name(BOFNetworkPromiseDidCompleteExecution), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name(BOFNetworkPromiseCreatedNewTask), object: nil)
            session?.invalidateAndCancel()
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func sessionTaskDidComplete(_ notificationObj: Notification?) {
        do{
            taskPromiseObjectMap?.removeObject(forKey: notificationObj?.object)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func sessionTaskDidCreate(_ notificationObj: Notification?) {
        do{
            let sessionTask = notificationObj?.object as? URLSessionTask
            let networkPromise = notificationObj?.userInfo?["BOFNetworkPromiseObject"] as? BOFNetworkPromise
            if sessionTask != nil && networkPromise != nil {
                taskPromiseObjectMap[sessionTask] = networkPromise
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    override init?() {
        do{
            super.init()
            taskPromiseObjectMap = NSMapTable.strongToStrongObjects()
            executorConfiguration()
            NotificationCenter.default.addObserver(self, selector: Selector("sessionTaskDidComplete:"), name: Notification.Name(BOFNetworkPromiseDidCompleteExecution), object: nil)
            NotificationCenter.default.addObserver(self, selector: Selector("sessionTaskDidCreate:"), name: Notification.Name(BOFNetworkPromiseCreatedNewTask), object: nil)
            isSDKEnabled = true
            isNetworkSyncEnabled = true
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    init(backgroundIdentifier identifier: String?) {
        do{
            super.init()
            taskPromiseObjectMap = NSMapTable.strongToStrongObjects()
            if identifier != nil && ((identifier?.count ?? 0) > 0) {
                executorConfiguration(withBackgroundIdentifier: identifier)
            } else {
                executorConfiguration()
            }
            NotificationCenter.default.addObserver(self, selector: Selector("sessionTaskDidComplete:"), name: Notification.Name(BOFNetworkPromiseDidCompleteExecution), object: nil)
            NotificationCenter.default.addObserver(self, selector: Selector("sessionTaskDidCreate:"), name: Notification.Name(BOFNetworkPromiseCreatedNewTask), object: nil)
            isSDKEnabled = true
            isNetworkSyncEnabled = true
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    
    func execute(_ networkPromise: BOFNetworkPromise) {
        do{
            if isNetworkSyncEnabled && isSDKEnabled {
                let sessionTask = networkPromise.start(with: session)
                if sessionTask != nil && networkPromise {
                    taskPromiseObjectMap?[sessionTask] = networkPromise
                }
            } else {
                BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do{
            taskPromiseObjectMap[downloadTask]?.bofurlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        do{
            taskPromiseObjectMap[task]?.bofurlSession(session, task: task, didCompleteWithError: error)
            taskPromiseObjectMap.removeValue(forKey: task)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        do{
            taskPromiseObjectMap[dataTask]?.bofurlSession(session, dataTask: dataTask, didReceive: data)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        do{
            taskPromiseObjectMap[downloadTask]?.bofurlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        do{
            taskPromiseObjectMap[downloadTask]?.bofurlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        do{
            if delegate.responds(to: Selector("BOFNetworkPromiseExecutor:didBecomeInvalidWithError:")) {
                delegate.bofNetworkPromiseExecutor(self, didBecomeInvalidWithError: error)
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
}
