//
//  BOANetworkAndDataSync.m
//  BlotoutAnalytics
//
//  Created by Blotout on 20/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOANetworkAndDataSync.h"
#import <BlotoutFoundation/BOFNetworkPromise.h>
#import <BlotoutFoundation/BOFNetworkPromiseExecutor.h>
#import "BOAUtilities.h"
#import "BlotoutAnalytics_Internal.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
#import "BOANetworkConstants.h"

static id sBOANetworkAndDataSync = nil;

@implementation BOANetworkAndDataSync


+ (instancetype)sharedInstance {
    static dispatch_once_t boaNetworkAndDataOnceToken = 0;
    dispatch_once(&boaNetworkAndDataOnceToken, ^{
        sBOANetworkAndDataSync = [[[self class] alloc] init];
    });
    return  sBOANetworkAndDataSync;
}

- (void)checkForPiiAndSendToServer:(NSData*)serverFormatJSON{
    @try {
        if (serverFormatJSON) {
            NSString *requestUrlStr = [[BOASDKManifestController sharedInstance] getAPIEndPointFromManifestFor:EVENT_PATH];
            if (!requestUrlStr || [requestUrlStr isEqualToString:@""]) {
                NSString *urlDomainStr = @"";
                if (![BlotoutAnalytics sharedInstance].isDevModeEnabled) {
                    if ([BlotoutAnalytics isSDKInProductionMode]) {
                        urlDomainStr = BO_SDK_PROD_MODE_API_DOMAIN_PATH;
                    }else{
                        urlDomainStr = BO_SDK_STAGE_MODE_API_DOMAIN_PATH;
                    }
                }else{
                    urlDomainStr = BO_SDK_ALPHA_DEV_MODE_API_DOMAIN_PATH;
                }
                requestUrlStr = [NSString stringWithFormat:@"%@/%@",urlDomainStr,BO_SDK_REST_API_EVENTS_PUSH_PATH];
            }
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrlStr]];
            //BO_SDK_REST_API_EVENTS_PUSH
            request.HTTPMethod = @"POST";
            NSString *sdkToken = [BlotoutAnalytics isSDKInProductionMode] ? [BlotoutAnalytics blotoutSDKProdEnvKey] : [BlotoutAnalytics blotoutSDKTestEnvKey];
            [request setAllHTTPHeaderFields:@{
                BO_ACCEPT: @"application/json",
                BO_CONTENT_TYPE: @"application/json",
                BO_TOKEN: sdkToken,
                BO_VERSION: @"v1"
            }];
            [request setHTTPBody:serverFormatJSON];
            BOFNetworkPromise *netpromise = [[BOFNetworkPromise alloc] initWithURLRequest:request completionHandler:^(NSURLResponse * _Nullable urlResponse, id  _Nullable dataOrLocation, NSError * _Nullable error) {
                
                NSHTTPURLResponse *httpRes = (NSHTTPURLResponse*)urlResponse;
                BOFLogDebug(@"urlResponse:%@  dataOrLocation:%@ error:%@ urlResponse_statusCode:%ld allHeaderFields:%@", urlResponse, dataOrLocation, error, httpRes.statusCode, httpRes.allHeaderFields);
            }];
            [[BOFNetworkPromiseExecutor sharedInstance] executeNetworkPromise:netpromise];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)checkForPiiAndSendToServer:(NSString*)serverFormatJSON usingRequest:(NSURLRequest*)request{
    
}
@end
