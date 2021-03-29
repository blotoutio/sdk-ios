//
//  BONetworkManager.m
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BONetworkManager.h"
#import <BlotoutFoundation/BOFNetworkPromise.h>
#import <BlotoutFoundation/BOFNetworkPromiseExecutor.h>
#import <BlotoutFoundation/BOReachability.h>
#import "NSError+BOAdditions.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOANetworkConstants.h"

@implementation BONetworkManager


+ (void)asyncRequest:(NSURLRequest *)request
             success:(void(^)(id, NSURLResponse *))successBlock_
             failure:(void(^)(id, NSURLResponse *, NSError *))failureBlock_ {
    
    @try {
        if ([[BOReachability reachabilityForInternetConnection] currentReachabilityStatus] == BONotReachable) {
            NSError *error = [NSError boErrorForCode:BOErrorNoInternetConnection withMessage:@"Network Not Reachable"];
            failureBlock_(nil, nil,error);
            return;
        }
        
        BOFNetworkPromise *netpromise = [[BOFNetworkPromise alloc] initWithURLRequest:request completionHandler:^(NSURLResponse * _Nullable urlResponse, id  _Nullable dataOrLocation, NSError * _Nullable error) {
            
            NSHTTPURLResponse *httpRes = (NSHTTPURLResponse*)urlResponse;
            
            if(httpRes.statusCode  == 200) {
                successBlock_(dataOrLocation,urlResponse);
            } else {
                failureBlock_(dataOrLocation,urlResponse,error);
            }
            
            BOFLogDebug(@"urlResponse:%@  dataOrLocation:%@ error:%@ urlResponse_statusCode:%ld allHeaderFields:%@", urlResponse, dataOrLocation, error, httpRes.statusCode, httpRes.allHeaderFields);
        }];
        
        [[BOFNetworkPromiseExecutor sharedInstance] executeNetworkPromise:netpromise];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        failureBlock_(nil, nil, [NSError boErrorForDict:exception.userInfo]);
    }
}
@end
