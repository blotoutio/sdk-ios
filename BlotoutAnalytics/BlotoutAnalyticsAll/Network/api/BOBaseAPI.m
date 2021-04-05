//
//  BOBaseAPI.m
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
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
        if(data != nil) {
            dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    
    return dict;
}

-(NSString*)getBaseServerUrl {
    
    NSString *urlDomainStr = @"";
    
    if([BOASDKManifestController sharedInstance].serverBaseURL != nil && [BOASDKManifestController sharedInstance].serverBaseURL.length>0) {
        urlDomainStr = [BOASDKManifestController sharedInstance].serverBaseURL;
    } else {
        urlDomainStr = [BlotoutAnalytics sharedInstance].endPointUrl;
    }
    
    return urlDomainStr;
}

-(NSString*)resolveAPIEndPoint:(BOUrlEndPoint)endPoint {
    @try {
        NSString *apiPath = nil;
        
        switch (endPoint) {
            case BOUrlEndPointEventDataPOST:
                
                if([BOASDKManifestController sharedInstance].eventPath != nil && [BOASDKManifestController sharedInstance].eventPath.length>0) {
                    apiPath =[NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],[BOASDKManifestController sharedInstance].eventPath];
                } else {
                    apiPath = [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_EVENTS_PUSH_PATH];
                }
                break;
                
            case BOUrlEndPointManifestGET:
                apiPath = [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_MANIFEST_PULL_PATH];
                break;
        }
        return apiPath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSDictionary*)prepareRequestHeaders {
    
    NSString *sdkToken = [BlotoutAnalytics sharedInstance].token;
    
    return @{
        BO_ACCEPT: @"application/json",
        BO_CONTENT_TYPE: @"application/json",
        BO_TOKEN: sdkToken,
        BO_VERSION: @"v1"
    };
}

/* This Method check for null value in response data and replace it with empty string, Temp fix for Manifest Response */
-(NSData*)checkForNullValue:(NSData*)data{
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if([responseString containsString:@"null,"]) {
        responseString = [responseString stringByReplacingOccurrencesOfString:@"null," withString:@""];
    }
    
    return [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
}
@end
