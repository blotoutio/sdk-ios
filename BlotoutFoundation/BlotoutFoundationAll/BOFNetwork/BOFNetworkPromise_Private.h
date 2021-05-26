//
//  BOFNetworkPromise_Private.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#ifndef BOFNetworkPromise_Private_h
#define BOFNetworkPromise_Private_h


#import "BOFNetworkPromise.h"

FOUNDATION_EXTERN NSString * _Nonnull const BOFNetworkPromiseDidCompleteExecution;
FOUNDATION_EXTERN NSString * _Nonnull const BOFNetworkPromiseCreatedNewTask;

@class BOFNetworkPromiseExecutor;

@interface BOFNetworkPromise ()
@property (nullable, nonatomic, strong) id<BOFNetworkPromiseDeleagte> delegateForHandler;

@property (nonatomic)                    NSUInteger                 totalAttempts;
@property (nullable, nonatomic, strong)  NSURLRequest               *urlRequest;
@property (nullable, copy)               NSData                     *resumeData;
@property (nullable, nonatomic, strong)  BOFNetworkPromiseCompletionHandler completionHandler;
@property (nonatomic)                    NSTimeInterval             retryDelay;
@property (nullable, nonatomic, strong)  NSURLSessionTask           *anySessionTask;

-(nullable NSURLSessionTask*)getAsyncDownloadUrlSessionTask:(NSURLSession * _Nullable)session;
-(nullable NSURLSessionTask*)getAsyncUrlSessionTask:(NSURLSession * _Nullable)session;
-(nullable NSURLSessionTask*)getSyncUrlSessionTask:(NSURLSession * _Nullable)session;
-(void)postNotificationForTaskCompletion;

-(void)sessionTaskComplettionHandlerDownloaded:(id _Nullable)dataOrLocation response:(NSURLResponse * _Nullable) response error:(NSError * _Nullable) error session:(NSURLSession * _Nullable)session;


-(void)BOFURLSession:(NSURLSession * _Nullable)session downloadTask:(NSURLSessionDownloadTask * _Nullable)downloadTask didFinishDownloadingToURL:(NSURL * _Nullable)location;
-(void)BOFURLSession:(NSURLSession * _Nullable)session task:(NSURLSessionTask * _Nullable)task didCompleteWithError:(NSError * _Nullable)error;
-(void)BOFURLSession:(NSURLSession * _Nullable)session downloadTask:(NSURLSessionDownloadTask * _Nullable)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
-(void)BOFURLSession:(NSURLSession * _Nullable)session downloadTask:(NSURLSessionDownloadTask * _Nullable)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes;
- (void)BOFURLSession:(NSURLSession * _Nullable)session dataTask:(NSURLSessionDataTask * _Nullable)dataTask
      didReceiveData:(NSData * _Nullable)data;

@end


#endif /* BOFNetworkPromise_Private_h */
