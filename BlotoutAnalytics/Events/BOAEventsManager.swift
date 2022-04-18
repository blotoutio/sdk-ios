//
//  BOAEventsManager.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 22/03/22.
//

import Foundation

let BOAQueueKey = "BOAQueue"
let kBOAQueueFilename = "blotout.queue.plist"

class BOAEventsManager:NSObject {
    private var queue: [AnyHashable]?
    private var storage: BOAStorage?
    private var configuration: BlotoutAnalyticsConfiguration
    private var flushTimer: Timer?
    private var referrer: [AnyHashable : Any]?
    private var flushTaskID: UIBackgroundTaskIdentifier!
    private var batchRequest = false
    
    
    init(configuration: BlotoutAnalyticsConfiguration, storage: BOAStorage) {
        super.init()
        self.configuration = configuration
        self.storage = storage
        flushTimer = Timer(
            timeInterval: configuration.flushInterval,
            target: self,
            selector: Selector("flush"),
            userInfo: nil,
            repeats: true)
        
        RunLoop.main.add(flushTimer, forMode: .default)
        
        
        return self
    }
    
    func beginBackgroundTask() {
        do{
            endBackgroundTask()
            
            BOEventsOperationExecutor.sharedInstance.dispatchBackgroundTask({ [self] in
                weak var application = configuration.application
                if application == nil {
                    return
                }
                flushTaskID = application.boa_beginBackgroundTask(
                    withName: "BlotoutAnalytics_Background_Task",
                    expirationHandler: { [self] in
                        endBackgroundTask()
                    })
            })
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    
    func endBackgroundTask() {
       do{
            BOEventsOperationExecutor.sharedInstance.dispatchBackgroundTask({ [self] in
                if flushTaskID == .invalid {
                    return
                }
                
                weak var application = configuration.application
                if let application = application {
                    application.boa_endBackgroundTask(flushTaskID)
                }
                
                flushTaskID = UIBackgroundTaskIdentifier.invalid
            })
        } catch{
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        })
    }
    
    func capture(_ payload: BOACaptureModel?) {
        do{
            let event = BOADeveloperEvents.captureEvent(payload)
            if event == nil {
                return
            }
            
            enqueueEvent("capture", dictionary: event)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func capturePersonal(_ payload: BOACaptureModel?, isPHI phiEvent: Bool) {
        do{
            let personalEvent = BOADeveloperEvents.capturePersonalEvent(payload, isPHI: phiEvent)
            if personalEvent == nil {
                return
            }
            
            enqueueEvent("capturePersonal", dictionary: personalEvent)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    
    func enqueueEvent(_ action: String?, dictionary payload: [AnyHashable : Any]?) {
        do{
            queuePayload(payload)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func queuePayload(_ payload: [AnyHashable : Any]?) {
        var payload = payload
        do{
            payload = BOAUtilities.traverseJSON(payload)
            if let payload = payload {
                queue.append(payload)
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
        do{
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                if queue.count() == 0 {
                    BOFLogDebug("%@ No queued API calls to flush.", self)
                    endBackgroundTask()
                    return
                }
                if batchRequest {
                    BOFLogDebug("%@ API request already in progress, not flushing again.", self)
                    return
                }
                
                let batch = queue as? [AnyHashable]
                sendData(batch)
            } catch {
                BOFLogDebug(frmt: "%@", args:  error.localizedDescription)
            })
        }
    }
    
    func flushQueueByLength() {
        do{
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                if !batchRequest && queue.count() >= configuration.flushAt {
                    flush()
                }
            })
        } catch {
            BOFLogDebug(frmt: "%@", args:  error.localizedDescription)
        }
    }
    
    
    func sendData(_ batch: [AnyHashable]?) {
        do{
            batchRequest = true
            BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                let post = BOEventPostAPI()
                let json = BOADeveloperEvents.prepareServerPayload(batch)
                var error: Error? = nil
                var data: Data? = nil
                
                post.postEventDataModel(data, withAPICode: BOUrlEndPointEventPublish, success: { [self] responseObject in
                    BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: { [self] in
                        queue = queue.filter({ !batch.contains($0) })
                        persistQueue()
                        batchRequest = false
                        endBackgroundTask()
                    })
                }, failure: { [self] urlResponse, dataOrLocation, error in
                    batchRequest = false
                    BOFLogDebug("%@", error.description())
                })
            })
        } catch {
            BOFLogDebug(frmt: "%@", args:  error.localizedDescription)
            self.batchRequest = false
        }
    }
    
    func applicationDidEnterBackground() {
        do{
            beginBackgroundTask()
            // We are gonna try to flush as much as we reasonably can when we enter background
            // since there is a chance that the user will never launch the app again.
            flush()
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)

        })
    }
    
    func applicationWillTerminate() {
        do{
            BOEventsOperationExecutor.sharedInstance.dispatch(inBackgroundAndWait: { [self] in
                if queue.count {
                    persistQueue()
                }
            })
        }catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)

        }
    }
    
    func queue() -> [AnyHashable]? {
        if (queue == nil) {
#if os(tvOS)
            queue = (storage.array(forKey: BOAQueueKey) ?? [])
#else
            queue = (storage.array(forKey: kBOAQueueFilename) ?? [])
#endif
        }
        
        return queue
    }
    
    func persistQueue() {
#if os(tvOS)
        storage.set(queue.copy(), forKey: BOAQueueKey)
#else
        storage.set(queue.copy(), forKey: kBOAQueueFilename)
#endif
    }
    
}
