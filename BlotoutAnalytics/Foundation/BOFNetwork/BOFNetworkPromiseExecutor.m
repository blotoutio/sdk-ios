//
//  BOFNetworkPromiseExecutor.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFNetworkPromiseExecutor.h"
#import "BOFNetworkPromiseExecutor_Private.h"
#import "BOFNetworkPromise_Private.h"
#import "BOFLogs.h"
#import "BOFConstants.h"

__strong static id sBOFSharedInstance = nil;
//VAST specific session shared instance
__strong static id sBOFSharedInstanceForCampaign = nil;

#define kNSURLNetworkConfigurationIdentifier @"BOFNetworkUrlSessionConfigurationIdentifier"
#define kNSURLNetworkConfigurationIdentifierForCampaign @"BOFNetworkUrlSessionConfigurationIdentifierForCampaign"

@interface BOFNetworkPromiseExecutor() <NSURLSessionDownloadDelegate, NSURLSessionDataDelegate> {}

@end

@implementation BOFNetworkPromiseExecutor

+ (instancetype)sharedInstance {
  @try {
    static dispatch_once_t bofNetworkPromiseOnceToken = 0;
    dispatch_once(&bofNetworkPromiseOnceToken, ^{
      sBOFSharedInstance = [[[self class] alloc] init];
    });
    
    return  sBOFSharedInstance;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

+ (instancetype)sharedInstanceForCampaign {
  @try {
    static dispatch_once_t bofNetworkPromiseOnceTokenForCampaign = 0;
    dispatch_once(&bofNetworkPromiseOnceTokenForCampaign, ^{
      sBOFSharedInstanceForCampaign = [[[self class] alloc] initWithBackgroundIdentifier:kNSURLNetworkConfigurationIdentifierForCampaign];
    });
    
    return  sBOFSharedInstanceForCampaign;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

-(void)executorConfiguration {
  @try {
    //You must create exactly one session per identifier (specified when you create the configuration object). The behavior of multiple sessions sharing the same identifier is undefined.
    //https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html
    //test cases will fail as was written with normal configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.allowsCellularAccess = YES;
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    [self.taskPromiseObjectMap removeAllObjects];
    //concurrentQueue = dispatch_queue_create("com.bfonetwork.promiseexecuterqueue", DISPATCH_QUEUE_CONCURRENT);
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

-(void)executorConfigurationWithBackgroundIdentifier:(NSString *)identifier {
  @try {
    //You must create exactly one session per identifier (specified when you create the configuration object). The behavior of multiple sessions sharing the same identifier is undefined.
    //https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html
    //test cases will fail as was written with normal configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    sessionConfiguration.allowsCellularAccess = YES;
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    [self.taskPromiseObjectMap removeAllObjects];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

-(void)dealloc {
  @try {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BOFNetworkPromiseDidCompleteExecution object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BOFNetworkPromiseCreatedNewTask object:nil];
    //When object deallocated, we have to explicitly invalidate the session.
    //iOS does not deallocate session by its own
    [_session invalidateAndCancel];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

-(void)sessionTaskDidComplete:(NSNotification*)notificationObj {
  @try {
    [self.taskPromiseObjectMap removeObjectForKey:notificationObj.object];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

-(void)sessionTaskDidCreate:(NSNotification*)notificationObj {
  @try {
    NSURLSessionTask* sessionTask = notificationObj.object;
    BOFNetworkPromise *networkPromise = [notificationObj.userInfo objectForKey:@"BOFNetworkPromiseObject"];
    if (sessionTask && networkPromise) {
      [self.taskPromiseObjectMap setObject:networkPromise forKey:sessionTask];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

- (instancetype)init {
  @try {
    self = [super init];
    if (self) {
      self.taskPromiseObjectMap = [NSMapTable strongToStrongObjectsMapTable];
      [self executorConfiguration];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionTaskDidComplete:) name:BOFNetworkPromiseDidCompleteExecution object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionTaskDidCreate:) name:BOFNetworkPromiseCreatedNewTask object:nil];
      self.isSDKEnabled = YES;
      self.isNetworkSyncEnabled = YES;
    }
    return self;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

- (instancetype)initWithBackgroundIdentifier:(NSString *)identifier {
  @try {
    self = [super init];
    if (self) {
      self.taskPromiseObjectMap = [NSMapTable strongToStrongObjectsMapTable];
      if (identifier && (identifier.length > 0)) {
        [self executorConfigurationWithBackgroundIdentifier:identifier];
      } else {
        [self executorConfiguration];
      }
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionTaskDidComplete:) name:BOFNetworkPromiseDidCompleteExecution object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionTaskDidCreate:) name:BOFNetworkPromiseCreatedNewTask object:nil];
      self.isSDKEnabled = YES;
      self.isNetworkSyncEnabled = YES;
    }
    return self;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

- (void)executeNetworkPromise:(BOFNetworkPromise * _Nonnull)networkPromise {
  @try {
    if (self.isNetworkSyncEnabled && self.isSDKEnabled) {
      NSURLSessionTask* sessionTask = [networkPromise startWithSession:self.session];
      if (sessionTask && networkPromise) {
        [self.taskPromiseObjectMap setObject:networkPromise forKey:sessionTask];
      }
    } else {
      BOFLogDebug(@"BOSDK_DEBUG: %@", @"Network sync disabled by developer");
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
  @try {
    [[self.taskPromiseObjectMap objectForKey:downloadTask] BOFURLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    //didCompleteWithError is always called for any task, so remove reference of task & networkPromise in didCompleteWithError only
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  @try {
    [[self.taskPromiseObjectMap objectForKey:task] BOFURLSession:session task:task didCompleteWithError:error];
    [self.taskPromiseObjectMap removeObjectForKey:task];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
  @try {
    [[self.taskPromiseObjectMap objectForKey:dataTask] BOFURLSession:session dataTask:dataTask didReceiveData:data];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  @try {
    [[self.taskPromiseObjectMap objectForKey:downloadTask] BOFURLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
  @try {
    [[self.taskPromiseObjectMap objectForKey:downloadTask] BOFURLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
  @try {
    if ([self.delegate respondsToSelector:@selector(BOFNetworkPromiseExecutor:didBecomeInvalidWithError:)]) {
      [self.delegate BOFNetworkPromiseExecutor:self didBecomeInvalidWithError:error];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
}

@end
