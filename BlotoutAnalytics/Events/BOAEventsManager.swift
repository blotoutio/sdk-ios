//
//  BOAEventsManager.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 22/03/22.
//

import Foundation
import UIKit

let BOAQueueKey = "BOAQueue"
let kBOAQueueFilename = "blotout.queue.plist"

class BOAEventsManager:NSObject {
    private var queue: [AnyHashable] = []
    private var storage: BOAStorage?
    private var configuration: BlotoutAnalyticsConfiguration?
    private var flushTimer: Timer?
    private var referrer: [AnyHashable : Any] = [:]
    private var flushTaskID: UIBackgroundTaskIdentifier?
    private var batchRequest = false
    
    
//    required init?(coder aDecoder: NSCoder) {
//
//        super.init(coder: aDecoder)
//    }
    
    //TODO: check the method flow
    init(configuration: BlotoutAnalyticsConfiguration, storage: BOAStorage){
      
        super.init()
        //TODO: check this
        self.configuration = configuration
        self.storage = storage
        flushTimer = Timer(
            timeInterval: configuration.flushInterval,
            target: self,
            selector: #selector(CATransaction.flush),
            userInfo: nil,
            repeats: true)
        
        RunLoop.main.add(flushTimer!, forMode: .default)
      // }
      
    }
    
    func beginBackgroundTask() {
        endBackgroundTask()

        BOEventsOperationExecutor.sharedInstance.dispatchBackgroundTask({ [self] in
                let application = configuration!.application
                if application == nil {
                    return
                }

                flushTaskID = application!.boa_beginBackgroundTask(
                    withName: "BlotoutAnalytics_Background_Task",
                    expirationHandler: { [self] in
                        endBackgroundTask()
                    })
            })
    }
    
    
    func endBackgroundTask() {
      
            BOEventsOperationExecutor.sharedInstance.dispatchBackgroundTask({ [self] in
                if flushTaskID == .invalid {
                    return
                }
                
                weak var application = configuration!.application
                if let application = application {
                    application.boa_endBackgroundTask(flushTaskID!)
                }
                
                flushTaskID = UIBackgroundTaskIdentifier.invalid
            })
       
    }
    
    func capture(_ payload: BOACaptureModel?) {
        
            let event = BOADeveloperEvents.captureEvent(payload)
            if event == nil {
                return
            }
            
            enqueueEvent("capture", dictionary: event)
       
    }
    
//    func capturePersonal(_ payload: BOACaptureModel?, isPHI phiEvent: Bool) {
//
//            let personalEvent = BOADeveloperEvents.capturePersonalEvent(payload, isPHI: phiEvent)
//            if personalEvent == nil {
//                return
//            }
//
//            enqueueEvent("capturePersonal", dictionary: personalEvent)
//    }
    
    
    func enqueueEvent(_ action: String?, dictionary payload: [AnyHashable : Any]?) {
        
            queuePayload(payload)
        
    }
    
    func queuePayload(_ payload: [AnyHashable : Any]?) {
        var payload = payload
        do{
            payload = BOAUtilities.traverseJSON(payload) as? [AnyHashable : Any]
            if let payload = payload {
           //TODO: fix this     queue.insert(contentsOf: payload, at: 0)
                
               // queue.append(payload)
            }
            persistQueue()
            flushQueueByLength()
        } catch {
            BOFLogDebug(frmt: "%@", args:  error.localizedDescription)
        }
    }
    
    func flush() {
        self.flush(withMaxSize: 0)
    }
    
    func flush(withMaxSize maxBatchSize: Int) {

            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                if queue.count == 0 {
                    BOFLogDebug(frmt: "%@ No queued API calls to flush.", args: self)
                    endBackgroundTask()
                    return
                }
                if batchRequest {
                    BOFLogDebug(frmt: "%@ API request already in progress, not flushing again.", args: self)
                    return
                }
                
                let batch = queue as? [AnyHashable]
                sendData(batch ?? [])
            })
    }
    
    
    func flushQueueByLength() {

            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                if !batchRequest && queue.count >= configuration!.flushAt {
                    flush()
                }
            })
    }
    
    
    func sendData(_ batch: [AnyHashable]) {
            batchRequest = true
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                let post = BOEventPostAPI()
                let json = BOADeveloperEvents.prepareServerPayload(events: batch)
                var error: Error? = nil
                var data: Data? = nil
                
                post.postEventDataModel(data, withAPICode: BOUrlEndPoint.eventPublish, success: { [self] responseObject in
                    BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                        queue = queue.filter({ !batch.contains($0) })
                        persistQueue()
                        batchRequest = false
                        endBackgroundTask()
                    })
                }, failure: { [self] urlResponse, dataOrLocation, error in
                    batchRequest = false
                    BOFLogDebug(frmt: "%@", args: error?.localizedDescription as! CVarArg)
                })
            })

    }
    
    func applicationDidEnterBackground() {
            beginBackgroundTask()
            // We are gonna try to flush as much as we reasonably can when we enter background
            // since there is a chance that the user will never launch the app again.
            flush()
    }
    
    func applicationWillTerminate() {
            BOEventsOperationExecutor.sharedInstance.dispatch(inBackgroundAndWait: { [self] in
                if queue.count ?? 0 > 0 {
                    persistQueue()
                }
            })

    }
    
    //TODO: have changed name,need to verify code
    func getQueue() -> [AnyHashable]? {
        if (self.queue == nil) {
#if os(tvOS)
            self.queue = (storage.array(forKey: BOAQueueKey) ?? [])
#else
            self.queue = (storage!.array(forKey: kBOAQueueFilename) as? [AnyHashable] ?? [])
#endif
        }
        return queue
    }
    
    func persistQueue() {
#if os(tvOS)
        storage.set(queue, forKey: BOAQueueKey)
#else
        storage!.set(queue, forKey: kBOAQueueFilename)
#endif
    }
    
}
