//
//  BOFNetworkPromise.h
//  BlotoutFoundation
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOFNetworkPromiseProtocols.h"

NS_ASSUME_NONNULL_BEGIN

// dataOrLocation will be either NSData or NSUrl
// Based on BOANetworkPromise executed as data promise or download promise
// If resumeData or downloadAsFile is set then BOANetworkPromise will be executed as download promise else determined by system.
typedef void (^BOFNetworkPromiseCompletionHandler)( NSURLResponse * _Nullable urlResponse, id _Nullable dataOrLocation, NSError * _Nullable error);

typedef NS_ENUM(NSInteger, BOFNetworkPromiseTaskState) {
  BOFNetworkPromiseTaskStateRunning = 0,
  BOFNetworkPromiseTaskStateSuspended = 1,
  BOFNetworkPromiseTaskStateCanceling = 2,
  BOFNetworkPromiseTaskStateCompleted = 3,
} NS_ENUM_AVAILABLE(NSURLSESSION_AVAILABLE, 7_0);

FOUNDATION_EXPORT const float BOFNetworkPromiseTaskPriorityDefault NS_AVAILABLE(10_10, 8_0);
FOUNDATION_EXPORT const float BOFNetworkPromiseTaskPriorityLow NS_AVAILABLE(10_10, 8_0);
FOUNDATION_EXPORT const float BOFNetworkPromiseTaskPriorityHigh NS_AVAILABLE(10_10, 8_0);

@class BOFNetworkPromiseFileHandler, BOFNetworkPromiseStringHandler, BOFNetworkPromiseJSONHandler, BOFNetworkPromiseXMLHandler;

@interface BOFNetworkPromise : NSObject { }
@property (nullable, nonatomic, strong) id<BOFNetworkPromiseDeleagte> delegate;
@property(nonatomic) NSInteger numberOfRetries;
@property (readwrite) BOOL downloadAsFile;   //default download will try to download as NSData, like data task.
@property (nullable, copy) NSString *networkPromiseDescription;
@property (readonly) NSUInteger networkPromiseIdentifier;
@property (nullable, readonly, copy) NSURLRequest *originalRequest;
@property (nullable, readonly, copy) NSURLRequest *currentRequest;
@property (nullable, readonly, copy) NSURLResponse *response;
@property (nullable, readonly, strong) NSMutableData *responseData;

@property (readonly) BOFNetworkPromiseTaskState state;
@property (nullable, readonly, copy) NSError *error;
@property float priority NS_AVAILABLE(10_10, 8_0);

- (nullable instancetype)initWithURLRequest:(nonnull NSURLRequest *)request completionHandler:(_Nullable BOFNetworkPromiseCompletionHandler)networkPromiseCompletionHandler;
- (nullable instancetype)initWithResumeData:(NSData * _Nonnull)resumedData completionHandler:(_Nullable BOFNetworkPromiseCompletionHandler)networkPromiseCompletionHandler;
- (nullable instancetype)initWithURLRequest:(nonnull NSURLRequest *)request responseHandler:( id<BOFNetworkPromiseDeleagte> _Nonnull)networkResponseHandler;

//Set this if fileDownload is required at a specifc location, will try to move if provided directory is writable else will return default download location
@property (nullable, nonatomic, strong) NSURL   *downloadLocation;
@property (nullable, nonatomic, strong) NSError *relocationErr;

- (NSURLSessionTask* _Nullable)startWithSession:(NSURLSession * _Nullable)session;

- (void)cancel;
- (void)suspend;
- (void)resume;
// To call this on networkpromise object, either of this must be true i.e downloadAsFile set to true or initiated with resume data
- (void)cancelByProducingResumeData:(nullable void (^)(NSData * __nullable resumeData))completionHandler;
@end


NS_ASSUME_NONNULL_END
