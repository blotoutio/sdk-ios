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

@property (strong, nonatomic) NSString *piiPublicKey;
@property (strong, nonatomic) NSString *phiPublickey;
@property (strong, nonatomic) NSArray *enabledSystemEvents;

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

-(void)reloadManifestData;
-(void)serverSyncManifestAndAppVerification:(void (^_Nullable) (BOOL isSuccess, NSError* error))callback;
-(BOOL)isManifestAvailable;
-(NSString*)sdkManifestPathAfterWriting:(NSString*)sdkManifest;
-(NSString*)latestSDKManifestPath;
-(NSString*)latestSDKManifestJSONString;
-(BOASDKVariable*)getManifestVariable:(BOASDKManifest*)manifest forID:(int)ID;
-(BOOL)isSystemEventEnabled:(int)eventCode;

@end

NS_ASSUME_NONNULL_END
