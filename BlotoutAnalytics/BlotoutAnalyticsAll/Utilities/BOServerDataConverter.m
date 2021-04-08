//
//  BOServerDataConverter.m
//  BlotoutAnalytics
//
//  Created by Blotout on 10/05/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import "BOServerDataConverter.h"
#import "BOADeviceAndAppFraudController.h"
#import "BOASDKManifestController.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOANetworkConstants.h"
#import <UIKit/UIKit.h>
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAUtilities.h"
#import "BOAUserDefaultsStorage.h"
#import "BOSharedManager.h"

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
}

+(NSDictionary*)recordAppInformation{
    @try {
        NSNumber *launchTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
        [appInfo setObject:launchTimeStamp forKey:@"launchTimeStamp"];
        
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString * versionAndBundle = [NSString stringWithFormat:@"%@.%@", appVersionString ?: @"",appBuildString ?: @""];
        [appInfo setObject:versionAndBundle forKey:@"version"];
        
        NSString * sdkVersion = [NSString stringWithFormat:@"%d.%d.%d", BOSDK_MAJOR_VERSION,BOSDK_MINOR_VERSION,BOSDK_PATCH_VERSION];
        [appInfo setObject:sdkVersion forKey:@"sdkVersion"];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        [appInfo setObject:bundleIdentifier forKey:@"bundle"];
        
        NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *prodName = [bundleInfo objectForKey:@"CFBundleName"];
        [appInfo setObject:prodName forKey:@"name"]; //Check this, coming as SalesDemoApp, which is app name
        
        [appInfo setObject:[NSNumber numberWithInt:[BOAUtilities currentPlatformCode]] forKey:@"platform"];
        
        NSString *osn = [BOAUtilities systemName] ? [BOAUtilities systemName] : @"-1";
        [appInfo setObject:osn forKey:@"osName"];
        
        NSString *osv = [BOAUtilities systemVersion] ? [BOAUtilities systemVersion] : @"-1";
        [appInfo setObject:osv forKey:@"osVersion"];
        
        NSString *dmft = @"Apple";
        [appInfo setObject:dmft forKey:@"deviceMft"];
        
        NSString *dModel = [BOAUtilities deviceModel] ? [BOAUtilities deviceModel] : @"NA";
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
        NSNumber *timeStamp = [BOAUtilities getUserBirthTimeStamp];
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
            @"user_id_created": timeStamp,
            @"referrer" : [BOSharedManager sharedInstance].referrer
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
        
        return metaInfo;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
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
    return 1;
}

@end
