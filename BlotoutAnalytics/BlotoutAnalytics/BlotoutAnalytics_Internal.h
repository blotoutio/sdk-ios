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

/**
 *Default Value is YES, only set to NO when you want to disable SDK
 *Once you disable SDK, SDK won't collect any further information but already collected informtion,
 *will be sent to server as per Blotout Contract
 */
@property (nonatomic, readwrite) BOOL isEnabled;

//for disable data write on disk
@property (nonatomic, readwrite) BOOL isDataCollectionEnabled;
//for disable network
@property (nonatomic, readwrite) BOOL isNetworkSyncEnabled;

//Individual Module enable or disable control
//System Events, which SDK detect automatically
@property (nonatomic, readwrite) BOOL isSystemEventsEnabled;
//Rentention Events, which SDK detect for retention tracking like DAU, MAU
@property (nonatomic, readwrite) BOOL isRetentionEventsEnabled;
//Funnel Events, which SDK process for funnel analysis
@property (nonatomic, readwrite) BOOL isFunnelEventsEnabled;
//Segments Events, which SDK process for segment analysis
@property (nonatomic, readwrite) BOOL isSegmentEventsEnabled;
//Developer Codified Events, which SDK collects when developer send some events
@property (nonatomic, readwrite) BOOL isDeveloperEventsEnabled;
//if user is a payingUser
@property (nonatomic, readwrite) BOOL isPayingUser;

//Enable SDK Log Information
@property (nonatomic, readwrite) BOOL isSDKLogEnabled;

// return sdk version
-(nonnull NSString*)sdkVersion;

//Fraud Services
-(BOOL)isDeviceCompromised;
-(BOOL)isAppCompromised;
-(BOOL)isNetworkProxied;
-(BOOL)isSimulator;
-(BOOL)isRunningOnVM;
-(BOOL)isEnvironmentSecure;

-(void)setPayingUser:(BOOL)payingUser;

-(void)startTimedEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)startEventInfo;

-(void)endTimedEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)endEventInfo;

-(void)logUserRetentionEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo;

-(void)logEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime;

-(void)logPIIEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime;

/**
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 * @param eventTime eventTime as Date
 */
-(void)logPHIEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime;


+(BOOL)isSDKInProductionMode;
+(NSString*_Nullable)blotoutSDKTestEnvKey;
+(NSString*_Nullable)blotoutSDKProdEnvKey;

@end

#endif /* BlotoutAnalytics_Internal_h */
