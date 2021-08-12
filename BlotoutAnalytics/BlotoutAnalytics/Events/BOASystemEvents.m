//
//  BOASystemEvents.m
//  BlotoutAnalytics
//
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "BOASystemEvents.h"
#import "BlotoutAnalytics.h"
#import "BlotoutAnalytics_Internal.h"
#import "BOANetworkConstants.h"
#import "BOFLogs.h"
#import "BOASDKManifestController.h"
#import "BOFUserDefaults.h"

@implementation BOASystemEvents
+(void)captureAppLaunchingInfoWithConfiguration:(NSDictionary *)launchOptions {
  @try {
    BlotoutAnalytics *analytics = [BlotoutAnalytics sharedInstance];
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
    
    NSInteger previousBuildV1 = [[analyticsRootUD objectForKey:BO_BUILD_KEYV1] intValue];
    if (previousBuildV1) {
      [analyticsRootUD setObject:[@(previousBuildV1) stringValue] forKey:BO_BUILD_KEYV2];
      [analyticsRootUD removeObjectForKey:BO_BUILD_KEYV1];
    }
    
    NSString *previousVersion = [analyticsRootUD objectForKey:BO_VERSION_KEY];
    NSString *previousBuildV2 = [analyticsRootUD objectForKey:BO_BUILD_KEYV2];
    
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *currentBuild = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    
    if (!previousBuildV2 && [sdkManifesCtrl isSystemEventEnabled:BO_APPLICATION_INSTALLED]) {
        [analytics capture:@"Application Installed" withInformation:@{
          @"version" : currentVersion ?: @"",
          @"build" : currentBuild ?: @"",
        } withType:BO_SYSTEM withEventCode:@(BO_APPLICATION_INSTALLED)];
    } else if (![currentBuild isEqualToString:previousBuildV2] && [sdkManifesCtrl isSystemEventEnabled:BO_APPLICATION_UPDATED]) {
      [analytics capture:@"Application Updated" withInformation:@{
        @"previous_version" : previousVersion ?: @"",
        @"previous_build" : previousBuildV2 ?: @"",
        @"version" : currentVersion ?: @"",
        @"build" : currentBuild ?: @"",
      } withType:BO_SYSTEM withEventCode:@(BO_APPLICATION_UPDATED)];
    }
    
    if ([sdkManifesCtrl isSystemEventEnabled:BO_APPLICATION_OPENED]) {
      [analytics capture:@"Application Opened" withInformation:@{
        @"from_background" : @NO,
        @"version" : currentVersion ?: @"",
        @"build" : currentBuild ?: @"",
        @"referring_application" : launchOptions[UIApplicationLaunchOptionsSourceApplicationKey] ?: @"",
        @"url" : launchOptions[UIApplicationLaunchOptionsURLKey] ?: @"",
      } withType:BO_SYSTEM withEventCode:@(BO_APPLICATION_OPENED)];
    }
    
    [analyticsRootUD setObject:currentVersion forKey:BO_VERSION_KEY];
    [analyticsRootUD setObject:currentBuild forKey:BO_BUILD_KEYV2];
  } @catch(NSException *exception) {
    BOFLogDebug(@"%@", exception);
  }
}

@end
