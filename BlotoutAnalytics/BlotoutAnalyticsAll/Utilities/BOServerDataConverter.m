//
//  BOServerDataConverter.m
//  BlotoutAnalytics
//
//  Created by Blotout on 10/05/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import "BOServerDataConverter.h"
#import "BOAppSessionData.h"
#import "BOADeviceAndAppFraudController.h"
#import <BlotoutFoundation/BOFSystemServices.h>
#import "BOASDKManifestController.h"
#import "BOASegmentsResSegmentsPayload.h"
#import "BOAEvents.h"
#import "BOAAppSessionEvents.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
#import "BOAAppSessionEvents.h"
#import <UIKit/UIKit.h>
#import "BOACommunicatonController.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAUtilities.h"
#import "BOAUserDefaultsStorage.h"

const int Continent = 1;
const int Country = 2;
const int Region = 3;
const int City = 4;
const int Postal_Address = 5;

const int DeviceGrainHigh = 1;
const int DeviceGrainMedium = 2;
const int DeviceGrainAll = 3;

static NSMutableDictionary *appInfo;

@interface BOServerDataConverter ()
@end

@implementation BOServerDataConverter

+ (void)load{
    appInfo = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storePreviousDayAppInfoViaNotification:) name:BO_ANALYTICS_ON_DAY_CHANGED object:nil];
}

