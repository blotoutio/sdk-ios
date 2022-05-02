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

typealias BOFNetworkPromiseCompletionHandler = (URLResponse?, Any?, Error?) -> Void

class BOFNetworkPromise:NSObject {
    
    enum BOFNetworkPromiseTaskState : Int {
        case running = 0
        case suspended = 1
        case canceling = 2
        case completed = 3
    }
    
    
    var delegateForHandler: BOFNetworkPromiseDeleagte?
    var totalAttempts = 0
    var urlRequest: URLRequest?
    var resumeData: Data?
    var completionHandler: BOFNetworkPromiseCompletionHandler?
    var retryDelay: TimeInterval = 0.0
    var anySessionTask: URLSessionTask?
    
    var downloadLocation: URL?
    var relocationErr: Error?
    
    var delegate: BOFNetworkPromiseDeleagte?
    var numberOfRetries = 0
    var downloadAsFile = false //default download will try to download as NSData, like data task.
    // var networkPromiseDescription: String?
    //  private(set) var networkPromiseIdentifier = 0
    // private(set) var originalRequest: URLRequest?
    // private(set) var currentRequest: URLRequest?
    
    // private(set) var response: URLResponse?
    private(set) var responseData: Data?
   // private(set) var state: BOFNetworkPromiseTaskState?
    private(set) var error: Error?
    var priority:Float
    var networkPromiseDescription: String?
    @available(macOS 10.10, iOS 8.0, *)
   // var priority: Float = 0.0
    
    //    convenience init?() {
    //        return nil
    //    }
    
    //TODO: correct these init methods
    init?(urlRequest request: URLRequest?, completionHandler networkPromiseCompletionHandler: @escaping BOFNetworkPromiseCompletionHandler) {
        if request == nil {
            return nil
        }
        priority = URLSessionTask.defaultPriority
        super.init()
        urlRequest = request
        completionHandler = networkPromiseCompletionHandler
        customInitialization()
       
    }
    
    //TODO:not being used, maybe remove
    init(resumeData resumedData: Data, completionHandler networkPromiseCompletionHandler: @escaping BOFNetworkPromiseCompletionHandler) {
//        if resumedData == nil {
//            return nil
//        }
//
        priority = URLSessionTask.defaultPriority
        super.init()
        resumeData = resumedData
        completionHandler = networkPromiseCompletionHandler
        customInitialization()
        
    }
    init(urlRequest request: URLRequest, responseHandler networkResponseHandler: BOFNetworkPromiseDeleagte) {
        
//        if request == nil {
//            return nil
//        }
        priority = URLSessionTask.defaultPriority
        super.init()
        urlRequest = request
        delegateForHandler = networkResponseHandler
        urlRequest = request
        delegateForHandler = networkResponseHandler
        customInitialization()
        
    }
    
    func customInitialization() {
        numberOfRetries = 0
        totalAttempts = 0
        retryDelay = 20.0
        
    }
    
