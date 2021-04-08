//
//  BOFNetworkPromise.m
//  BlotoutFoundation
//
//  Created by Blotout on 26/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFNetworkPromise.h"
#import "BOFNetworkPromise_Private.h"

#import "BOFFileSystemManager.h"
#import "BOFConstants.h"
#import "BOFLogs.h"

NSString * const BOFNetworkPromiseDidCompleteExecution =   @"BOFNetworkPromiseDidCompleteExecution";
NSString * const BOFNetworkPromiseCreatedNewTask       =   @"BOFNetworkPromiseCreatedNewTask";
const float BOFNetworkPromiseTaskPriorityDefault       =   0.5;
const float BOFNetworkPromiseTaskPriorityLow           =   0.0;
const float BOFNetworkPromiseTaskPriorityHigh          =   1.0;

@interface  BOFNetworkPromise()
@property(nullable, nonatomic, readwrite ,strong)NSMutableData *responseData;
@end

@implementation BOFNetworkPromise
@synthesize networkPromiseDescription = _networkPromiseDescription;
@synthesize priority = _priority;

-( instancetype )init
{
    return nil;
}

- (instancetype)initWithURLRequest:(NSURLRequest * )request completionHandler:(BOFNetworkPromiseCompletionHandler)networkPromiseCompletionHandler{
    @try {
        if ( request == nil ) {
            return nil;
        }
        
        self = [super init];
        if ( self ) {
            self.urlRequest = request;
            self.completionHandler = networkPromiseCompletionHandler;
            [self customInitialization];
            
        }
        return self;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithResumeData:(NSData *)resumedData completionHandler:(BOFNetworkPromiseCompletionHandler)networkPromiseCompletionHandler{
    
    @try {
        if ( resumedData == nil ) {
            return nil;
        }
        
        self = [super init];
        if ( self ) {
            self.resumeData = resumedData;
            self.completionHandler = networkPromiseCompletionHandler;
            [self customInitialization];
        }
        return self;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

- (nullable instancetype)initWithURLRequest:(nonnull NSURLRequest *)request responseHandler:( id<BOFNetworkPromiseDeleagte> _Nonnull)networkResponseHandler;
{
    @try {
        if ( request == nil ) {
            return nil;
        }
        
        self = [super init];
        if ( self ) {
            self.urlRequest = request;
            self.delegateForHandler = networkResponseHandler;
            [self customInitialization];
            
        }
        return self;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

- (void)customInitialization
{
    @try {
        self.numberOfRetries = 0;
        self.totalAttempts = 0;
        self.retryDelay = 20.0;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(void)postNotificationForTaskCompletion{
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:BOFNetworkPromiseDidCompleteExecution object:self.anySessionTask userInfo:@{@"Description":@"NetworkPromise object completed execution using completion handler."}];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(void)postNotificationForNewTaskCreation{
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:BOFNetworkPromiseCreatedNewTask object:self.anySessionTask userInfo:@{
            @"Description":@"NetworkPromise locobject created new task using retry controls.",
            @"BOFNetworkPromiseObject" : self}];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

//-(void)doRetryOnErrorWithSession:(NSURLSession*)session{
//    self.totalAttempts++;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self startWithSession:session];
//        [self postNotificationForNewTaskCreation];
//    });
//}

-(void)doNecessaryCallbackInvocationOnCompletion:(id _Nullable)dataOrLocation response:(NSURLResponse * _Nullable) response error:(NSError * _Nullable) error{
    @try {
        if (self.completionHandler) {
            self.completionHandler(response,dataOrLocation,error);
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(BOFNetworkPromise:didCompleteWithError:)]) {
                [self.delegate BOFNetworkPromise:self didCompleteWithError:error];
            }
        }
        if (self.delegateForHandler && [self.delegateForHandler respondsToSelector:@selector(BOFNetworkPromise:didCompleteWithError:)]) {
            [self.delegateForHandler BOFNetworkPromise:self didCompleteWithError:error];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(void)sessionTaskComplettionHandlerDownloaded:(id _Nullable)dataOrLocation response:(NSURLResponse * _Nullable) response error:(NSError * _Nullable) error session:(NSURLSession * _Nullable)session
{
    @try {
        [self postNotificationForTaskCompletion];
        
        //Retry code should be refactored, so that works in case of delegate calls as well, but will require chnages to prevent session task & object removal from map in executor or add again, think then change
        //Also post notification when this is called irrespective of success or error, in case retry is called then new task will be created, so new entry should be
        // done in BOFNetworkPromiseTaskObject map
        
        //Note: Code is refactored for the above conditions, now retry is working for delegate and completetion handler both and test cases are passed.
        //Will be testing more on this.
        //doNecessaryCallbackInvocationOnCompletion function take care of what to call.
        
        /*
         Remove callback and completion block call from UI thread & make it happen on non UI thread with gurantee to reach caller, take care of thread being dead before called and caller do not receive call back cases, in coming versions, this is the main reason for using main thread here but in practise non good, also for performace.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            //shoould retry
            NSHTTPURLResponse *httpResponse  = (NSHTTPURLResponse *)response;
            if ( (error != nil && [error code] >= 500 ) || ([httpResponse statusCode] >= 500 )) {
                
                if (self.totalAttempts < self.numberOfRetries) {
                    //[self doRetryOnErrorWithSession:session];
                    self.totalAttempts++;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self startWithSession:session];
                        [self postNotificationForNewTaskCreation];
                    });
                } else {
                    [self doNecessaryCallbackInvocationOnCompletion:dataOrLocation response:response error:error];
                    //self.completionHandler ? self.completionHandler(response,dataOrLocation,error) : nil;
                    //[self postNotificationForTaskCompletion];
                }
            }
            else{
                [self doNecessaryCallbackInvocationOnCompletion:dataOrLocation response:response error:error];
                //self.completionHandler ? self.completionHandler(response,dataOrLocation,error) : nil;
                //[self postNotificationForTaskCompletion];
            }
        });
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(nullable NSURLSessionTask*)getAsyncDownloadUrlSessionTask:(NSURLSession * _Nullable)session{
    @try {
        NSURLSessionTask *anySessionTask = nil;
        if (self.resumeData) {
            anySessionTask = [session downloadTaskWithResumeData:_resumeData completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                [self sessionTaskComplettionHandlerDownloaded:location response:response error:error session:session];
            }];
        }else if (self.urlRequest) {
            anySessionTask = [session downloadTaskWithRequest:self.urlRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                [self sessionTaskComplettionHandlerDownloaded:location response:response error:error session:session];
            }];
        }
        return anySessionTask;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

//If session task is returned through this then delegate methods will not be called irrespective of whether delegate is set or not
-(nullable NSURLSessionTask*)getAsyncUrlSessionTask:(NSURLSession * _Nullable)session{
    @try {
        NSURLSessionTask *anySessionTask = nil;
        
        if (self.downloadAsFile || self.resumeData) {
            anySessionTask = [self getAsyncDownloadUrlSessionTask:session];
        }else if (self.urlRequest) {
            anySessionTask = [session dataTaskWithRequest:self.urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                [self sessionTaskComplettionHandlerDownloaded:data response:response error:error session:session];
            }];
        }
        return anySessionTask;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}


//If session task is returned through this then delegate methods will be called based on whether delegate is set or not
-(nullable NSURLSessionTask*)getSyncUrlSessionTask:(NSURLSession * _Nullable)session{
    @try {
        NSURLSessionTask *anySessionTask = nil;
        if (self.downloadAsFile || self.resumeData) {
            if (self.resumeData) {
                anySessionTask = [session downloadTaskWithResumeData:_resumeData];
            }else if (self.urlRequest) {
                anySessionTask = [session downloadTaskWithRequest:self.urlRequest];
            }
        }else if (self.urlRequest) {
            anySessionTask = [session dataTaskWithRequest:self.urlRequest];
        }
        return anySessionTask;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}


- (NSURLSessionTask*)startWithSession:(NSURLSession * _Nullable)session{
    
    @try {
        if (self.completionHandler && session) {
            //Note: getting sync task with delegate, as using NSURLSession with background download enforces the rule of using delegate & we can't use completion block else crash.
            //Change before production, so in case something does not fit well, please revert.
            
            //self.anySessionTask = [self getAsyncUrlSessionTask:session];
            self.anySessionTask = [self getSyncUrlSessionTask:session];
        }else if (session) {
            self.anySessionTask = [self getSyncUrlSessionTask:session];
        }
        
        if ((!session || !_anySessionTask) && self.completionHandler) {
            self.completionHandler(nil,nil,[NSError errorWithDomain:kBOFNetworkPromiseDefaultErrorDomain code:kBOFNetworkPromiseDefaultErrorCode userInfo:kBOFNetworkPromiseDefaultErrorUserInfo]);
        }
        
        _anySessionTask.taskDescription = _networkPromiseDescription;
        if ( NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
            _anySessionTask.priority = _priority;
        }
        [_anySessionTask resume];
        return _anySessionTask;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

-(NSUInteger)networkPromiseIdentifier{
    @try {
        return _anySessionTask.taskIdentifier;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return 0;
}

-(void)setNetworkPromiseDescription:(NSString *)networkPromiseDescription{
    @try {
        _networkPromiseDescription = networkPromiseDescription;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(NSString*)networkPromiseDescription{
    @try {
        return (_anySessionTask.taskDescription ? _anySessionTask.taskDescription : _networkPromiseDescription);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

-(NSURLRequest*)originalRequest{
    @try {
        return _anySessionTask.originalRequest;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

-(NSURLRequest*)currentRequest{
    @try {
        return _anySessionTask.currentRequest;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

-(NSURLResponse*)response{
    @try {
        return _anySessionTask.response;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

-(BOFNetworkPromiseTaskState)state{
    @try {
        BOFNetworkPromiseTaskState currentState;
        if (!_anySessionTask) {
            currentState = BOFNetworkPromiseTaskStateSuspended;
        } else {
            switch (_anySessionTask.state) {
                case NSURLSessionTaskStateRunning:
                    currentState = BOFNetworkPromiseTaskStateRunning;
                    break;
                case NSURLSessionTaskStateSuspended:
                    currentState = BOFNetworkPromiseTaskStateSuspended;
                    break;
                case NSURLSessionTaskStateCanceling:
                    currentState = BOFNetworkPromiseTaskStateCanceling;
                    break;
                case NSURLSessionTaskStateCompleted:
                    currentState = BOFNetworkPromiseTaskStateCompleted;
                    break;
                default:
                    break;
            }
        }
        return currentState;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return BOFNetworkPromiseTaskStateSuspended;
}

-(NSError*)error{
    @try {
        return _anySessionTask.error;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

-(void)setPriority:(float)priority{
    @try {
        _priority = priority;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}
-(float)priority{
    @try {
        if ( NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
            return _anySessionTask.priority;
        }
        return _priority;  // should be same as _priority
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NSURLSessionTaskPriorityDefault;
}

- (void)cancel{
    @try {
        [self.anySessionTask cancel];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}
- (void)suspend{
    @try {
        [self.anySessionTask suspend];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}
- (void)resume{
    @try {
        [self.anySessionTask resume];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}
- (void)cancelByProducingResumeData:(nullable void (^)(NSData * __nullable resumeData))completionHandler
{
    @try {
        if ([self.anySessionTask isKindOfClass:[NSURLSessionDownloadTask class]]) {
            [((NSURLSessionDownloadTask *)self.anySessionTask) cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                completionHandler(resumeData);
            }];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(void)BOFURLSession:(NSURLSession * _Nullable)session downloadTask:(NSURLSessionDownloadTask * _Nullable)downloadTask didFinishDownloadingToURL:(NSURL * _Nullable)location
{
    @try {
        if (self.downloadLocation) {
            NSError *relocationError = nil;
            BOOL success = [BOFFileSystemManager moveFileFromLocation:location toLocation:self.downloadLocation relocationError:&relocationError];
            self.relocationErr = relocationError;
            if (success) {
                location = self.downloadLocation;
            }
        } else {
            self.downloadLocation = location;
        }
        
        if ([self.delegate respondsToSelector:@selector(BOFNetworkPromise:didFinishDownloadingToURL:)]) {
            [self.delegate BOFNetworkPromise:self didFinishDownloadingToURL:location];
        }
        if ([self.delegateForHandler respondsToSelector:@selector(BOFNetworkPromise:didFinishDownloadingToURL:)]) {
            [self.delegateForHandler BOFNetworkPromise:self didFinishDownloadingToURL:location];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(void)BOFURLSession:(NSURLSession * _Nullable)session task:(NSURLSessionTask * _Nullable)task didCompleteWithError:(NSError * _Nullable)error
{
    @try {
        id dataOrLocation = self.responseData ? self.responseData : self.downloadLocation;
        [self sessionTaskComplettionHandlerDownloaded:dataOrLocation response:task.response error:error session:session];
        
        //    if ([self.delegate respondsToSelector:@selector(BOFNetworkPromise:didCompleteWithError:)]) {
        //        [self.delegate BOFNetworkPromise:self didCompleteWithError:error];
        //    }
        //    if ([self.delegateForHandler respondsToSelector:@selector(BOFNetworkPromise:didCompleteWithError:)]) {
        //        [self.delegateForHandler BOFNetworkPromise:self didCompleteWithError:error];
        //    }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(void)BOFURLSession:(NSURLSession * _Nullable)session downloadTask:(NSURLSessionDownloadTask * _Nullable)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    @try {
        if ([self.delegate respondsToSelector:@selector(BOFNetworkPromise:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
            [self.delegate BOFNetworkPromise:self didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        }
        if ([self.delegateForHandler respondsToSelector:@selector(BOFNetworkPromise:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
            [self.delegateForHandler BOFNetworkPromise:self didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(void)BOFURLSession:(NSURLSession * _Nullable)session downloadTask:(NSURLSessionDownloadTask * _Nullable)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    @try {
        if ([self.delegate respondsToSelector:@selector(BOFNetworkPromise:didResumeAtOffset:expectedTotalBytes:)]) {
            [self.delegate BOFNetworkPromise:self didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
        }
        if ([self.delegateForHandler respondsToSelector:@selector(BOFNetworkPromise:didResumeAtOffset:expectedTotalBytes:)]) {
            [self.delegateForHandler BOFNetworkPromise:self didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

- (void)BOFURLSession:(NSURLSession * _Nullable)session dataTask:(NSURLSessionDataTask * _Nullable)dataTask
       didReceiveData:(NSData * _Nullable)data
{
    @try {
        if ( self.responseData == nil ) {
            self.responseData = [[NSMutableData alloc] init];
        }
        
        [self.responseData appendData:data];
        
        if ([self.delegate respondsToSelector:@selector(BOFNetworkPromise:didReceiveData:)]) {
            [self.delegate BOFNetworkPromise:self didReceiveData:data];
        }
        if ([self.delegateForHandler respondsToSelector:@selector(BOFNetworkPromise:didReceiveData:)]) {
            [self.delegateForHandler BOFNetworkPromise:self didReceiveData:data];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(void)dealloc
{
    @try {
        self.delegate = nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}
@end

