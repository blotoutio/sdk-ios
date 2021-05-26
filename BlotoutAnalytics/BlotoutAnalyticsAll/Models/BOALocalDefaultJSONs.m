//
//  BOALocalDefaultJSONs.m
//  BlotoutAnalytics
//
//  Created by Blotout on 08/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOALocalDefaultJSONs.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"


@implementation BOALocalDefaultJSONs

+(NSString*)appSessionJSONString{
    NSString *jsonString =  @"{\"appBundle\":null,\"date\":null,\"singleDaySessions\":{\"sentToServer\":false,\"systemUptime\":[],\"lastServerSyncTimeStamp\":null,\"allEventsSyncTimeStamp\":null,\"appInfo\":[],\"ubiAutoDetected\":{\"screenShotsTaken\":[],\"appNavigation\":[],\"appGesture\":{\"touchOrClick\":[],\"drag\":[],\"flick\":[],\"swipe\":[],\"doubleTap\":[],\"moreThanDoubleTap\":[],\"twoFingerTap\":[],\"moreThanTwoFingerTap\":[],\"pinch\":[],\"touchAndHold\":[],\"shake\":[],\"rotate\":[],\"screenEdgePan\":[]}},\"developerCodified\":{\"touchClick\":[],\"drag\":[],\"flick\":[],\"swipe\":[],\"doubleTap\":[],\"moreThanDoubleTap\":[],\"twoFingerTap\":[],\"moreThanTwoFingerTap\":[],\"pinch\":[],\"touchAndHold\":[],\"shake\":[],\"rotate\":[],\"screenEdgePan\":[],\"view\":[],\"addToCart\":[],\"chargeTransaction\":[],\"listUpdated\":[],\"timedEvent\":[],\"customEvents\":[],\"piiEvents\":[],\"phiEvents\":[]},\"appStates\":{\"sentToServer\":false,\"appLaunched\":[],\"appActive\":[],\"appResignActive\":[],\"appInBackground\":[],\"appInForeground\":[],\"appBackgroundRefreshAvailable\":[],\"appReceiveMemoryWarning\":[],\"appSignificantTimeChange\":[],\"appOrientationPortrait\":[],\"appOrientationLandscape\":[],\"appStatusbarFrameChange\":[],\"appBackgroundRefreshStatusChange\":[],\"appNotificationReceived\":[],\"appNotificationViewed\":[],\"appNotificationClicked\":[],\"appSessionInfo\":[]},\"deviceInfo\":{\"multitaskingEnabled\":[],\"proximitySensorEnabled\":[],\"debuggerAttached\":[],\"pluggedIn\":[],\"jailBroken\":[],\"numberOfActiveProcessors\":[],\"processorsUsage\":[],\"accessoriesAttached\":[],\"headphoneAttached\":[],\"numberOfAttachedAccessories\":[],\"nameOfAttachedAccessories\":[],\"batteryLevel\":[],\"isCharging\":[],\"fullyCharged\":[],\"deviceOrientation\":[],\"cfUUID\":[],\"vendorID\":[]},\"networkInfo\":{\"currentIPAddress\":[],\"externalIPAddress\":[],\"cellIPAddress\":[],\"cellNetMask\":[],\"cellBroadcastAddress\":[],\"wifiIPAddress\":[],\"wifiNetMask\":[],\"wifiBroadcastAddress\":[],\"wifiRouterAddress\":[],\"wifiSSID\":[],\"connectedToWifi\":[],\"connectedToCellNetwork\":[]},\"storageInfo\":[],\"memoryInfo\":[],\"location\":[],\"crashDetails\":[],\"commonEvents\":[], \"retentionEvent\":{\"sentToServer\":false,\"dau\":null,\"dpu\":null,\"appInstalled\":null,\"newUser\":null,\"DAST\":null,\"customEvents\":[]}}}";
    
    return jsonString;
}

+(NSDictionary*)appSessionJSONDict{
    @try {
        NSString *jsonStr = [self appSessionJSONString];
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        return jsonDict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}


+(NSDictionary*)appSessionJSONDictFromJSONString:(NSString*)jsonString{
    @try {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        return jsonDict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)appLifeTimeDataJSONString{
    NSString *jsonString = @"{\"appBundle\":null,\"appID\":null,\"date\":null,\"lastServerSyncTimeStamp\":null,\"allEventsSyncTimeStamp\":null,\"appLifeTimeInfo\":[]}";
    return jsonString;
}

+(NSDictionary*)appLifeTimeDataJSONDict{
    @try {
        NSString *jsonStr = [self appLifeTimeDataJSONString];
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        return jsonDict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDictionary*)appLifeTimeDataJSONDictFromJSONString:(NSString*)jsonString{
    @try {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        return jsonDict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}


@end