+(NSDictionary*)recordAppInformation{
    @try {
        NSNumber *launchTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
        [appInfo setObject:launchTimeStamp forKey:@"launchTimeStamp"];
        
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString * versionAndBundle = [NSString stringWithFormat:@"%@.%@", appVersionString,appBuildString];
        [appInfo setObject:NSNullifyCheck(versionAndBundle) forKey:@"version"];
        
        NSString * sdkVersion = [NSString stringWithFormat:@"%d.%d.%d", BOSDK_MAJOR_VERSION,BOSDK_MINOR_VERSION,BOSDK_PATCH_VERSION];
        [appInfo setObject:NSNullifyCheck(sdkVersion) forKey:@"sdkVersion"];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        [appInfo setObject:NSNullifyCheck(bundleIdentifier) forKey:@"bundle"];
        
        NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *prodName = [bundleInfo objectForKey:@"CFBundleExecutable"]; //CFBundleName
        [appInfo setObject:NSNullifyCheck(prodName) forKey:@"name"]; //Check this, coming as SalesDemoApp, which is app name
        [appInfo setObject:NSNullifyCheck([BOFSystemServices sharedServices].language) forKey:@"language"];
        
        [appInfo setObject:[NSNumber numberWithInt:[BOAUtilities currentPlatformCode]] forKey:@"platform"];
        
        NSString *osn = [BOFSystemServices sharedServices].systemName ? [BOFSystemServices sharedServices].systemName : @"-1";
        [appInfo setObject:osn forKey:@"osName"];
        
        NSString *osv = [BOFSystemServices sharedServices].systemsVersion ? [BOFSystemServices sharedServices].systemsVersion : @"-1";
        [appInfo setObject:osv forKey:@"osVersion"];
        
        NSString *dmft = @"Apple";
        [appInfo setObject:dmft forKey:@"deviceMft"];
        
        NSString *dModel = [BOFSystemServices sharedServices].deviceModel ? [BOFSystemServices sharedServices].deviceModel : @"NA";
        [appInfo setObject:dModel forKey:@"deviceModel"];
        
        int isProxied = [BOADeviceAndAppFraudController isConnectionProxied] ? 1 : 0;
        [appInfo setObject:[NSNumber numberWithBool:isProxied] forKey:@"vpnStatus"];
        
        int jbnStatus = [BOADeviceAndAppFraudController isDeviceJailbroken] ? 1 : 0;
        [appInfo setObject:[NSNumber numberWithBool:jbnStatus] forKey:@"jbnStatus"];
        
        BOOL isDyLibInjected = [BOADeviceAndAppFraudController isDylibInjectedToProcessWithName:@"dylib_name"] && [BOADeviceAndAppFraudController isDylibInjectedToProcessWithName:@"libcycript"];
        int dcomp = (isDyLibInjected || jbnStatus) ?  1 : 0;
        int acomp = isDyLibInjected ?  1 : 0;
        [appInfo setObject:[NSNumber numberWithBool:dcomp] forKey:@"dcompStatus"];
        [appInfo setObject:[NSNumber numberWithBool:acomp] forKey:@"acompStatus"];
        
        int timeoOffset = [BOAUtilities getCurrentTimezoneOffsetInMin];
        [appInfo setObject:[NSNumber numberWithInt:timeoOffset] forKey:@"timeZoneOffset"];
        
        return appInfo;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+ (NSDictionary *)prepareMetaData{
    @try {
        NSDictionary *appInfoCurrentDict = nil;
        if (appInfo && (appInfo.allValues.count > 0)) {
            appInfoCurrentDict = appInfo;
        }else{
            appInfoCurrentDict = [self recordAppInformation];
        }
        NSNumber *timeStamp = [BOAUserDefaultsStorage getUserBirthTimeStamp];
        NSMutableDictionary *metaInfo = [[NSMutableDictionary alloc] initWithDictionary:@{
            @"plf": [appInfoCurrentDict objectForKey:@"platform"],
            @"appv": [appInfoCurrentDict objectForKey:@"version"],
            @"appn": [appInfoCurrentDict objectForKey:@"bundle"],
            @"jbrkn": [appInfoCurrentDict objectForKey:@"jbnStatus"],
            @"vpn": [appInfoCurrentDict objectForKey:@"vpnStatus"],
            @"dcomp": [appInfoCurrentDict objectForKey:@"dcompStatus"],
            @"acomp": [appInfoCurrentDict objectForKey:@"acompStatus"],
            @"osn": [appInfoCurrentDict objectForKey:@"osName"],
            @"osv": [appInfoCurrentDict objectForKey:@"osVersion"],
            @"dmft": [appInfoCurrentDict objectForKey:@"deviceMft"],
            @"dm": [appInfoCurrentDict objectForKey:@"deviceModel"],
            @"sdkv": [appInfoCurrentDict objectForKey:@"sdkVersion"],
            @"tz_offset": [appInfoCurrentDict objectForKey:@"timeZoneOffset"],
            @"user_id_created": timeStamp
        }];
        
        if([[metaInfo allValues] count] > 0) {
            int deviceGrain = [self getDeviceGrain];
            switch (deviceGrain) {
                case DeviceGrainHigh:
                    [metaInfo removeObjectForKey:@"osn"];
                    [metaInfo removeObjectForKey:@"osv"];
                    [metaInfo removeObjectForKey:@"dmft"];
                    [metaInfo removeObjectForKey:@"dm"];
                    break;
                case DeviceGrainMedium:
                case DeviceGrainAll:
                    break;
                default:
                    break;
            }
        }
    
        return NSNullifyDictCheck(metaInfo);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (NSDictionary *)prepareGeoData {
    @try {
        
        //Return No Geo Event Data in case of firstParty container
        if([BOASDKManifestController sharedInstance].sdkDeploymentMode == BO_DEPLOYMENT_MODE_FIRST_PARTY) {
            return nil;
        }
        
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSString *currLocStr = [analyticsRootUD objectForKey:BO_ANALYTICS_CURRENT_LOCATION_DICT];
        NSDictionary *cKnownLocation = currLocStr ? [BOAUtilities jsonObjectFromString:currLocStr] : nil;
        NSMutableDictionary *geoInfo = nil;
        if (cKnownLocation) {
            geoInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                @"conc": [cKnownLocation objectForKey:@"continentCode"],
                @"couc": [cKnownLocation objectForKey:@"country"],
                @"reg": [cKnownLocation objectForKey:@"state"],
                @"city": [cKnownLocation objectForKey:@"city"],
                @"zip": [cKnownLocation objectForKey:@"zip"],
                @"lat": [cKnownLocation objectForKey:@"latitude"],
                @"long": [cKnownLocation objectForKey:@"longitude"],
            }];
        }
        
        if((geoInfo != nil) && (geoInfo.allValues.count > 0)) {
            int deviceGrain = [self getGeoGrain];
            switch (deviceGrain) {
                case Continent:
                    [geoInfo removeObjectForKey:@"couc"];
                    [geoInfo removeObjectForKey:@"reg"];
                    [geoInfo removeObjectForKey:@"city"];
                    [geoInfo removeObjectForKey:@"zip"];
                    break;
                case Country:
                    [geoInfo removeObjectForKey:@"reg"];
                    [geoInfo removeObjectForKey:@"city"];
                    [geoInfo removeObjectForKey:@"zip"];
                    break;
                case Region:
                    [geoInfo removeObjectForKey:@"city"];
                    [geoInfo removeObjectForKey:@"zip"];
                    break;
                case City:
                    [geoInfo removeObjectForKey:@"zip"];
                    break;
                case Postal_Address:
                    //Postal address
                    break;
                default:
                    break;
            }
            //Lat Long will never be sent
            [geoInfo removeObjectForKey:@"lat"];
            [geoInfo removeObjectForKey:@"long"];
        }
        
        for (NSString *geoKey in geoInfo.allKeys) {
            id geoVal = [geoInfo objectForKey:geoKey];
            if ([geoVal isEqual:NSNull.null] || [geoVal isEqual:NULL]) {
                [geoInfo removeObjectForKey:geoKey];
            }
        }
        
        return NSNullifyDictCheck(geoInfo);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (int)getGeoGrain {
    @try {
        BOASDKManifestController *mc = [BOASDKManifestController sharedInstance];
        int geoGrain = [mc eventGEOLocationGrain].intValue;
        if(geoGrain > 0) {
            return geoGrain;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return -1;
}

+ (int)getDeviceGrain {
    @try {
        int deviceGrain = [[BOASDKManifestController sharedInstance] eventDeviceInfoGrain].intValue;
        if(deviceGrain > 0) {
            return deviceGrain;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return -1;
}

+ (NSDictionary *)preparePreviousMetaData:(nullable BOAppSessionData*)sessionData {
    @try {
        
        NSDictionary *appInfoCurrentDict = [BOAAppSessionEvents sharedInstance].sessionAppInfo;
        if (!(appInfoCurrentDict && (appInfoCurrentDict.allValues.count > 10))) {
            [[BOAAppSessionEvents sharedInstance] recordAppInformation:nil];
            appInfoCurrentDict = [BOAAppSessionEvents sharedInstance].sessionAppInfo;
        }
        BOAppInfo *appInfoCurrent = [BOAppInfo fromJSONDictionary:appInfoCurrentDict];
        
        //can find previous day based on sessionData but using default as short term solution.
        
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSString *previousAppInfoDictStr = [analyticsRootUD objectForKey:BO_ANALYTICS_ROOT_USER_DEFAULTS_PREVIOUS_DAY_APP_INFO];
        NSDictionary *previousAppInfoDict = [BOAUtilities jsonObjectFromString:previousAppInfoDictStr];
        
        BOAppInfo *appInfoPrevious = nil;
        if (previousAppInfoDict.allValues.count > 0) {
            appInfoPrevious =  [BOAppInfo fromJSONDictionary:previousAppInfoDict];
        }
        if (appInfoPrevious) {
            NSMutableDictionary *metaInfo = [[NSMutableDictionary alloc] initWithDictionary:@{
                @"plf": NSNull.null,
                @"appv": [appInfoPrevious.version isEqualToString:appInfoCurrent.version] ? NSNull.null : appInfoPrevious.version,
                @"appn": [appInfoPrevious.name isEqualToString:appInfoCurrent.name] ? NSNull.null : appInfoPrevious.name,
                @"jbrkn": [appInfoPrevious.jbnStatus isEqualToNumber:appInfoCurrent.jbnStatus] ? NSNull.null : appInfoPrevious.jbnStatus,
                @"vpn": [appInfoPrevious.vpnStatus isEqualToNumber:appInfoCurrent.vpnStatus] ? NSNull.null : appInfoPrevious.vpnStatus,
                @"dcomp": [appInfoPrevious.dcompStatus isEqualToNumber:appInfoCurrent.dcompStatus] ? NSNull.null : appInfoPrevious.dcompStatus,
                @"acomp": [appInfoPrevious.acompStatus isEqualToNumber:appInfoCurrent.acompStatus] ? NSNull.null : appInfoPrevious.acompStatus,
                @"osn": [appInfoPrevious.osName isEqualToString:appInfoCurrent.osName] ? NSNull.null : appInfoPrevious.osName,
                @"osv": [appInfoPrevious.osVersion isEqualToString:appInfoCurrent.osVersion] ? NSNull.null : appInfoPrevious.osVersion,
                @"dmft": NSNull.null,
                @"dm": NSNull.null,
                @"sdkv": [appInfoPrevious.sdkVersion isEqualToString:appInfoCurrent.sdkVersion] ? NSNull.null : appInfoPrevious.sdkVersion,
                @"tz_offset": [appInfoPrevious.timeZoneOffset isEqualToString:appInfoCurrent.timeZoneOffset] ? NSNull.null : appInfoPrevious.timeZoneOffset,
            }];
            
            if([[metaInfo allValues] count] > 0) {
                int deviceGrain = [self getDeviceGrain];
                switch (deviceGrain) {
                    case DeviceGrainHigh:
                        [metaInfo removeObjectForKey:@"osn"];
                        [metaInfo removeObjectForKey:@"osv"];
                        [metaInfo removeObjectForKey:@"dmft"];
                        [metaInfo removeObjectForKey:@"dm"];
                        break;
                    case DeviceGrainMedium:
                        [metaInfo removeObjectForKey:@"osn"];
                        [metaInfo removeObjectForKey:@"osv"];
                        [metaInfo removeObjectForKey:@"dmft"];
                        [metaInfo removeObjectForKey:@"dm"];
                        break;
                    case DeviceGrainAll:
                        break;
                    default:
                        break;
                }
            }
            
            for (NSString *metaInfoKey in metaInfo.allKeys) {
                id metaVal = [metaInfo objectForKey:metaInfoKey];
                if ([metaVal isEqual:NSNull.null] || [metaVal isEqual:NULL]) {
                    [metaInfo removeObjectForKey:metaInfoKey];
                }
            }
            
            return (metaInfo && (metaInfo.allValues.count > 0)) ? metaInfo : nil;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (void)storePreviousDayAppInfoViaNotification:(nullable NSNotification*)notification {
    @try {
        //        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        //        NSDictionary *singleDaySessions = [notification.object objectForKey:@"singleDaySessions"];
        //        NSArray <NSDictionary *> *appInfoArr = [singleDaySessions objectForKey:@"appInfo"];
        //        NSDictionary *appInfoDict = [appInfoArr lastObject];
        //        if (appInfoDict.allValues.count > 0) {
        //            NSString *appInfoDictStr = [BOAUtilities jsonStringFrom:appInfoDict withPrettyPrint:NO];
        //            [analyticsRootUD setObject:appInfoDictStr forKey:BO_ANALYTICS_ROOT_USER_DEFAULTS_PREVIOUS_DAY_APP_INFO];
        //        }
        //        [[NSUserDefaults standardUserDefaults] synchronize];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

@end
