//
//  BOServerDataConverter.m
//  BlotoutAnalytics
//
//  Copyright © 2020 Blotout. All rights reserved.
//

#import "BOServerDataConverter.h"
#import "BOADeviceAndAppFraudController.h"
#import "BOASDKManifestController.h"
#import "BOFLogs.h"
#import "BOANetworkConstants.h"
#import "BOAUtilities.h"
#import "BOAUserDefaultsStorage.h"
#import "BOSharedManager.h"
#import <WebKit/WebKit.h>

static NSMutableDictionary *appInfo;

@interface BOServerDataConverter ()
@end

@implementation BOServerDataConverter

+ (void)load {
  appInfo = [NSMutableDictionary dictionary];
}

+(NSDictionary*)recordAppInformation {
  @try {
      NSNumber *launchTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
      [appInfo setObject:launchTimeStamp forKey:@"launchTimeStamp"];
      
      NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
      NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
      NSString * versionAndBundle = [NSString stringWithFormat:@"%@.%@", appVersionString ?: @"",appBuildString ?: @""];
      [appInfo setObject:versionAndBundle forKey:@"version"];
      
      NSString * sdkVersion = [NSString stringWithFormat:@"%d.%d.%d", BOSDK_MAJOR_VERSION,BOSDK_MINOR_VERSION,BOSDK_PATCH_VERSION];
      [appInfo setObject:sdkVersion forKey:@"sdkVersion"];
      
      NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
      NSString *prodName = [bundleInfo objectForKey:@"CFBundleName"];
      [appInfo setObject:prodName forKey:@"name"]; //Check this, coming as SalesDemoApp, which is app name
    
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
      
      dispatch_async(dispatch_get_main_queue(), ^{
      NSString *userAgent = [[WKWebView new] valueForKey:@"userAgent"];
      [appInfo setObject:userAgent forKey:@"userAgent"];
      });
      
      return appInfo;
  } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

+ (NSDictionary *)prepareMetaData {
  @try {
    NSDictionary *appInfoCurrentDict = nil;
    if (appInfo && (appInfo.allValues.count > 0)) {
      appInfoCurrentDict = appInfo;
    } else {
      appInfoCurrentDict = [self recordAppInformation];
    }
  
      NSString *screenName = [BOSharedManager sharedInstance].currentScreenName;
      NSMutableDictionary *metaInfo = [[NSMutableDictionary alloc] initWithDictionary:@{

      @"jbrkn": [appInfoCurrentDict objectForKey:@"jbnStatus"],
      @"vpn": [appInfoCurrentDict objectForKey:@"vpnStatus"],
      @"dcomp": [appInfoCurrentDict objectForKey:@"dcompStatus"],
      @"acomp": [appInfoCurrentDict objectForKey:@"acompStatus"],
      @"sdkv": [appInfoCurrentDict objectForKey:@"sdkVersion"],
      @"tz_offset": [appInfoCurrentDict objectForKey:@"timeZoneOffset"],
      @"user_agent": [appInfoCurrentDict objectForKey:@"userAgent"],
      @"referrer" : [BOSharedManager sharedInstance].referrer,
      @"page_title" : screenName
    }];

    return metaInfo;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

@end
