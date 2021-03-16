//
//  BOASessionEvents.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAAppSessionEvents.h"
#import <UIKit/UIKit.h>
#import "BOAConstants.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import <BlotoutFoundation/BOFSystemServices.h>
#import <BlotoutFoundation/BOFNetworkPromise.h>
#import <BlotoutFoundation/BOFNetworkPromiseExecutor.h>

#import "BOALocalDefaultJSONs.h"
#import "BOAppSessionData.h"
#import "BOAAppLifetimeData.h"
#import "BOALifeTimeAllEvent.h"
#import <UserNotifications/UserNotifications.h>

#import "BOARetentionEvents.h"
#import "BOAJSONQueryEngine.h"

#import "BOAFunnelSyncController.h"
#import "BOANotificationConstants.h"
#import "BOACommunicatonController.h"
#import "BlotoutAnalytics_Internal.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "NSError+BOAdditions.h"
#import "BOANetworkConstants.h"
#import "BOManifestGeoAPI.h"
#import "BOSharedManager.h"
#import "BONetworkEventService.h"

static id sBOFAppSessionSharedInstance = nil;

@interface BOAAppSessionEvents () <UNUserNotificationCenterDelegate>{
    BOAppSessionData *appSessionModel;
    BOAAppLifetimeData *appLifeTimeModel;
    NSInteger averageSessionDuration;
    BOOL requestInProgress;
}

@end

@implementation BOAAppSessionEvents

