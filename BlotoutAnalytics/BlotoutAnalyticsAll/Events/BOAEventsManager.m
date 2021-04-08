//
//  BOEventsManager.m
//  BlotoutAnalyticsTVOS
//
//  Created by ankuradhikari on 22/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "BOAEventsManager.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOEventsOperationExecutor.h"
#import "BOADeveloperEvents.h"
#import "BOEventPostAPI.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAUtilities.h"

NSString *const BOAQueueKey = @"BOAQueue";
NSString *const kBOAQueueFilename = @"blotout.queue.plist";


@interface BOAEventsManager ()
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) id<BOAStorage> storage;
@property (nonatomic, strong) BlotoutAnalyticsConfiguration *configuration;
@property (nonatomic, strong) NSTimer *flushTimer;
@property (atomic, copy) NSDictionary *referrer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier flushTaskID;
@property (nonatomic, readwrite) BOOL batchRequest;

@end

@implementation BOAEventsManager

- (id)initWithConfiguration:(BlotoutAnalyticsConfiguration *)configuration storage:(id<BOAStorage>)storage {
    
    if (self = [super init]) {
        self.configuration = configuration;
        self.storage = storage;
        
        self.flushTimer = [NSTimer timerWithTimeInterval:self.configuration.flushInterval
                                                  target:self
                                                selector:@selector(flush)
                                                userInfo:nil
                                                 repeats:YES];
        
        [NSRunLoop.mainRunLoop addTimer:self.flushTimer
                                forMode:NSDefaultRunLoopMode];
    }
    
    return self;
}

- (void)beginBackgroundTask
{
    @try {
        [self endBackgroundTask];
        
        [[BOEventsOperationExecutor sharedInstance] dispatchBackgroundTask:^{
            id<BOAApplicationProtocol> application = self.configuration.application;
            if (application) {
                self.flushTaskID = [application boa_beginBackgroundTaskWithName:@"BlotoutAnalytics_Background_Task"
                                                              expirationHandler:^{
                    [self endBackgroundTask];
                }];
            }
        }];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)endBackgroundTask
{
    @try {
        [[BOEventsOperationExecutor sharedInstance] dispatchBackgroundTask:^{
            if (self.flushTaskID != UIBackgroundTaskInvalid) {
                id<BOAApplicationProtocol> application = self.configuration.application;
                if (application) {
                    [application boa_endBackgroundTask:self.flushTaskID];
                }
                
                self.flushTaskID = UIBackgroundTaskInvalid;
            }
        }];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)capture:(BOACaptureModel *)payload
{
    @try {
        NSDictionary *event = [BOADeveloperEvents captureEvent:payload];
        if(event != nil) {
            [self enqueueEvent:@"capture" dictionary:event];
        }
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@", exception);
    }
}

-(void)capturePersonal:(BOACaptureModel *)payload isPHI:(BOOL)phiEvent {
    @try {
        NSDictionary *personalEvent = [BOADeveloperEvents capturePersonalEvent:payload isPHI:phiEvent];
        if(personalEvent != nil) {
            [self enqueueEvent:@"capturePersonal" dictionary:personalEvent];
        }
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@", exception);
    }
}

- (void)enqueueEvent:(NSString *)action dictionary:(NSDictionary *)payload {
    @try {
        [self queuePayload:payload];
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@", exception);
    }
}

- (void)queuePayload:(NSDictionary *)payload
{
    @try {
        payload = [BOAUtilities traverseJSON:payload];
        [self.queue addObject:payload];
        [self persistQueue];
        [self flushQueueByLength];
    }
    @catch (NSException *exception) {
        BOFLogDebug(@"%@", exception);
    }
}

- (void)flush
{
    [self flushWithMaxSize:0];
}

- (void)flushWithMaxSize:(NSUInteger)maxBatchSize
{
    @try {
        [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
            if ([self.queue count] == 0) {
                BOFLogDebug(@"%@ No queued API calls to flush.", self);
                [self endBackgroundTask];
                return;
            }
            if (self.batchRequest) {
                BOFLogDebug(@"%@ API request already in progress, not flushing again.", self);
                return;
            }
            
            NSArray *batch = [NSArray arrayWithArray:self.queue];
            
            [self sendData:batch];
        }];
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@", exception);
    }
}

- (void)flushQueueByLength
{
    @try {
        [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
            if (!self.batchRequest && [self.queue count] >= self.configuration.flushAt) {
                [self flush];
            }
        }];
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@", exception);
    }
}

- (void)sendData:(NSArray *)batch {
    @try {
        
        self.batchRequest = YES;
        [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
            BOEventPostAPI *post = [[BOEventPostAPI alloc] init];
            NSDictionary *json =  [BOADeveloperEvents prepareServerPayload:batch];
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:&error];
            
            [post postEventDataModel:data withAPICode:BOUrlEndPointEventDataPOST success:^(id  _Nonnull responseObject) {
                [self.queue removeObjectsInArray:batch];
                [self persistQueue];
                self.batchRequest = NO;
                [self endBackgroundTask];
            } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
                self.batchRequest = NO;
                NSLog(@"%@",[error description]);
            }];
        }];
        
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@", exception);
        self.batchRequest = NO;
    }
}

- (void)applicationDidEnterBackground
{
    @try {
        [self beginBackgroundTask];
        // We are gonna try to flush as much as we reasonably can when we enter background
        // since there is a chance that the user will never launch the app again.
        [self flush];
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@", exception);
    }
}

- (void)applicationWillTerminate
{
    @try {
        [[BOEventsOperationExecutor sharedInstance] dispatchInBackgroundAndWait:^{
            if (self.queue.count)
                [self persistQueue];
        }];
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@", exception);
    }
}

- (NSMutableArray *)queue
{
    if (!_queue) {
#if TARGET_OS_TV
        _queue = [[self.storage arrayForKey:BOAQueueKey] ?: @[] mutableCopy];
#else
        _queue = [[self.storage arrayForKey:kBOAQueueFilename] ?: @[] mutableCopy];
#endif
    }
    
    return _queue;
}

- (void)persistQueue
{
#if TARGET_OS_TV
    [self.storage setArray:[self.queue copy] forKey:BOAQueueKey];
#else
    [self.storage setArray:[self.queue copy] forKey:kBOAQueueFilename];
#endif
}
@end
