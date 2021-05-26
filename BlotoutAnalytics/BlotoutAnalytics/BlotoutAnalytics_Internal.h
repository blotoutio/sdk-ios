//
//  BlotoutAnalytics_Internal.h
//  BlotoutAnalytics
//
//  Created by Blotout on 16/02/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#ifndef BlotoutAnalytics_Internal_h
#define BlotoutAnalytics_Internal_h

#import "BlotoutAnalytics.h"
#import "BOAEvents.h"
#import "BOADeveloperEvents.h"
#import "BOAAppSessionEvents.h"
#import "BOARetentionEvents.h"
#import "BOADeviceEvents.h"
#import "BOAPiiEvents.h"
#import "BOAConstants.h"
#import <BlotoutFoundation/BlotoutFoundation.h>
#import <BlotoutFoundation/BOFSystemServices.h>
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import "UIViewController+Extensions.h"
#import "UIApplication+Extensions.h"
#import "BOALifeTimeAllEvent.h"
#import "BOAFunnelSyncController.h"
#import "BOASDKManifestController.h"
#import "BOASegmentsSyncController.h"
#import "BOADeviceAndAppFraudController.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOACommunicatonController.h"
#import <BlotoutFoundation/BOFNetworkPromiseExecutor.h>
#import "BOANotificationConstants.h"
#import "BOPendingEvents.h"

@interface BlotoutAnalytics ()

@property (nonatomic, readwrite) BOOL isDevModeEnabled;
@property (nonatomic, readwrite) BOOL isProductionMode;
@property (strong, nonatomic) NSString * _Nonnull testBlotoutKey;
@property (strong, nonatomic) NSString * _Nonnull prodBlotoutKey;

@property (readwrite, nonatomic) BOOL sdkInitConfirmationSend;
@property (strong, nonatomic, nullable) NSMutableArray * sdkInitPendingEventLoader;

//Server Endpoint Url e.g. https://blotout.io, http://blotout.io, It has to be a domain based, IP's are considered invalid.
@property (nonatomic, strong, nullable) NSString *SDKEndPointUrl;


+(BOOL)isSDKInProductionMode;
+(NSString*_Nullable)blotoutSDKTestEnvKey;
+(NSString*_Nullable)blotoutSDKProdEnvKey;

@end

#endif /* BlotoutAnalytics_Internal_h */