    func postNotificationForTaskCompletion() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BOFNetworkPromiseDidCompleteExecution), object: anySessionTask, userInfo: [
            "Description": "NetworkPromise object completed execution using completion handler."
        ])
        
    }
    
    func postNotificationForNewTaskCreation() {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: BOFNetworkPromiseCreatedNewTask),
            object: anySessionTask,
            userInfo: [
                "Description": "NetworkPromise locobject created new task using retry controls.",
                "BOFNetworkPromiseObject": self
            ])
        
    }
    
    func doNecessaryCallbackInvocation(onCompletion dataOrLocation: Any, response: URLResponse?, error: Error) {
        if completionHandler != nil {
            completionHandler!(response, dataOrLocation, error)
        } else {
            
            delegate?.bofNetworkPromise?(self, didCompleteWithError: error)
            
        }
        delegateForHandler?.bofNetworkPromise?(self, didCompleteWithError: error)
        
    }
    
    
    func sessionTaskComplettionHandlerDownloaded(_ dataOrLocation: Any?, response: URLResponse?, error: Error?, session: URLSession?) {
        postNotificationForTaskCompletion()
        DispatchQueue.main.async(execute: { [self] in
            //shoould retry
            let httpResponse = response as? HTTPURLResponse
            
            if (error != nil && (error! as NSError).code >= 500) || (httpResponse?.statusCode ?? 200 >= 500) {
                if totalAttempts < numberOfRetries {
                    self.totalAttempts += 1
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(retryDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [self] in
                        start(with: session)
                        postNotificationForNewTaskCreation()
                    })
                }
                else {
                    doNecessaryCallbackInvocation(onCompletion: dataOrLocation, response: response, error: error as! Error)
                }
            }
            else {
                doNecessaryCallbackInvocation(onCompletion: dataOrLocation, response: response, error: error as! Error)
            }
            
        })
    }
    
    
    func getAsyncDownloadUrlSessionTask(_ session: URLSession?) -> URLSessionTask? {
        var anySessionTask: URLSessionTask? = nil
        
        if resumeData != nil {
            if let resumeData = resumeData {
                self.anySessionTask = session?.downloadTask(withResumeData: resumeData) { [self] location, response, error in
                    sessionTaskComplettionHandlerDownloaded(location, response: response, error: error, session: session)
                } as! URLSessionTask
            }
        }
        else if (urlRequest != nil) {
            anySessionTask = session?.downloadTask(with: urlRequest!) { [self] location, response, error in
                sessionTaskComplettionHandlerDownloaded(location, response: response, error: error, session: session)
            }
        }
        return anySessionTask
    }
    
    func getAsyncUrlSessionTask(_ session: URLSession?) -> URLSessionTask? {
        var anySessionTask: URLSessionTask? = nil
        if downloadAsFile || resumeData != nil {
            anySessionTask = getAsyncDownloadUrlSessionTask(session)
        } else if (urlRequest != nil) {
            anySessionTask = session?.dataTask(with: urlRequest!) { [self] data, response, error in
                sessionTaskComplettionHandlerDownloaded(data, response: response, error: error, session: session)
            }
        }
        return anySessionTask
        
    }
    
    func getSyncUrlSessionTask(_ session: URLSession?) -> URLSessionTask? {
        var anySessionTask: URLSessionTask? = nil
        if downloadAsFile || resumeData != nil {
            if resumeData != nil {
                if let resumeData = resumeData {
                    self.anySessionTask = session?.downloadTask(withResumeData: resumeData) as! URLSessionTask
                }
            } else if (urlRequest != nil) {
                anySessionTask = session?.downloadTask(with: urlRequest!)
            }
        } else if (urlRequest != nil) {
            anySessionTask = session?.dataTask(with: urlRequest!)
        }
        return anySessionTask
        
    }
    
    func start(with session: URLSession?) -> URLSessionTask? {
        if completionHandler != nil && session != nil {
            anySessionTask = getSyncUrlSessionTask(session)!
        } else if let session = session {
            anySessionTask = getSyncUrlSessionTask(session)!
        }
        if ((session == nil) || (anySessionTask == nil)) && completionHandler != nil {
            completionHandler!(nil, nil, NSError(domain: kBOFNetworkPromiseDefaultErrorDomain, code: kBOFNetworkPromiseDefaultErrorCode, userInfo: kBOFNetworkPromiseDefaultErrorUserInfo))
        }
        
        anySessionTask?.taskDescription = networkPromiseDescription
        if NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0 {
            anySessionTask?.priority = priority
        }
        anySessionTask?.resume()
        return anySessionTask
        
    }
    
    func networkPromiseIdentifier() -> Int {
        
        return anySessionTask?.taskIdentifier ?? 0
    }
    
    //TODO: test networkPromiseDescription
    func setNetworkPromiseDescription(_ networkPromiseDescription: String?) {
        
        self.networkPromiseDescription = networkPromiseDescription ?? self.networkPromiseDescription
    }
    var getNetworkPromiseDescription: String? {
        return anySessionTask?.taskDescription ?? networkPromiseDescription
    }
    
    var originalRequest: URLRequest? {
        return anySessionTask?.originalRequest
    }
    
    var currentRequest: URLRequest? {
        return anySessionTask?.currentRequest
        
    }
    
    func response() -> URLResponse? {
        return anySessionTask?.response
    }
    
    func state() -> BOFNetworkPromiseTaskState {
            var currentState: BOFNetworkPromiseTaskState
            if (anySessionTask == nil) {
                currentState = BOFNetworkPromiseTaskState.suspended
            }
            else
            {
                switch anySessionTask?.state {
                case .running:
                    currentState = BOFNetworkPromiseTaskState.running
                case .suspended:
                    currentState = BOFNetworkPromiseTaskState.suspended
                case .canceling:
                    currentState = BOFNetworkPromiseTaskState.canceling
                case .completed:
                    currentState = BOFNetworkPromiseTaskState.completed
                default:
                    currentState = BOFNetworkPromiseTaskState.suspended
                    //TODO: test this
                    break
                }
            }
            return currentState
    }
    //    func error() -> Error? {
    //        do{
    //            return anySessionTask?.error
    //        } catch {
    //            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
    //        }
    //        return nil
    //    }
    
    func setPriority(_ priority: Float) {
        self.priority = priority
    }
    
   /* var priority:Float{
        
        get{
            if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
                return anySessionTask.priority
            }
            return priority
        }
        set(newPriority)
        {
           return priority = newPriority
        }
    }*/
    
    func getPriority()->Float {
      //  do {
            if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
                return anySessionTask?.priority ?? self.priority
            }
        return self.priority  // should be same as _priority
