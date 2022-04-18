//
//  BOEventsOperationExecutor.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 16/04/22.
//

import Foundation

let BO_ANALYTICS_SDK_SERIAL_QUEUE_KEY = "com.bo.sdk.queue.serial"
let BO_ANALYTICS_SDK_DEVICE_OPERATION_QUEUE_KEY = "com.bo.sdk.queue.device.serial"
let BO_ANALYTICS_SDK_BACKGROUND_QUEUE_KEY = "com.bo.sdk.queue.background"
let BO_ANALYTICS_SDK_INITIALIZATION_OPERATION_QUEUE_KEY = "com.bo.sdk.queue.initialization.serial"
let BO_ANALYTICS_SDK_SESSION_OPERATION_QUEUE_KEY = "com.bo.sdk.queue.session.serial"

private let sBOFSharedInstance: Any? = nil

class BOEventsOperationExecutor {
    private var executorSerialQueue: DispatchQueue?
    private var executorDeviceSerialQueue: DispatchQueue?
    private var executorInitializationSerialQueue: DispatchQueue?
    private var executorBackgroundTaskQueue: DispatchQueue?
    private var executorSessionDataSerialQueue: DispatchQueue?
    private var executorBackgroundTaskID: UIBackgroundTaskIdentifier!

    static let sharedInstance = BOEventsOperationExecutor()
    
    init() {
        super.init()
        executorSerialQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_SERIAL_QUEUE_KEY, DISPATCH_QUEUE_SERIAL)
        executorBackgroundTaskQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_BACKGROUND_QUEUE_KEY, DISPATCH_QUEUE_SERIAL)
        executorDeviceSerialQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_DEVICE_OPERATION_QUEUE_KEY, DISPATCH_QUEUE_CONCURRENT)
        executorInitializationSerialQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_INITIALIZATION_OPERATION_QUEUE_KEY, DISPATCH_QUEUE_CONCURRENT)
           executorSessionDataSerialQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_SESSION_OPERATION_QUEUE_KEY, DISPATCH_QUEUE_CONCURRENT)
       }
    func bo_dispatch_queue_create_specific(_ label: UnsafePointer<Int8>?, _ attr: DispatchQueueAttributes) -> DispatchQueue {
        let queue = DispatchQueue(label: label)
        dispatch_queue_set_specific(queue, queue, queue, nil)
        return queue
    }
    
    func bo_dispatch_is_on_specific_queue(_ queue: DispatchQueue) -> Bool {
        return dispatch_get_specific(queue) != nil
    }
    
    func bo_dispatch_specific(_ queue: DispatchQueue, _ block: () -> (), _ waitForCompletion: Bool) {
        let autoreleasing_block = {
            autoreleasepool {
                block()
            }
        }

        if dispatch_get_specific(queue) {
            autoreleasing_block()
            return
        }

        if waitForCompletion {
            queue.sync(execute: autoreleasing_block)
            return
        }

        queue.async(execute: autoreleasing_block)
    }
    func bo_dispatch_specific_after_time(_ queue: DispatchQueue, _ block: () -> (), _ afterTime: Double) {
        let autoreleasing_block = {
            autoreleasepool {
                block()
            }
        }

        queue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(afterTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: autoreleasing_block)
    }
    
    func bo_dispatch_specific_async(_ queue: DispatchQueue, _ block: () -> ()) {
        bo_dispatch_specific(queue, block, false)
    }


    func bo_dispatch_specific_sync(_ queue: DispatchQueue, _ block: () -> ()) {
        bo_dispatch_specific(queue, block, true)
    }
    func dispatchBackgroundTask(_ block: @escaping () -> Void) {
        bo_dispatch_specific_async(executorBackgroundTaskQueue, block)
    }

    func dispatchEvents(inBackground block: @escaping () -> Void) {
        bo_dispatch_specific_async(executorSerialQueue, block)
    }
    
    func dispatchDeviceOperation(inBackground block: @escaping () -> Void) {
        bo_dispatch_specific_async(executorDeviceSerialQueue, block)
    }

    func dispatch(inBackgroundAndWait block: @escaping () -> Void) {
        bo_dispatch_specific_sync(executorSerialQueue, block)
    }

    func dispatchInitialization(inBackground block: @escaping () -> Void) {
        bo_dispatch_specific_async(executorInitializationSerialQueue, block)
    }
    
    func dispatchInitialization(inBackground block: @escaping () -> Void, afterDelay delayInterval: Double) {
        bo_dispatch_specific_after_time(executorInitializationSerialQueue, block, delayInterval)
    }

    func dispatchSessionOperation(inBackground block: @escaping () -> Void, afterDelay delayInterval: Double) {
        bo_dispatch_specific_after_time(executorSessionDataSerialQueue, block, delayInterval)
    }
}
