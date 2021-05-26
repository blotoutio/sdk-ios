//
//  BOANonPiiEvents.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOARetentionEvents.h"
#import "BOAppSessionData.h"
#import "BOAAppLifetimeData.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import "BOAConstants.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BlotoutAnalytics.h"
#import "BOANotificationConstants.h"
#import "BOSharedManager.h"

static BOOL DAUSet = NO;
static BOOL DPUSet = NO;
static BOOL DASTSet = NO;
static BOOL NUOTSet = NO;
static BOOL AppInstalledTSet = NO;

static id sBOARetentionEvnetsSharedInstance = nil;
@implementation BOARetentionEvents

-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaRetentionEventsOnceToken = 0;
    dispatch_once(&boaRetentionEventsOnceToken, ^{
        sBOARetentionEvnetsSharedInstance = [[[self class] alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordDPUwithPayload:) name:BO_ANALYTICS_IS_PAYING_USER object:nil];
    });
    return  sBOARetentionEvnetsSharedInstance;
}

-(void)recordDAUwithPayload:(nullable NSDictionary*)eventInfo{
    @try {
        if (BOAEvents.isSessionModelInitialised) {
            BODau *dau = [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.dau;
            @synchronized (dau) {
                if (!dau && !DAUSet) {
                    DAUSet = YES;
                    id infoActiveUser = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : @{@"date":[BOAUtilities dateStringInFormat:@"yyyy-MM-dd"]};
                    BODau *dau = [BODau fromJSONDictionary:@{
                        @"sentToServer":[NSNumber numberWithBool:NO],
                        @"mid": [BOAUtilities getMessageIDForEvent:@"DAU"],
                        @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                        @"dauInfo":infoActiveUser,
                        @"session_id":[BOSharedManager sharedInstance].sessionId
                    }
                                  ];
                    [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent setDau:dau];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordDPUwithPayload:(nullable NSNotification*)eventInfo{
    @try {
        if (BOAEvents.isSessionModelInitialised) {
            BODpu *dpu = [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.dpu;
            @synchronized (dpu) {
                BOOL isPayUser =  [BlotoutAnalytics sharedInstance].isPayingUser;
                if (!dpu && isPayUser && !DPUSet) {
                    DPUSet = YES;
                    id infoPayingUser = (eventInfo.userInfo && (eventInfo.userInfo.allKeys.count>0))  ? eventInfo : @{@"date":[BOAUtilities dateStringInFormat:@"yyyy-MM-dd"]};
                    BODpu *dpu = [BODpu fromJSONDictionary:@{
                        @"sentToServer":[NSNumber numberWithBool:NO],
                        @"mid": [BOAUtilities getMessageIDForEvent:@"DPU"],
                        @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                        @"dpuInfo":infoPayingUser,
                        @"session_id":[BOSharedManager sharedInstance].sessionId
                    }
                                  ];
                    [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent setDpu:dpu];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordAppInstalled:(BOOL)isFirstLaunch withPayload:(nullable NSDictionary*)eventInfo{
    @try {
        BOOL isSDKFirstLaunch = [BOFFileSystemManager isFirstLaunchBOSDKFileSystemCheck];
        if (BOAEvents.isSessionModelInitialised && isSDKFirstLaunch) {
            BOAppInstalled *appInstalled = [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.appInstalled;
            if(appInstalled == nil) {
                id appInstalledInfo = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : @{@"date":[BOAUtilities dateStringInFormat:@"yyyy-MM-dd"]};
                BOOL isAppFirstLaunch = [BOFFileSystemManager isAppFirstLaunchFileSystemChecks];
                if (isAppFirstLaunch && !AppInstalledTSet) {
                    //Check for reinstall case
                    AppInstalledTSet = YES;
                    NSString *documentsDir = [BOFFileSystemManager getDocumentDirectoryPath];
                    NSDictionary* docDirfileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:documentsDir error:nil];
                    NSDate *documentsDirCrDate = [docDirfileAttribs fileCreationDate];
                    
                    BOAppInstalled *appInstalled = [BOAppInstalled
                                                    fromJSONDictionary:@{
                                                        @"sentToServer":[NSNumber numberWithBool:NO],
                                                        @"mid": [BOAUtilities getMessageIDForEvent:@"AppInstalled"],
                                                        @"isFirstLaunch":[NSNumber numberWithBool:isAppFirstLaunch],
                                                        @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStampFor:documentsDirCrDate],
                                                        @"appInstalledInfo":appInstalledInfo,
                                                        @"session_id":[BOSharedManager sharedInstance].sessionId
                                                    }
                                                    ];
                    [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent setAppInstalled:appInstalled];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordNewUser:(BOOL)isNewUser withPayload:(nullable NSDictionary*)eventInfo{
    @try {
        if (BOAEvents.isSessionModelInitialised) {
            BONewUser *newUser = [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.theNewUser;
            if(newUser == nil) {
                id newUserInfo = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : @{@"date":[BOAUtilities dateStringInFormat:@"yyyy-MM-dd"]};
                BOOL isNewUserInstallCheck = [BOFFileSystemManager isFirstLaunchBOSDKFileSystemCheck];
                NSNumber *timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                if (isNewUserInstallCheck && !NUOTSet) {
                    NUOTSet = YES;
                    BONewUser *newUser = [BONewUser fromJSONDictionary:@{
                        @"sentToServer":[NSNumber numberWithBool:NO],
                        @"mid":[BOAUtilities getMessageIDForEvent:@"NewUser"],
                        @"timeStamp":timeStamp,
                        @"isNewUser":[NSNumber numberWithBool:isNewUserInstallCheck],
                        @"theNewUserInfo":newUserInfo,
                        @"session_id":[BOSharedManager sharedInstance].sessionId
                    }
                                          ];
                    [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent setTheNewUser:newUser];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

//WIP for previous session DAST calculation
-(void)storeDASTupdatedSessionFile:(BOAppSessionData*)apSessionData{
    if (apSessionData) {
        NSError *error = nil;
        NSString *apSessionDataJsonString = [apSessionData toJSON:NSUTF8StringEncoding error:&error];
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        BOFLogDebug(@"analyticsRootUD %@", analyticsRootUD);
        [analyticsRootUD setObject:apSessionDataJsonString forKey:BO_ANALYTICS_SESSION_MODEL_DEFAULTS_KEY];
    }
}

//Need to check with backend team if this event need to be send once only for previous day else they might receive multiple
-(void)recordDAST:(NSNumber*)averageTime forSession:(NSDictionary*)sessionDict withPayload:(nullable NSDictionary<NSString *, NSString *>*)eventInfo{
    @try {
        if (sessionDict && (sessionDict.allKeys.count > 0)) {
            
            BOAppSessionData *apSessionData = [BOAppSessionData fromJSONDictionary:sessionDict];
            BODast *dast = apSessionData.singleDaySessions.retentionEvent.dast;
            
            if(apSessionData && (dast == nil) && !DASTSet) {
                DASTSet = YES;
                NSDictionary<NSString *, NSString *> *averageSessionInfo = eventInfo ? NSNullifyDictCheck(eventInfo) : @{@"date":[BOAUtilities dateStringInFormat:@"yyyy-MM-dd"]};
                NSNumber *averageSessionTime = averageTime != nil ? averageTime : [apSessionData.singleDaySessions.appInfo lastObject].averageSessionsDuration;
                BODast *dast = [BODast fromJSONDictionary:@{
                    @"sentToServer":[NSNumber numberWithBool:NO],
                    @"mid": [BOAUtilities getMessageIDForEvent:@"DAST"],
                    @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                    @"averageSessionTime":averageSessionTime,
                    @"payload":averageSessionInfo,
                    @"session_id":[BOSharedManager sharedInstance].sessionId
                }
                                ];
                [apSessionData.singleDaySessions.retentionEvent setDast:dast];
                [self storeDASTupdatedSessionFile:apSessionData];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordCustomEventsWithName:(NSString*)eventName andPaylod:(nullable NSDictionary*)eventInfo{
    @try {
        if (BOAEvents.isSessionModelInitialised) {
            id costumEventInfo = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : @{@"date":[BOAUtilities dateStringInFormat:@"yyyy-MM-dd"]};
            BOCustomEvent *customEvents = [BOCustomEvent fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent:eventName],
                @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                @"eventInfo":costumEventInfo,
                @"eventSubCode": [BOAUtilities codeForCustomCodifiedEvent:eventName],
                @"eventName":eventName,
                @"visibleClassName" : [NSString stringWithFormat:@"%@",[[self topViewController] class]],
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }
                                           ];
            
            NSMutableArray *existingCustomEvents = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.customEvents mutableCopy];
            [existingCustomEvents addObject:customEvents];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent setCustomEvents:existingCustomEvents];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

@end
