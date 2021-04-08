//
//  BOBaseAPI.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOBaseAPI.h"
#import "BONetworkManager.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOASDKManifestController.h"
#import "BlotoutAnalytics_Internal.h"

@implementation BOBaseAPI

-(NSDictionary*)getJsonData:(NSData*)data {
  NSDictionary *dict = nil;
  @try {
    if (data != nil) {
      dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  
  return dict;
}

-(NSString*)getBaseServerUrl {
  if ([BOASDKManifestController sharedInstance].serverBaseURL != nil && [BOASDKManifestController sharedInstance].serverBaseURL.length>0) {
    return [BOASDKManifestController sharedInstance].serverBaseURL;
  }
    
  return [BlotoutAnalytics sharedInstance].endPointUrl;
}

-(NSString*)resolveAPIEndPoint:(BOUrlEndPoint)endPoint {
  @try {
    switch (endPoint) {
      case BOUrlEndPointEventDataPOST: {
        if ([BOASDKManifestController sharedInstance].eventPath != nil && [BOASDKManifestController sharedInstance].eventPath.length>0) {
          return [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],[BOASDKManifestController sharedInstance].eventPath];
        }
        return [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_EVENTS_PUSH_PATH];
      }
      case BOUrlEndPointManifestGET:
        return [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_MANIFEST_PULL_PATH];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

-(NSDictionary*)prepareRequestHeaders {
  return @{
      BO_ACCEPT: @"application/json",
      BO_CONTENT_TYPE: @"application/json",
      BO_TOKEN: [BlotoutAnalytics sharedInstance].token,
      BO_VERSION: @"v1"
  };
}

/* This Method check for null value in response data and replace it with empty string, Temp fix for Manifest Response */
-(NSData*)checkForNullValue:(NSData*)data {
  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  if ([responseString containsString:@"null,"]) {
      responseString = [responseString stringByReplacingOccurrencesOfString:@"null," withString:@""];
  }
  
  return [responseString dataUsingEncoding:NSUTF8StringEncoding];
}
@end
