//
//  BOOperationEventsExecutor.m
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 24/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import "BOEventsOperationExecutor.h"
@import UIKit;

#define  BO_ANALYTICS_SDK_SERIAL_QUEUE_KEY  "com.bo.sdk.queue.serial"
#define  BO_ANALYTICS_SDK_DEVICE_OPERATION_QUEUE_KEY  "com.bo.sdk.queue.device.serial"
#define BO_ANALYTICS_SDK_BACKGROUND_QUEUE_KEY "com.bo.sdk.queue.background"
#define  BO_ANALYTICS_SDK_INITIALIZATION_OPERATION_QUEUE_KEY  "com.bo.sdk.queue.initialization.serial"
#define  BO_ANALYTICS_SDK_SESSION_OPERATION_QUEUE_KEY  "com.bo.sdk.queue.session.serial"

static id sBOFSharedInstance = nil;

@interface BOEventsOperationExecutor ()
@property (nonatomic, strong) dispatch_queue_t executorSerialQueue;
@property (nonatomic, strong) dispatch_queue_t executorDeviceSerialQueue;
@property (nonatomic, strong) dispatch_queue_t executorInitializationSerialQueue;
@property (nonatomic, strong) dispatch_queue_t executorBackgroundTaskQueue;
@property (nonatomic, strong) dispatch_queue_t executorSessionDataSerialQueue;
@property (nonatomic, assign) UIBackgroundTaskIdentifier executorBackgroundTaskID;

@end

@implementation BOEventsOperationExecutor

+ (instancetype)sharedInstance {
  static dispatch_once_t bofOnceToken = 0;
  dispatch_once(&bofOnceToken, ^{
    sBOFSharedInstance = [[[self class] alloc] init];
  });
  return sBOFSharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.executorSerialQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_SERIAL_QUEUE_KEY, DISPATCH_QUEUE_SERIAL);
    self.executorBackgroundTaskQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_BACKGROUND_QUEUE_KEY, DISPATCH_QUEUE_SERIAL);
    self.executorDeviceSerialQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_DEVICE_OPERATION_QUEUE_KEY, DISPATCH_QUEUE_CONCURRENT);
    self.executorInitializationSerialQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_INITIALIZATION_OPERATION_QUEUE_KEY, DISPATCH_QUEUE_CONCURRENT);
    self.executorSessionDataSerialQueue = bo_dispatch_queue_create_specific(BO_ANALYTICS_SDK_SESSION_OPERATION_QUEUE_KEY, DISPATCH_QUEUE_CONCURRENT);
  }
  return self;
}

dispatch_queue_t bo_dispatch_queue_create_specific(const char *label, dispatch_queue_attr_t attr) {
  dispatch_queue_t queue = dispatch_queue_create(label, attr);
  dispatch_queue_set_specific(queue, (__bridge const void *)queue, (__bridge void *)queue, NULL);
  return queue;
}

BOOL bo_dispatch_is_on_specific_queue(dispatch_queue_t queue) {
  return dispatch_get_specific((__bridge const void *)queue) != NULL;
}

void bo_dispatch_specific(dispatch_queue_t queue, dispatch_block_t block, BOOL waitForCompletion) {
  dispatch_block_t autoreleasing_block = ^{
    @autoreleasepool
    {
      block();
    }
  };
  
  if (dispatch_get_specific((__bridge const void *)queue)) {
    autoreleasing_block();
    return;
  }
  
  if (waitForCompletion) {
    dispatch_sync(queue, autoreleasing_block);
    return;
  }
  
  dispatch_async(queue, autoreleasing_block);
}

void bo_dispatch_specific_after_time(dispatch_queue_t queue, dispatch_block_t block,double afterTime) {
  dispatch_block_t autoreleasing_block = ^{
    @autoreleasepool
    {
      block();
    }
  };
    
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)),queue, autoreleasing_block);
}

void bo_dispatch_specific_async(dispatch_queue_t queue, dispatch_block_t block) {
  bo_dispatch_specific(queue, block, NO);
}

void bo_dispatch_specific_sync(dispatch_queue_t queue, dispatch_block_t block) {
  bo_dispatch_specific(queue, block, YES);
}

- (void)dispatchBackgroundTask:(void (^)(void))block {
  bo_dispatch_specific_async(_executorBackgroundTaskQueue, block);
}


- (void)dispatchEventsInBackground:(void (^)(void))block {
  bo_dispatch_specific_async(_executorSerialQueue, block);
}

- (void)dispatchDeviceOperationInBackground:(void (^)(void))block {
  bo_dispatch_specific_async(_executorDeviceSerialQueue, block);
}

- (void)dispatchInBackgroundAndWait:(void (^)(void))block {
  bo_dispatch_specific_sync(_executorSerialQueue, block);
}

- (void)dispatchInitializationInBackground:(void (^)(void))block {
  bo_dispatch_specific_async(_executorInitializationSerialQueue, block);
}

- (void)dispatchInitializationInBackground:(void (^)(void))block afterDelay:(double)delayInterval {
  bo_dispatch_specific_after_time(_executorInitializationSerialQueue, block, delayInterval);
}

- (void)dispatchSessionOperationInBackground:(void (^)(void))block afterDelay:(double)delayInterval {
  bo_dispatch_specific_after_time(_executorSessionDataSerialQueue, block, delayInterval);
}

@end
