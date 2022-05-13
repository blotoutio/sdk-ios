//
//  BOEventsOperationExecutor.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 16/04/22.
//

import Foundation
import UIKit

let BO_ANALYTICS_SDK_SERIAL_QUEUE_KEY = "com.bo.sdk.queue.serial"
let BO_ANALYTICS_SDK_DEVICE_OPERATION_QUEUE_KEY = "com.bo.sdk.queue.device.serial"
let BO_ANALYTICS_SDK_BACKGROUND_QUEUE_KEY = "com.bo.sdk.queue.background"
let BO_ANALYTICS_SDK_INITIALIZATION_OPERATION_QUEUE_KEY = "com.bo.sdk.queue.initialization.serial"
let BO_ANALYTICS_SDK_SESSION_OPERATION_QUEUE_KEY = "com.bo.sdk.queue.session.serial"

private let sBOFSharedInstance: Any? = nil

class BOEventsOperationExecutor:NSObject {
    private var executorSerialQueue: DispatchQueue
    private var executorDeviceSerialQueue: DispatchQueue
    private var executorInitializationSerialQueue: DispatchQueue
    private var executorBackgroundTaskQueue: DispatchQueue
    private var executorSessionDataSerialQueue: DispatchQueue
   // private var executorBackgroundTaskID: UIBackgroundTaskIdentifier

    static let sharedInstance = BOEventsOperationExecutor()
    
    override init() {
       
        executorSerialQueue = DispatchQueue(label: BO_ANALYTICS_SDK_SERIAL_QUEUE_KEY)
        executorBackgroundTaskQueue = DispatchQueue(label:BO_ANALYTICS_SDK_BACKGROUND_QUEUE_KEY)
        executorDeviceSerialQueue = DispatchQueue(label: BO_ANALYTICS_SDK_DEVICE_OPERATION_QUEUE_KEY, attributes: .concurrent)
        executorInitializationSerialQueue = DispatchQueue(label:BO_ANALYTICS_SDK_INITIALIZATION_OPERATION_QUEUE_KEY, attributes: .concurrent)
        executorSessionDataSerialQueue = DispatchQueue(label:BO_ANALYTICS_SDK_SESSION_OPERATION_QUEUE_KEY, attributes: .concurrent)
        super.init()
       }
    
    func bo_dispatch_specific(queue: DispatchQueue, block:@escaping () -> (),  waitForCompletion: Bool) {

        if (waitForCompletion) {
            queue.sync(execute: block);
          return;
        }
        queue.async(execute: block);

    }
    
    func bo_dispatch_specific_async(queue: DispatchQueue, block:@escaping () -> ()) {
        bo_dispatch_specific(queue: queue, block: block, waitForCompletion: false)
    }

    func bo_dispatch_specific_sync(queue: DispatchQueue,  block:@escaping () -> ()) {
        bo_dispatch_specific(queue: queue, block: block, waitForCompletion: true)
    }
    func dispatchBackgroundTask(_ block: @escaping () -> Void) {
        bo_dispatch_specific_async(queue: executorBackgroundTaskQueue, block: block)
    }

    func dispatchEvents(inBackground block: @escaping () -> Void) {
        bo_dispatch_specific_async(queue: executorSerialQueue, block: block)
    }

    func dispatch(inBackgroundAndWait block: @escaping () -> Void) {
        bo_dispatch_specific_sync(queue: executorSerialQueue, block: block)
    }

    func dispatchInitialization(inBackground block: @escaping () -> Void) {
        bo_dispatch_specific_async(queue: executorInitializationSerialQueue, block: block)
    }

}