//        } catch  {
//            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
//        }
//        return URLSessionTask.defaultPriority
    }
    
    
    func cancel() {
        anySessionTask?.cancel()
    }
    
    func suspend() {
        anySessionTask?.suspend()
    }
    
    func resume() {
        anySessionTask?.resume()
        
    }
    
    func cancel(byProducingResumeData completionHandler: @escaping (Data?) -> Void) {
        if anySessionTask is URLSessionDownloadTask {
            (anySessionTask as? URLSessionDownloadTask)?.cancel(byProducingResumeData: { resumeData in
                completionHandler(resumeData)
            })
        }
        
    }
    
    func bofurlSession(_ session: URLSession?, downloadTask: URLSessionDownloadTask?, didFinishDownloadingTo location: URL?) {
        do{
            
            var updatedLocation = location
            var relocationError:Error? = nil
            //TODO:check code
            if (self.downloadLocation != nil && updatedLocation != nil) {
                let success = BOFFileSystemManager.moveFile(fromLocation: updatedLocation!, toLocation: self.downloadLocation!, relocationError: relocationError as! Error)
                relocationErr = relocationError
                if success {
                    updatedLocation = downloadLocation
                }
            } else {
                downloadLocation = location
            }
            
            
            delegate?.bofNetworkPromise?(self, didFinishDownloadingTo: updatedLocation)
            
            delegateForHandler?.bofNetworkPromise?(self, didFinishDownloadingTo: updatedLocation)
            
            
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func bofurlSession(_ session: URLSession?, task: URLSessionTask?, didCompleteWithError error: Error?) {

            var dataOrLocation:Any
            
            if responseData != nil
            {
                dataOrLocation = responseData
            }
            else
            {
                dataOrLocation = downloadLocation
            }
            sessionTaskComplettionHandlerDownloaded(dataOrLocation, response: task?.response, error: error, session: session)
        
    }
    
    func bofurlSession(_ session: URLSession?, downloadTask: URLSessionDownloadTask?, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        delegate?.bofNetworkPromise?(self, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        
        delegateForHandler?.bofNetworkPromise?(self, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        
    }
    
    func bofurlSession(_ session: URLSession?, downloadTask: URLSessionDownloadTask?, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
        delegate?.bofNetworkPromise?(self, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
        delegateForHandler?.bofNetworkPromise?(self, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
    }
    
    func bofurlSession(
        _ session: URLSession?,
        dataTask: URLSessionDataTask?,
        didReceive data: Data?) {

            if responseData == nil {
                responseData = Data()
            }
            
            if data != nil{
                responseData?.append(data!)
            }
            
            delegate?.bofNetworkPromise?(self, didReceive: data)
            
            //            if delegate.responds(to: Selector("BOFNetworkPromise:didReceiveData:")) {
            //                delegate.bofNetworkPromise(self, didReceiveData: data)
            //            }
            
            delegateForHandler?.bofNetworkPromise?(self, didReceive: data)
            
            //TODO: check similar conditions
            //            if ((delegateForHandler?.responds(to: Selector("BOFNetworkPromise:didReceiveData:"))) != nil) {
            //                delegateForHandler?.bofNetworkPromise(self, didReceive: data)
            //            }
    }
    
    deinit {
        
        delegate = nil
        
    }
}
