//
//  BOFNetworkPromise.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 13/04/22.
//

import Foundation

let BOFNetworkPromiseDidCompleteExecution = "BOFNetworkPromiseDidCompleteExecution"
let BOFNetworkPromiseCreatedNewTask = "BOFNetworkPromiseCreatedNewTask"
let BOFNetworkPromiseTaskPriorityDefault: Float = 0.5
let BOFNetworkPromiseTaskPriorityLow: Float = 0.0
let BOFNetworkPromiseTaskPriorityHigh: Float = 1.0


class BOFNetworkPromise:NSObject {
    private var responseData: Data?
    convenience init() {
        return nil
    }
            convenience init(urlRequest request: URLRequest?, completionHandler networkPromiseCompletionHandler: BOFNetworkPromiseCompletionHandler) {
                // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
                SwiftTryCatch.try({
                    if request == nil {
                        return nil
                    }

                    super.init()
                    urlRequest = request
                    completionHandler = networkPromiseCompletionHandler
                    customInitialization()
                } catch { 
                    BOFLogDebug("%@:%@", BOF_DEBUG, exception)
                })
                return nil
            }
     
            convenience init(resumeData resumedData: Data?, completionHandler networkPromiseCompletionHandler: BOFNetworkPromiseCompletionHandler) {
                // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
                SwiftTryCatch.try({
                    if resumedData == nil {
                        return nil
                    }

                    super.init()
                    resumeData = resumedData
                    completionHandler = networkPromiseCompletionHandler
                    customInitialization()
                } catch { 
                    BOFLogDebug("%@:%@", BOF_DEBUG, exception)
                })
                return nil
            }
convenience init?(urlRequest request: URLRequest, responseHandler networkResponseHandler: BOFNetworkPromiseDeleagte) {
                // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
                SwiftTryCatch.try({
                    if request == nil {
                        return nil
                    }

                    super.init()
                    urlRequest = request
                    delegateForHandler = networkResponseHandler
                    urlRequest = request
                    delegateForHandler = networkResponseHandler
                    customInitialization()
                } catch { 
                    BOFLogDebug("%@:%@", BOF_DEBUG, exception)
                })
                return nil
            }
    
