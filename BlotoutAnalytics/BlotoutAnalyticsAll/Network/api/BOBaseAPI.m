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
#import "BOAConstants.h"
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

-(NSString*)validateAndReturnServerEndPoint:(NSString*)endPointUrl{
    
    if(endPointUrl != nil && endPointUrl.length > 0) {
        if([endPointUrl containsString:@"https://"] || [endPointUrl containsString:@"http://"]) {
            NSString *lastStr = [endPointUrl substringFromIndex:endPointUrl.length-1];
            if([lastStr isEqualToString:@"/"]) {
                return [NSString stringWithFormat:@"%@sdk",endPointUrl];
            } else {
                return [NSString stringWithFormat:@"%@/sdk",endPointUrl];
            }
        } else {
            return nil;
        }
    }
    
    return nil;
}

-(NSString*)getBaseServerUrl {
    
    NSString *urlDomainStr = @"";
    
    if (![BlotoutAnalytics sharedInstance].isDevModeEnabled) {
        if ([BlotoutAnalytics isSDKInProductionMode]) {
            if([BOASDKManifestController sharedInstance].serverBaseURL != nil && [BOASDKManifestController sharedInstance].serverBaseURL.length>0) {
                urlDomainStr = [BOASDKManifestController sharedInstance].serverBaseURL;
            } else {
                NSString *validatedUrl = [self validateAndReturnServerEndPoint:[BlotoutAnalytics sharedInstance].SDKEndPointUrl];
                if(validatedUrl != nil && validatedUrl.length > 0) {
                    urlDomainStr = validatedUrl;
                } else {
                    urlDomainStr = BO_SDK_PROD_MODE_API_DOMAIN_PATH;
                }
            }
        }else{
            if([BOASDKManifestController sharedInstance].serverBaseURL != nil && [BOASDKManifestController sharedInstance].serverBaseURL.length>0) {
                urlDomainStr = [BOASDKManifestController sharedInstance].serverBaseURL;
            } else {
                NSString *validatedUrl = [self validateAndReturnServerEndPoint:[BlotoutAnalytics sharedInstance].SDKEndPointUrl];
                if(validatedUrl != nil && validatedUrl.length > 0) {
                    urlDomainStr = validatedUrl;
                } else {
                    urlDomainStr = BO_SDK_STAGE_MODE_API_DOMAIN_PATH;
                }
            }
        }
    }else{
        if([BOASDKManifestController sharedInstance].serverBaseURL != nil && [BOASDKManifestController sharedInstance].serverBaseURL.length>0) {
            urlDomainStr = [BOASDKManifestController sharedInstance].serverBaseURL;
        } else {
            NSString *validatedUrl = [self validateAndReturnServerEndPoint:[BlotoutAnalytics sharedInstance].SDKEndPointUrl];
            if(validatedUrl != nil && validatedUrl.length > 0) {
                urlDomainStr = validatedUrl;
            } else {
                urlDomainStr = BO_SDK_ALPHA_DEV_MODE_API_DOMAIN_PATH;
            }
        }
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
                
            case BOUrlEndPointRetentionEventDataPOST:
                if([BOASDKManifestController sharedInstance].eventRetentionPath != nil && [BOASDKManifestController sharedInstance].eventRetentionPath.length>0) {
                    apiPath =[NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],[BOASDKManifestController sharedInstance].eventRetentionPath];
                } else {
                    apiPath = [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_RETENTION_PUSH_PATH];
                }
                break;
            case BOUrlEndPointFunnelEventDataGET:
                if([BOASDKManifestController sharedInstance].eventFunnelPath != nil && [BOASDKManifestController sharedInstance].eventFunnelPath.length>0) {
                    apiPath =[NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],[BOASDKManifestController sharedInstance].eventFunnelPath];
                } else {
                    apiPath = [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_FUNNEL_PULL_PATH];
                }
                break;
            case BOUrlEndPointFunnelEventDataPOST:
                if([BOASDKManifestController sharedInstance].eventFunnelPathsFeedback != nil && [BOASDKManifestController sharedInstance].eventFunnelPathsFeedback.length>0) {
                    apiPath =[NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],[BOASDKManifestController sharedInstance].eventFunnelPathsFeedback];
                } else {
                    apiPath = [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_FUNNEL_PUSH_PATH];
                }
                break;
            case BOUrlEndPointSegmentEventDataGET:
                if([BOASDKManifestController sharedInstance].segmentPath != nil && [BOASDKManifestController sharedInstance].segmentPath.length>0) {
                    apiPath =[NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],[BOASDKManifestController sharedInstance].segmentPath];
                } else {
                    apiPath = [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_SEGMENT_PULL_PATH];
                }
                break;
            case BOUrlEndPointSegmentEventDataPOST:
                if([BOASDKManifestController sharedInstance].segmentPathFeedback != nil && [BOASDKManifestController sharedInstance].segmentPathFeedback.length>0) {
                    apiPath =[NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],[BOASDKManifestController sharedInstance].segmentPathFeedback];
                } else {
                    apiPath = [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_SEGMENT_PUSH_PATH];
                }
                break;
            case BOUrlEndPointGeoDataGET:
                if([BOASDKManifestController sharedInstance].geoIPPath != nil && [BOASDKManifestController sharedInstance].geoIPPath.length>0) {
                    apiPath =[NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],[BOASDKManifestController sharedInstance].geoIPPath];
                } else {
                    apiPath = [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_GEO_IP_PULL_PATH];
                }
                break;
            case BOUrlEndPointManifestGET:
                if([BOASDKManifestController sharedInstance].manifestPath != nil && [BOASDKManifestController sharedInstance].manifestPath.length>0) {
                    apiPath =[NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],[BOASDKManifestController sharedInstance].manifestPath];
                } else {
                    apiPath = [NSString stringWithFormat:@"%@/%@",[self getBaseServerUrl],BO_SDK_REST_API_MANIFEST_PULL_PATH];
                }
                break;
        }
        return apiPath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSDictionary*)prepareRequestHeaders {
    
    NSString *sdkToken = [BlotoutAnalytics isSDKInProductionMode] ? [BlotoutAnalytics blotoutSDKProdEnvKey] : [BlotoutAnalytics blotoutSDKTestEnvKey];
    
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
