//
//  BOOperationEventsExecutor.h
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 24/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOEventsOperationExecutor : NSObject

+ (instancetype)sharedInstance;
- (void)dispatchBackgroundTask:(void (^)(void))block;
- (void)dispatchEventsInBackground:(void (^)(void))block;
- (void)dispatchDeviceOperationInBackground:(void (^)(void))block;
- (void)dispatchInitializationInBackground:(void (^)(void))block;
- (void)dispatchInBackgroundAndWait:(void (^)(void))block;
- (void)dispatchInitializationInBackground:(void (^)(void))block afterDelay:(double)delayInterval;
- (void)dispatchSessionOperationInBackground:(void (^)(void))block afterDelay:(double)delayInterval;
@end

NS_ASSUME_NONNULL_END
