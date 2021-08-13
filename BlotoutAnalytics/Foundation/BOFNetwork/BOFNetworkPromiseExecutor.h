//
//  BOFNetworkPromiseExecutor.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BOFNetworkPromise;
@protocol BOFNetworkPromiseExecutorDeleagte;

@interface BOFNetworkPromiseExecutor : NSObject {}
@property (nonatomic, assign) BOOL isNetworkSyncEnabled;
@property (nonatomic, assign) BOOL isSDKEnabled;
@property (nullable, nonatomic, weak)   id<BOFNetworkPromiseExecutorDeleagte> delegate;

+ (nullable instancetype)sharedInstance;
+ (nullable instancetype)sharedInstanceForCampaign;
- (void)executeNetworkPromise:(BOFNetworkPromise * _Nonnull)networkPromise;

@end

@protocol BOFNetworkPromiseExecutorDeleagte <NSObject>
- (void)BOFNetworkPromiseExecutor:(BOFNetworkPromiseExecutor * _Nonnull)networkPromiseExecutor didBecomeInvalidWithError:(NSError * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