-(instancetype)init{
    self = [super init];
    if (self) {
        requestInProgress = NO;
        averageSessionDuration = 0;
        self.sessionAppInfo = [NSMutableDictionary dictionary];
        [self registerForNotifications];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaAppSessionOnceToken = 0;
    dispatch_once(&boaAppSessionOnceToken, ^{
        sBOFAppSessionSharedInstance = [[[self class] alloc] init];
    });
    return  sBOFAppSessionSharedInstance;
}

-(void)startRecordingEvnets{
    self.isEnabled = YES;
}

-(void)stopRecordingEvnets{
    self.isEnabled = NO;
}

-(void)averageAppSessionDurationForTheDay{
    @try {
        //App Did Launch
        [self recordSystemUptime:nil];
        NSNumber *terminationTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
        [self.sessionAppInfo setObject:terminationTimeStamp forKey:@"terminationTimeStamp"];
        
        NSNumber *launchTimeStamp = [self.sessionAppInfo objectForKey:@"launchTimeStamp"];
        NSNumber *sessionDuration = [NSNumber numberWithInteger:([terminationTimeStamp integerValue] - [launchTimeStamp integerValue])];
        [self.sessionAppInfo setObject:sessionDuration forKey:@"sessionsDuration"];
        
        NSInteger numberOfSesisons = [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appInfo.count + 1;
        NSInteger allSessionDuration = [sessionDuration integerValue];
        for (BOAppInfo *appInfo in [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appInfo) {
            NSNumber *sessionDuration = appInfo.sessionsDuration != nil ? appInfo.sessionsDuration : [NSNumber numberWithInteger:0];
            allSessionDuration = allSessionDuration + [sessionDuration integerValue];
        }
        averageSessionDuration = allSessionDuration / numberOfSesisons;
        [self.sessionAppInfo setObject:[NSNumber numberWithInteger:averageSessionDuration] forKey:@"averageSessionsDuration"];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordSessionOnDayChangeOrAppTermination:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler{
    @try {
        if (averageSessionDuration <= 0) {
            [self averageAppSessionDurationForTheDay];
        }
        
        if (BOAEvents.isSessionModelInitialised && (self.sessionAppInfo.allKeys.count > 0)) {
            BOAppInfo *appInfo = [BOAppInfo fromJSONDictionary:self.sessionAppInfo];
            NSMutableArray *existingAppInfo = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appInfo mutableCopy];
            [existingAppInfo addObject:appInfo];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setAppInfo:existingAppInfo];
        }
        
        NSError *error = nil;
        NSString *jsonString = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil] toJSON:NSUTF8StringEncoding error:&error];
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        BOFLogDebug(@"analyticsRootUD %@", analyticsRootUD);
        [analyticsRootUD setObject:jsonString forKey:BO_ANALYTICS_SESSION_MODEL_DEFAULTS_KEY];
        
        completionHandler(YES, nil);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        completionHandler(NO, [NSError boErrorForDict:exception.userInfo]);
    }
}

-(void)recordLifeTimeOnDayChangeOrAppTermination:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler{
    @try {
        BOAAppLifetimeData *lifeTimeDataModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
        NSError *error = nil;
        NSString *lifeTimeModelJsonString = [lifeTimeDataModel toJSON:NSUTF8StringEncoding error:&error];
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        [analyticsRootUD setObject:lifeTimeModelJsonString forKey:BO_ANALYTICS_LIFETIME_MODEL_DEFAULTS_KEY];
        
        completionHandler(YES, nil);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        completionHandler(NO, [NSError boErrorForDict:exception.userInfo]);
    }
}

-(void)resetAverageSessionDuration{
    averageSessionDuration = 0;
}

-(void)appTerminationFunctionalityOnDayChange{
    @try {
        [self recordSessionOnDayChangeOrAppTermination:^(BOOL isSuccess, NSError * _Nullable error) {
            [self recordLifeTimeOnDayChangeOrAppTermination:^(BOOL isSuccess, NSError * _Nullable error) {
                [self resetAverageSessionDuration];
            }];
        }];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

//------ Notificaitons -----------
-(void)recordSessionInfo:(BOAppSessionData*)sInstance {
    BOSessionInfo *sessionInfo = [BOSessionInfo fromJSONDictionary:@{
        BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
        BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_LAUNCHED], // discuss this
        BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
        BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
        BO_START:[BOAUtilities get13DigitNumberObjTimeStamp]
    }];
    NSMutableArray *existingData = [sInstance.singleDaySessions.appStates.appSessionInfo mutableCopy];
    [existingData addObject:sessionInfo];
    [sInstance.singleDaySessions.appStates setAppSessionInfo:existingData];
}

-(void)recordAppLaunched:(BOAppSessionData*)sInstance{
    BOApp *appStates = [BOApp fromJSONDictionary:@{
        BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
        BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_LAUNCHED], // discuss this
        BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
        BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
        BO_VISIBLE_CLASS_NAME:[NSString stringWithFormat:@"%@",[[self topViewController] class]]
    }];
    NSMutableArray *existingData = [sInstance.singleDaySessions.appStates.appLaunched mutableCopy];
    [existingData addObject:appStates];
    [sInstance.singleDaySessions.appStates setAppLaunched:existingData];
    
}
-(void)recordNotificationsInBackgroundWith:(NSDictionary*)notificationData{
    @try {
        if (BOAEvents.isSessionModelInitialised) {
            
            BOAppSessionData *sInstance = [BOAppSessionData sharedInstanceFromJSONDictionary:nil];
            [self recordAppLaunched:sInstance];
            [self recordSessionInfo:sInstance];
            
            if (!sInstance.appBundle) {
                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                [sInstance setAppBundle:bundleIdentifier];
            }
            
            NSDate *currentDateL = [BOAUtilities getCurrentDate];
            if (!sInstance.date && currentDateL) {
                NSString *sessionDate = [BOAUtilities convertDate:currentDateL inFormat:@"yyyy-MM-dd"];
                if ((sessionDate && (sessionDate.length == 10) && ![sessionDate isEqualToString:@""])) {
                    [sInstance setDate:sessionDate];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordSystemUptime:(nullable NSNumber*)time{
    @try {
        // Get the info about a process
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        // Get the uptime of the system
        NSTimeInterval systemUptime = [processInfo systemUptime];
        NSNumber *systemUptimeN = time != nil ?  time : [NSNumber numberWithDouble:systemUptime];
        NSMutableArray *existingSystemUptime = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.systemUptime mutableCopy];
        [existingSystemUptime addObject:systemUptimeN];
        [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setSystemUptime:existingSystemUptime];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)decideAndRecordLaunchReason:(nullable NSNotification*)notification{
    @try {
        if (notification && notification.userInfo) {
            //Store string represenation of all the objects
            id launchURL = [notification.userInfo objectForKey:UIApplicationLaunchOptionsURLKey];
            if (launchURL) {
                [self.sessionAppInfo setObject:launchURL forKey:@"launchReason"];
            }else{
                [self.sessionAppInfo setObject:@"UserLaunch" forKey:@"launchReason"];
            }
            id appBundleID = [notification.userInfo objectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
            if (appBundleID) {
                [self.sessionAppInfo setObject:appBundleID forKey:@"launchReason"];
            }
            id appRemoteNoti = [notification.userInfo objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (appRemoteNoti) {
                [self.sessionAppInfo setObject:appRemoteNoti forKey:@"launchReason"];
            }
            id appLocalNoti = [notification.userInfo objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
            if (appLocalNoti) {
                [self.sessionAppInfo setObject:appLocalNoti forKey:@"launchReason"];
            }
            id appAnnotation = [notification.userInfo objectForKey:UIApplicationLaunchOptionsAnnotationKey];
            if (appAnnotation) {
                [self.sessionAppInfo setObject:appAnnotation forKey:@"launchReason"];
            }
            id appLocation = [notification.userInfo objectForKey:UIApplicationLaunchOptionsLocationKey];
            if (appBundleID) {
                [self.sessionAppInfo setObject:appLocation forKey:@"launchReason"];
            }
            id appNewsStand = [notification.userInfo objectForKey:UIApplicationLaunchOptionsNewsstandDownloadsKey];
            if (appNewsStand) {
                [self.sessionAppInfo setObject:appNewsStand forKey:@"launchReason"];
            }
            id appBTCentral = [notification.userInfo objectForKey:UIApplicationLaunchOptionsBluetoothCentralsKey];
            if (appBTCentral) {
                [self.sessionAppInfo setObject:appBTCentral forKey:@"launchReason"];
            }
            id appBTPeripheral = [notification.userInfo objectForKey:UIApplicationLaunchOptionsBluetoothPeripheralsKey];
            if (appBTPeripheral) {
                [self.sessionAppInfo setObject:appBTPeripheral forKey:@"launchReason"];
            }
            id appShortcuts = [notification.userInfo objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
            if (appShortcuts) {
                [self.sessionAppInfo setObject:appShortcuts forKey:@"launchReason"];
            }
            id appUserActivity = [notification.userInfo objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
            if (appUserActivity) {
                [self.sessionAppInfo setObject:appUserActivity forKey:@"launchReason"];
            }
            id appUserActivityType = [notification.userInfo objectForKey:UIApplicationLaunchOptionsUserActivityTypeKey];
            if (appUserActivityType) {
                [self.sessionAppInfo setObject:appUserActivityType forKey:@"launchReason"];
            }
            if (@available(iOS 10.0, *)) {
                id appCloudKit = [notification.userInfo objectForKey:UIApplicationLaunchOptionsCloudKitShareMetadataKey];
                if (appCloudKit) {
                    [self.sessionAppInfo setObject:appCloudKit forKey:@"launchReason"];
                }
            } else {
                // Fallback on earlier versions
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordAppInformation:(nullable NSNotification*)notification{
    @try {
        NSNumber *launchTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
        [self.sessionAppInfo setObject:launchTimeStamp forKey: BO_LAUNCH_TIME_STAMP];
        
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString * versionAndBundle = [NSString stringWithFormat:@"%@.%@", appVersionString,appBuildString];
        [self.sessionAppInfo setObject:NSNullifyCheck(versionAndBundle) forKey: BO_VERSION];
        
        NSString * sdkVersion = [NSString stringWithFormat:@"%d.%d.%d", BOSDK_MAJOR_VERSION,BOSDK_MINOR_VERSION,BOSDK_PATCH_VERSION];
        [self.sessionAppInfo setObject:NSNullifyCheck(sdkVersion) forKey: BO_SDK_VERSION];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        [self.sessionAppInfo setObject:NSNullifyCheck(bundleIdentifier) forKey: BO_BUNDLE];
        
        NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *prodName = [bundleInfo objectForKey:@"CFBundleExecutable"]; //CFBundleName
        [self.sessionAppInfo setObject:NSNullifyCheck(prodName) forKey: BO_NAME]; //Check this, coming as SalesDemoApp, which is app name
        [self.sessionAppInfo setObject:NSNullifyCheck([BOFSystemServices sharedServices].language) forKey: BO_LANGUAGE];
        
        [self.sessionAppInfo setObject:[NSNumber numberWithInt:[BOAUtilities currentPlatformCode]] forKey: BO_PLATFORM];
        
        NSString *osn = [BOFSystemServices sharedServices].systemName ? [BOFSystemServices sharedServices].systemName : @"-1";
        [self.sessionAppInfo setObject:osn forKey: BO_OS_NAME];
        
        NSString *osv = [BOFSystemServices sharedServices].systemsVersion ? [BOFSystemServices sharedServices].systemsVersion : @"-1";
        [self.sessionAppInfo setObject:osv forKey: BO_OS_VERSION];
        
        NSString *dmft = @"Apple";
        [self.sessionAppInfo setObject:dmft forKey: BO_DEVICE_MFT];
        
        NSString *dModel = [BOFSystemServices sharedServices].deviceModel ? [BOFSystemServices sharedServices].deviceModel : @"NA";
        [self.sessionAppInfo setObject:dModel forKey: BO_DEVICE_MODEL];
        
        int isProxied = [BOADeviceAndAppFraudController isConnectionProxied] ? 1 : 0;
        [self.sessionAppInfo setObject:[NSNumber numberWithBool:isProxied] forKey: BO_VPN_STATUS];
        
        int jbnStatus = [BOADeviceAndAppFraudController isDeviceJailbroken] ? 1 : 0;
        [self.sessionAppInfo setObject:[NSNumber numberWithBool:jbnStatus] forKey: BO_JBN_STATUS];
        
        BOOL isDyLibInjected = [BOADeviceAndAppFraudController isDylibInjectedToProcessWithName:@"dylib_name"] && [BOADeviceAndAppFraudController isDylibInjectedToProcessWithName:@"libcycript"];
        int dcomp = (isDyLibInjected || jbnStatus) ?  1 : 0;
        int acomp = isDyLibInjected ?  1 : 0;
        
        [self.sessionAppInfo setObject:[NSNumber numberWithBool:dcomp] forKey: BO_DCOMP_STATUS];
        [self.sessionAppInfo setObject:[NSNumber numberWithBool:acomp] forKey: BO_ACOMP_STATUS];
        
        int timeOffset = [BOAUtilities getCurrentTimezoneOffsetInMin];
        [self.sessionAppInfo setObject:[NSNumber numberWithInt:timeOffset] forKey: BO_TIME_ZONE_OFFSET];
        
        __block BOAAppSessionEvents *blockSelf = self;
        [self getGeoIPAndPublishWith:^(NSDictionary *currentLocation, NSError * _Nullable error) {
            [blockSelf.sessionAppInfo setObject:NSNullifyDictCheck(currentLocation) forKey: BO_CURRENT_LOCATION];
        }];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)storeGeoLocation:(NSDictionary *)currentLocation{
    if (currentLocation && (currentLocation.allValues.count > 0)) {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSString *currentLocStr = [BOAUtilities jsonStringFrom:currentLocation withPrettyPrint:NO];
        [analyticsRootUD setObject:currentLocStr forKey:BO_ANALYTICS_CURRENT_LOCATION_DICT];
    }
}

-(NSDictionary*)getGeoIPAndPublishWith:(void (^)(NSDictionary *currentLocation, NSError * _Nullable error))completionHandler{
    @try {
        //TODO: change end point when BO Geo-IP REST API is deployed
        if (!self.isEnabled) {
            return nil;
        }
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSString *currLocStr = [analyticsRootUD objectForKey:BO_ANALYTICS_CURRENT_LOCATION_DICT];
        NSDictionary *cKnownLocation = currLocStr ? [BOAUtilities jsonObjectFromString:currLocStr] : nil;
        
        BOOL fetchNewLocation = YES;
        if (cKnownLocation) {
            NSNumber *lastLocTimeStamp = [cKnownLocation objectForKey:@"timeStamp"];
            NSInteger currTime = [BOAUtilities get13DigitIntegerTimeStamp];
            
            NSInteger  diffMilli =  currTime - [lastLocTimeStamp integerValue];
            NSInteger  dayMilli = 24*60*60*1000;
            if (diffMilli < dayMilli) {
                fetchNewLocation = NO;
            }
        }
        
        if (requestInProgress || !fetchNewLocation) {
            return cKnownLocation;
        }
        
        __block NSString *country = [BOFSystemServices sharedServices].country;
        __block NSString *state = nil;
        __block NSString *city = nil;
        __block NSString *zip = nil;
        __block NSString *continentCode = nil;
        __block NSNumber *latitude = nil;
        __block NSNumber *longitude = nil;
        __block NSNumber *timeStamp = nil;
        
        __block NSDictionary *cNewLocationDict = nil;
        
        if (fetchNewLocation) {
            BOManifestGeoAPI *geoAPI = [[BOManifestGeoAPI alloc] init];
            [geoAPI getGeoData:nil success:^(id  _Nonnull responseObject, id  _Nonnull data) {
                self->requestInProgress = NO;
                @try {
                    NSDictionary *jsonDict = (NSDictionary*)responseObject;
                    
                    NSDictionary *geoData = [jsonDict objectForKey:@"geo"];
                    if ([geoData.allKeys containsObject:@"couc"]) {
                        country = [geoData objectForKey:@"couc"];
                    }
                    if ([geoData.allKeys containsObject:@"reg"]) {
                        state = [geoData objectForKey:@"reg"];
                    }
                    if ([geoData.allKeys containsObject:@"city"]) {
                        city = [geoData objectForKey:@"city"];
                    }
                    if ([geoData.allKeys containsObject:@"zip"]) {
                        zip = [geoData objectForKey:@"zip"];
                    }
                    if ([geoData.allKeys containsObject:@"conc"]) {
                        continentCode = [geoData objectForKey:@"conc"];
                    }
                    if ([geoData.allKeys containsObject:@"lat"]) {
                        latitude = [geoData objectForKey:@"lat"];
                    }
                    if ([geoData.allKeys containsObject:@"long"]) {
                        longitude = [geoData objectForKey:@"long"];
                    }
                    if ([geoData.allKeys containsObject: BO_TIME_STAMP]) {
                        timeStamp = [geoData objectForKey: BO_TIME_STAMP];
                    }
                    if (!(timeStamp != nil)) {
                        timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                    }
                    
                    //Store all other information for future use.
                    
                    NSDictionary *currentLocation = @{
                        @"city":NSNullifyCheck(city),
                        @"state":NSNullifyCheck(state),
                        @"country":NSNullifyCheck(country),
                        @"zip":NSNullifyCheck(zip),
                        @"continentCode":NSNullifyCheck(continentCode),
                        @"latitude":NSNullifyCheck(latitude),
                        @"longitude":NSNullifyCheck(longitude),
                        @"timeStamp":NSNullifyCheck(timeStamp)
                    };
                    
                    
                    [self storeGeoLocation:currentLocation];
                    cNewLocationDict = currentLocation;
                    [[BOACommunicatonController sharedInstance] postMessage:BO_ANALYTICS_APP_IP_LOCATION_RECEIVED_KEY withObject:currentLocation andUserInfo:currentLocation asNotifications:YES];
                    if (completionHandler) {
                        completionHandler(currentLocation, nil);
                    }
                } @catch (NSException *exception) {
                    //Log exception
                    if (completionHandler) {
                        NSError *locationErr = [NSError errorWithDomain:@"io.blotout.sdk" code:100003 userInfo:exception.userInfo];
                        completionHandler(nil, locationErr);
                    }
                }
            } failure:^(NSError * _Nonnull error) {
                completionHandler(nil, error);
            }];
            requestInProgress = YES;
        }
        
        return (cNewLocationDict ? cNewLocationDict : cKnownLocation);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        completionHandler(nil, [NSError boErrorForDict:exception.userInfo]);
    }
    return nil;
}

-(void)postInitLaunchEventsRecording{
    //App Did Launc
    [self recordAppInformation:nil];
    [self recordSystemUptime:nil];
    [self recordNotificationsInBackgroundWith:nil];
    [[BOAFunnelSyncController sharedInstanceFunnelController] appLaunchedWithInfo:@{}];
    
    //There should not be any concern except cases where 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BOALifeTimeAllEvent *sharedLifeTimeEvents = [BOALifeTimeAllEvent sharedInstance];
        [sharedLifeTimeEvents recordWAST:nil withPayload:nil];
        [sharedLifeTimeEvents recordMAST:nil withPayload:nil];
    });
}

-(void)registerForNotifications{
    @try {
        __block BOAAppSessionEvents *blockSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            
            [self performSelector:@selector(decideAndRecordLaunchReason:) withObject:note afterDelay:10];
            
            [[BOACommunicatonController sharedInstance] postMessage:BO_ANALYTICS_APP_LAUNCH_KEY withObject:note.object andUserInfo:note.userInfo asNotifications:YES];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationDidEnterBackgroundNotification %@", note);
            [[BOACommunicatonController sharedInstance] postMessage:BO_ANALYTICS_APP_BACKGROUND_KEY withObject:note.object andUserInfo:note.userInfo asNotifications:YES];
            if (BOAEvents.isSessionModelInitialised) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_IN_BACKGROUND],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME:[NSString stringWithFormat:@"%@",[[blockSelf topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appInBackground mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppInBackground:existingData];
                
                [[BOAFunnelSyncController sharedInstanceFunnelController] appInBackgroundWithInfo:note.userInfo];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationWillEnterForegroundNotification %@", note);
            if (BOAEvents.isSessionModelInitialised) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_IN_FOREGROUND],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME:[NSString stringWithFormat:@"%@",[[blockSelf topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appInForeground mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppInForeground:existingData];
            }
            
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationDidBecomeActiveNotification %@", note);
            if (BOAEvents.isSessionModelInitialised) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_BECOME_ACTIVE],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME: [NSString stringWithFormat:@"%@",[[blockSelf topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appActive mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppActive:existingData];
            }
            
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationWillResignActiveNotification %@", note);
            if (BOAEvents.isSessionModelInitialised) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_RESIGN_ACTIVE],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME: [NSString stringWithFormat:@"%@",[[blockSelf topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appResignActive mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppResignActive:existingData];
                
                [[BOAFunnelSyncController sharedInstanceFunnelController] appInBackgroundWithInfo:note.userInfo];
            }
            
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationDidReceiveMemoryWarningNotification %@", note);
            //Incorporate later with data safety and cleanup resources
            if (BOAEvents.isSessionModelInitialised) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_MEMORY_WARNING],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME: [NSString stringWithFormat:@"%@",[[self topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appReceiveMemoryWarning mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppReceiveMemoryWarning:existingData];
            }
            
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            
            // Send page_hide event
            if([BOSharedManager sharedInstance].currentNavigation != nil) {
                [BONetworkEventService sendPageHideEvent:[BOSharedManager sharedInstance].currentNavigation.to storeEvents:YES];
            } else {
                [BONetworkEventService sendPageHideEvent:@"Unknown" storeEvents:YES];
            }
            
            if (BOAEvents.isSessionModelInitialised) {
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appSessionInfo mutableCopy];
                
                BOSessionInfo *sessionInfo = existingData.lastObject;
                if(sessionInfo != nil) {
                    sessionInfo.end = [BOAUtilities get13DigitNumberObjTimeStamp];
                    long duration = sessionInfo.end.integerValue - sessionInfo.start.integerValue;
                    sessionInfo.duration = [NSNumber numberWithInteger:duration];
                }
                
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppSessionInfo:existingData];
            }
            
            [self recordSessionOnDayChangeOrAppTermination:^(BOOL isSuccess, NSError * _Nullable error) {
                [self recordLifeTimeOnDayChangeOrAppTermination:^(BOOL isSuccess, NSError * _Nullable error) {
                    [self resetAverageSessionDuration];
                }];
            }];
            
            [[BOAFunnelSyncController sharedInstanceFunnelController] appWillTerminatWithInfo:note.userInfo];
            
            [[BOACommunicatonController sharedInstance] postMessage:BO_ANALYTICS_APP_TERMINATE_KEY withObject:note.object andUserInfo:note.userInfo asNotifications:YES];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationSignificantTimeChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationSignificantTimeChangeNotification %@", note);
            if (BOAEvents.isSessionModelInitialised) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_SIGNIFICANT_TIME_CHANGE],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME: [NSString stringWithFormat:@"%@",[[self topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appSignificantTimeChange mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppSignificantTimeChange:existingData];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationWillChangeStatusBarOrientationNotification %@", note);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationDidChangeStatusBarOrientationNotification %@", note);
            
            BOOL isPortrait = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown);
            BOOL isLandscape = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight);
            
            if (!isPortrait && !isLandscape) {
                isPortrait = ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) || ([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown);
                isLandscape = ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) || ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight);
            }
            
            if (BOAEvents.isSessionModelInitialised && isPortrait) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"Portrait"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME: [NSString stringWithFormat:@"%@",[[blockSelf topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appOrientationPortrait mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppOrientationPortrait:existingData];
            }
            if (BOAEvents.isSessionModelInitialised && isLandscape) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"Landscape"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME: [NSString stringWithFormat:@"%@",[[blockSelf topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appOrientationLandscape mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppOrientationLandscape:existingData];
            }
            
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarFrameNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationWillChangeStatusBarFrameNotification %@", note);
            //We can record the old and new status bar frame size if needed
            if (BOAEvents.isSessionModelInitialised) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_STATUS_BAR_FRAME_CHANGED],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME: [NSString stringWithFormat:@"%@",[[blockSelf topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appStatusbarFrameChange mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppStatusbarFrameChange:existingData];
            }
            
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationBackgroundRefreshStatusDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationBackgroundRefreshStatusDidChangeNotification %@", note);
            if (BOAEvents.isSessionModelInitialised) {
                BOApp *appStates = [BOApp fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_BACKGROUND_REFRESH_CHANGED],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VISIBLE_CLASS_NAME: [NSString stringWithFormat:@"%@",[[blockSelf topViewController] class]]
                }
                                    ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appBackgroundRefreshStatusChange mutableCopy];
                [existingData addObject:appStates];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppBackgroundRefreshStatusChange:existingData];
                
                if ([UIApplication sharedApplication].backgroundRefreshStatus == UIBackgroundRefreshStatusAvailable) {
                    BOApp *appBGRefresh = [BOApp fromJSONDictionary:@{
                        BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                        BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_BACKGROUND_REFRESH_AVAILABLE],
                        BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                        BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                        BO_VISIBLE_CLASS_NAME: [NSString stringWithFormat:@"%@",[[blockSelf topViewController] class]]
                    }
                                           ];
                    NSMutableArray *existingDataBGRefresh = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appBackgroundRefreshAvailable mutableCopy];
                    [existingDataBGRefresh addObject:appBGRefresh];
                    [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates setAppBackgroundRefreshStatusChange:existingDataBGRefresh];
                }
            }
            
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationProtectedDataWillBecomeUnavailable object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //Screen locked
            BOFLogDebug(@"UIApplicationProtectedDataWillBecomeUnavailable %@", note);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationProtectedDataDidBecomeAvailable object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //Screen Unlocked
            BOFLogDebug(@"UIApplicationProtectedDataDidBecomeAvailable %@", note);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //App Did Launch
            BOFLogDebug(@"UIApplicationUserDidTakeScreenshotNotification %@", note);
            
            if (BOAEvents.isSessionModelInitialised) {
                BOScreenShotsTaken *screenShotRecord = [BOScreenShotsTaken fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_TAKEN_SCREEN_SHOT],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_CURRENT_VIEW: [NSString stringWithFormat:@"%@",[[blockSelf topViewController].view class]]
                }
                                                        ];
                NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.ubiAutoDetected.screenShotsTaken mutableCopy];
                [existingData addObject:screenShotRecord];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.ubiAutoDetected setScreenShotsTaken:existingData];
            }
            
        }];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}
@end
