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
  return [BlotoutAnalytics sharedInstance].endPointUrl;
}

-(NSString*)resolveAPIEndPoint:(BOUrlEndPoint)endPoint {
  NSString *url;
  switch (endPoint) {
      case BOUrlEndPointEventPublish:{
      url = [NSString stringWithFormat:@"%@/%@", [self getBaseServerUrl],BO_SDK_REST_API_EVENTS_PUSH_PATH];
          break;
      }
    case BOUrlEndPointManifestPull:
      url = [NSString stringWithFormat:@"%@/%@", [self getBaseServerUrl], BO_SDK_REST_API_MANIFEST_PULL_PATH];
  }
  
  return [NSString stringWithFormat:@"%@?token=%@", url, [BlotoutAnalytics sharedInstance].token];
}

-(NSDictionary*)prepareRequestHeaders {
  return @{
      BO_ACCEPT: @"application/json",
      BO_CONTENT_TYPE: @"application/json"
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
