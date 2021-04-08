//
//  BOASDKManifestController.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOASDKManifestController is class to fetch SDK config from server
 */

#import <Foundation/Foundation.h>
#import "BOASDKManifest.h"
#import "BOANetworkConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOASDKManifestController : NSObject

@property (strong, nonatomic) BOASDKManifest *sdkManifestModel;
@property (assign, nonatomic) BOOL isSyncedNow;

@property (assign, nonatomic) NSNumber *eventDeviceInfoGrain;
@property (assign, nonatomic) NSString *serverBaseURL;
@property (assign, nonatomic) NSString *eventPath;
@property (assign, nonatomic) NSString *piiPublicKey;
@property (assign, nonatomic) NSString *phiPublickey;
@property (assign, readwrite) bool sdkPushSystemEvents;

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

-(void)reloadManifestData;
-(void)serverSyncManifestAndAppVerification:(void (^_Nullable) (BOOL isSuccess, NSError* error))callback;
-(BOOL)isManifestAvailable;
-(NSString*)sdkManifestPathAfterWriting:(NSString*)sdkManifest;
-(NSString*)latestSDKManifestPath;
-(NSString*)latestSDKManifestJSONString;
-(NSNumber *)getNumberFrom:(NSString *)string;
-(BOASDKVariable*)getManifestVariable:(BOASDKManifest*)manifest forValue:(NSString*)value;

@end

NS_ASSUME_NONNULL_END