    func customInitialization() {
        do{
            numberOfRetries = 0
            totalAttempts = 0
            retryDelay = 20.0
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func postNotificationForTaskCompletion() {
        do{
            NotificationCenter.default.post(name: BOFNetworkPromiseDidCompleteExecution, object: anySessionTask, userInfo: [
                "Description": "NetworkPromise object completed execution using completion handler."
            ])
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func postNotificationForNewTaskCreation() {
        do{
            NotificationCenter.default.post(
                name: BOFNetworkPromiseCreatedNewTask,
                object: anySessionTask,
                userInfo: [
                    "Description": "NetworkPromise locobject created new task using retry controls.",
                    "BOFNetworkPromiseObject": self
                ])
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func doNecessaryCallbackInvocation(onCompletion dataOrLocation: Any?, response: URLResponse?, error: Error?) {
        do{
            
            if completionHandler != nil {
                completionHandler(response, dataOrLocation, error)
            } else {
                if delegate && delegate.responds(to: Selector("BOFNetworkPromise:didCompleteWithError:")) {
                    delegate.bofNetworkPromise(self, didCompleteWithError: error)
                }
            }
            if delegateForHandler && delegateForHandler.responds(to: Selector("BOFNetworkPromise:didCompleteWithError:")) {
                delegateForHandler.bofNetworkPromise(self, didCompleteWithError: error)
            }
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    
    func sessionTaskComplettionHandlerDownloaded(_ dataOrLocation: Any?, response: URLResponse?, error: Error?, session: URLSession?) {
        do{
            postNotificationForTaskCompletion()
            DispatchQueue.main.async(execute: {
                //shoould retry
                let httpResponse = response as? HTTPURLResponse
                
                if (error != nil && (error as NSError).code >= 500) || (httpResponse.statusCode >= 500) {
                    if totalAttempts < numberOfRetries {
                        totalAttempts += 1
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(retryDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [self] in
                            start(withSession: session)
                            postNotificationForNewTaskCreation()
                        })
                    }
                    else {
                            doNecessaryCallbackInvocation(onCompletion: dataOrLocation, response: response, error: error)
                        }
                }
                else {
                        doNecessaryCallbackInvocation(onCompletion: dataOrLocation, response: response, error: error)
                    }

            })
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    
    func getAsyncDownloadUrlSessionTask(_ session: URLSession?) -> URLSessionTask? {
        do{
            let anySessionTask: URLSessionTask? = nil
            
            if resumeData != nil {
                if let resumeData = resumeData {
                    anySessionTask = session.downloadTask(withResumeData: resumeData) { [self] location, response, error in
                        sessionTaskComplettionHandlerDownloaded(location, response: response, error: error, session: session)
                    }
                }
            }
            else if urlRequest {
                anySessionTask = session.downloadTask(with: urlRequest) { [self] location, response, error in
                    sessionTaskComplettionHandlerDownloaded(location, response: response, error: error, session: session)
                }
            }
            return anySessionTask
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    func getAsyncUrlSessionTask(_ session: URLSession?) -> URLSessionTask? {
        do{
            let anySessionTask: URLSessionTask? = nil
            if downloadAsFile || resumeData != nil {
                anySessionTask = getAsyncDownloadUrlSessionTask(session)
            } else if urlRequest {
                anySessionTask = session.dataTask(with: urlRequest) { [self] data, response, error in
                    sessionTaskComplettionHandlerDownloaded(data, response: response, error: error, session: session)
                }
            }
            return anySessionTask
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    func getSyncUrlSessionTask(_ session: URLSession?) -> URLSessionTask? {
        do{
            let anySessionTask: URLSessionTask? = nil
            if downloadAsFile || resumeData != nil {
                if resumeData != nil {
                    if let resumeData = resumeData {
                        anySessionTask = session.downloadTask(withResumeData: resumeData)
                    }
                } else if urlRequest {
                    anySessionTask = session.downloadTask(with: urlRequest)
                }
            } else if urlRequest {
                anySessionTask = session.dataTask(with: urlRequest)
            }
            return anySessionTask
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    func start(with session: URLSession?) -> URLSessionTask? {
        do{
            if completionHandler != nil && session != nil {
                anySessionTask = getSyncUrlSessionTask(session)
            } else if let session = session {
                anySessionTask = getSyncUrlSessionTask(session)
            }
            if (!session || !anySessionTask) && completionHandler != nil {
                completionHandler(nil, nil, NSError(domain: kBOFNetworkPromiseDefaultErrorDomain, code: kBOFNetworkPromiseDefaultErrorCode, userInfo: kBOFNetworkPromiseDefaultErrorUserInfo))
            }

            anySessionTask.taskDescription = networkPromiseDescription
            if NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0 {
                anySessionTask.priority = priority
            }
            anySessionTask.resume()
            return anySessionTask
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    func networkPromiseIdentifier() -> Int {
        do{
            return anySessionTask.taskIdentifier
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return 0
    }
    
    func setNetworkPromiseDescription(_ networkPromiseDescription: String?) {
        do{
            self.networkPromiseDescription = networkPromiseDescription
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    func networkPromiseDescription() -> String? {
        do{
            return anySessionTask.taskDescription ?? networkPromiseDescription
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    var originalRequest: URLRequest {
        do{
            return anySessionTask.originalRequest
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    var currentRequest: URLRequest {
        do{
            return anySessionTask.currentRequest
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    func response() -> URLResponse? {
        do{
            return anySessionTask.response()
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    func state() -> BOFNetworkPromiseTaskState {
        do{
            var currentState: BOFNetworkPromiseTaskState
            if !anySessionTask {
                currentState = BOFNetworkPromiseTaskStateSuspended
            }
            else
            {
                switch anySessionTask.state {
                case URLSessionTask.State.running:
                    currentState = BOFNetworkPromiseTaskStateRunning
                case URLSessionTask.State.suspended:
                    currentState = BOFNetworkPromiseTaskStateSuspended
                case URLSessionTask.State.canceling:
                    currentState = BOFNetworkPromiseTaskStateCanceling
                case URLSessionTask.State.completed:
                    currentState = BOFNetworkPromiseTaskStateCompleted
                default:
                    break
                }
            }
            return currentState
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return BOFNetworkPromiseTaskStateSuspended
    }
    func error() -> Error? {
        do{
            return anySessionTask.error()
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    func setPriority(_ priority: Float) {
        do{
            self.priority = priority
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    -(float)priority {
      @try {
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
          return _anySessionTask.priority;
        }
        return _priority;  // should be same as _priority
      } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
      }
      return NSURLSessionTaskPriorityDefault;
    }
    
    func cancel() {
        do{
            anySessionTask.cancel()
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func suspend() {
        do{
            anySessionTask.suspend()
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func resume() {
        do{
            anySessionTask.resume()
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func cancel(byProducingResumeData completionHandler: @escaping (Data?) -> Void) {
        do{
            if anySessionTask is URLSessionDownloadTask {
                (anySessionTask as? URLSessionDownloadTask)?.cancel(byProducingResumeData: { resumeData in
                    completionHandler(resumeData)
                })
            }
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func bofurlSession(_ session: URLSession?, downloadTask: URLSessionDownloadTask?, didFinishDownloadingTo location: URL?) {
        do{

            if downloadLocation {
                var relocationError: Error? = nil
                let success = BOFFileSystemManager.moveFile(fromLocation: location, toLocation: downloadLocation, relocationError: &relocationError)
                relocationErr = relocationError
                if success {
                    location = downloadLocation
                }
            } else {
                downloadLocation = location
            }
            if delegate.responds(to: Selector("BOFNetworkPromise:didFinishDownloadingToURL:")) {
                delegate.bofNetworkPromise(self, didFinishDownloadingToURL: location)
            }
            if delegateForHandler.responds(to: Selector("BOFNetworkPromise:didFinishDownloadingToURL:")) {
                delegateForHandler.bofNetworkPromise(self, didFinishDownloadingTo: location)
            }
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func bofurlSession(_ session: URLSession?, task: URLSessionTask?, didCompleteWithError error: Error?) {
        do{
            let dataOrLocation = responseData ?? downloadLocation
            sessionTaskComplettionHandlerDownloaded(dataOrLocation, response: task?.response, error: error, session: session)
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func bofurlSession(_ session: URLSession?, downloadTask: URLSessionDownloadTask?, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        do{
            
            if delegate.responds(to: Selector("BOFNetworkPromise:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:")) {
                delegate.bofNetworkPromise(self, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            }

            if delegateForHandler.responds(to: Selector("BOFNetworkPromise:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:")) {
                delegateForHandler.bofNetworkPromise(self, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            }
            
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func bofurlSession(_ session: URLSession?, downloadTask: URLSessionDownloadTask?, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        do{
            
            if delegate.responds(to: Selector("BOFNetworkPromise:didResumeAtOffset:expectedTotalBytes:")) {
                delegate.bofNetworkPromise(self, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
            }

            if delegateForHandler.responds(to: Selector("BOFNetworkPromise:didResumeAtOffset:expectedTotalBytes:")) {
                delegateForHandler.bofNetworkPromise(self, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
            }
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func bofurlSession(
        _ session: URLSession?,
        dataTask: URLSessionDataTask?,
        didReceive data: Data?
    ) {
        do{
            if responseData == nil {
                responseData = Data()
            }

            responseData.append(data)

            if delegate.responds(to: Selector("BOFNetworkPromise:didReceiveData:")) {
                delegate.bofNetworkPromise(self, didReceiveData: data)
            }

            if delegateForHandler.responds(to: Selector("BOFNetworkPromise:didReceiveData:")) {
                delegateForHandler.bofNetworkPromise(self, didReceiveData: data)
            }
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    deinit {
        do{
            delegate = nil
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
}
