//
//  BOASDKManifestController.h
//  BlotoutAnalytics
//
//  Created by Blotout on 16/11/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOASDKManifestController is class to fetch SDK config from server
 */

#import <Foundation/Foundation.h>
#import "BOASDKManifest.h"
#import "BOASDKManifestConstants.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BO_DEPLOYMENT_MODE) {
    BO_DEPLOYMENT_MODE_PRIVACY_ANALYTICS  = 0,
    BO_DEPLOYMENT_MODE_FIRST_PARTY= 1
};


@interface BOASDKManifestController : NSObject

@property (strong, nonatomic) BOASDKManifest *sdkManifestModel;
@property (assign, nonatomic) BOOL isSyncedNow;

@property (assign, nonatomic) BOOL networkCutoffReached;
@property (assign, nonatomic) BOOL storageCutoffReached;
@property (assign, nonatomic) BOOL sdkPushSystemEvents;
@property (assign, nonatomic) BOOL sdkPushPIIEvents;
@property (assign, nonatomic) BOOL sdkPushPHIEvents;
@property (assign, nonatomic) BOOL sdkMapUserId;
@property (assign, nonatomic) BOOL sdkBehaviourEvents;

@property (assign, nonatomic) NSNumber *eventPushThresholdInterval;
@property (assign, nonatomic) NSNumber *eventPushThresholdEventCounter;
@property (assign, nonatomic) NSNumber *eventGEOLocationGrain;
@property (assign, nonatomic) NSNumber *eventDeviceInfoGrain;
@property (assign, nonatomic) NSNumber *eventSystemMergeCounter;
@property (assign, nonatomic) NSNumber *eventCodifiedMergeCounter;
@property (assign, nonatomic) NSNumber *eventOfflineInterval;
@property (assign, nonatomic) NSNumber *licenseExpireDayAlive;
@property (assign, nonatomic) NSNumber *intervalManifestRefresh;
@property (assign, nonatomic) NSNumber *intervalStoreEvents;
@property (assign, nonatomic) NSNumber *intervalRetryInterval;
@property (assign, nonatomic) NSString *serverBaseURL;
@property (assign, nonatomic) NSString *geoIPPath;
@property (assign, nonatomic) NSString *eventFunnelPath;
@property (assign, nonatomic) NSString *eventFunnelPathsFeedback;
@property (assign, nonatomic) NSString *eventRetentionPath;
@property (assign, nonatomic) NSString *eventPath;
@property (assign, nonatomic) NSString *segmentPath;
@property (assign, nonatomic) NSString *segmentPathFeedback;
@property (assign, nonatomic) NSString *manifestPath;
@property (assign, nonatomic) NSString *piiPublicKey;
@property (assign, nonatomic) NSString *phiPublickey;
@property (assign, nonatomic) BOOL sdkDeploymentMode;

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

-(void)reloadManifestData;
-(void)serverSyncManifestAndAppVerification:(void (^_Nullable) (BOOL isSuccess, NSError* error))callback;

-(id)requiredValueUsingModelOfVariableNameKeyValue:(NSString*)value;
-(NSDictionary*)dictContainingValue:(NSString*)value;
-(id)requiredValueUsingDictForVariableNameKeyValue:(NSString*)value;
-(BOASDKVariable*)requiredVariableObjectUsingModelOfVariableNameKeyValue:(NSString*)value;
-(NSString*)getAPIEndPointFromManifestFor:(NSString*)manifestVarName;
-(BOOL)isManifestAvailable;

-(NSString*)sdkManifestPathAfterWriting:(NSString*)sdkManifest;

-(NSString*)latestSDKManifestPath;
-(NSString*)latestSDKManifestJSONString;

-(void)syncManifestWithServer;

-(NSTimeInterval) manifestRefreshInterval;
-(void)setupManifestExtraParamOnSuccess;
-(void)setupManifestExtraParamOnFailure;
-(NSNumber *)getNumberFrom:(NSString *)string;
-(BOASDKVariable*)getManifestVariable:(BOASDKManifest*)manifest forValue:(NSString*)value;
- (int) delayInterval;
-(NSNumber*)getStoreInterval;
@end

NS_ASSUME_NONNULL_END
