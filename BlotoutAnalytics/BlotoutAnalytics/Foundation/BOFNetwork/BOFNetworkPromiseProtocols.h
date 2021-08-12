//
//  BOFNetworkPromiseProtocols.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#ifndef BOFNetworkPromiseProtocols_h
#define BOFNetworkPromiseProtocols_h

#import <Foundation/Foundation.h>

@class BOFNetworkPromise;

typedef void (^downloadProgressHandler)(double percentageComplete, int64_t bytesWritten, int64_t totalBytesWritten,int64_t  totalBytesExpected);
typedef void (^downloadResumeHandler)  (int64_t resumeOffset, int64_t  totalBytesExpected);

@protocol BOFNetworkPromiseDeleagte <NSObject>
@optional
-(void)BOFNetworkPromise:(BOFNetworkPromise * _Nullable)networkDownloadPromise didFinishDownloadingToURL:(NSURL * _Nullable)location;
-(void)BOFNetworkPromise:(BOFNetworkPromise * _Nullable)networkPromise didCompleteWithError:(NSError * _Nullable)error;
-(void)BOFNetworkPromise:(BOFNetworkPromise * _Nullable)networkDownloadPromise didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
-(void)BOFNetworkPromise:(BOFNetworkPromise * _Nullable)networkDownloadPromise didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes;
- (void)BOFNetworkPromise:(BOFNetworkPromise * _Nullable)networkDataPromise didReceiveData:(NSData * _Nullable)data;

@end

#endif
