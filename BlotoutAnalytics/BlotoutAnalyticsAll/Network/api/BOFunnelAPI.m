//
//  BOEventPostAPI.m
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFunnelAPI.h"
#import "BOAUtilities.h"
#import "BlotoutAnalytics_Internal.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
#import "BOANetworkConstants.h"
#import "NSError+BOAdditions.h"
#import "BOAFunnelAndCodifiedEvents.h"


@implementation BOFunnelAPI

-(void)postFunnelDataModel:(NSData*)eventData success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    
    @try {
        NSString *apiEndPoint = [self resolveAPIEndPoint:BOUrlEndPointFunnelEventDataPOST];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiEndPoint]];
        [urlRequest setHTTPMethod:EPAPostAPI];
        
        [urlRequest setAllHTTPHeaderFields:[self prepareRequestHeaders]];
        if(eventData != nil) {
            [urlRequest setHTTPBody:eventData];
        }
        
        BOFLogDebug(@"DebugAPI_payload Event Data in Body %@", [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding]);
        
        [BONetworkManager asyncRequest:urlRequest success:^(id data , NSURLResponse *dataResponse) {
            
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                success (dict);
            }else{
                NSError *error = [NSError boErrorForCode:BOErrorParsingError withMessage:nil];
                failure(error);
            }
            
        } failure:^(id data, NSURLResponse *dataResponse, NSError *error) {
            failure(error);
        }];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        NSError *error = [NSError boErrorForCode:BOErrorParsingError withMessage:nil];
        failure(error);
    }
}

-(void)getFunnelDataModel:(NSData*)eventData success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    @try {
        
        NSString *apiEndPoint = [self resolveAPIEndPoint:BOUrlEndPointFunnelEventDataGET];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiEndPoint]];
        [urlRequest setHTTPMethod:EPAPostAPI];
        
        [urlRequest setAllHTTPHeaderFields:[self prepareRequestHeaders]];
        
        if(eventData != nil) {
            [urlRequest setHTTPBody:eventData];
        }
        
        BOFLogDebug(@"DebugAPI_payload Event Data in Body %@", [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding]);
        
        [BONetworkManager asyncRequest:urlRequest success:^(id data , NSURLResponse *dataResponse) {
            
            NSError *funnelDecodeError = nil;
            BOAFunnelAndCodifiedEvents *codifiedAndFunnel = [BOAFunnelAndCodifiedEvents fromData:data error:&funnelDecodeError];
            if(funnelDecodeError == nil) {
                success(codifiedAndFunnel);
            } else {
                NSError *error = [NSError boErrorForCode:BOErrorParsingError withMessage:nil];
                failure(error);
            }
            
        } failure:^(id data, NSURLResponse *dataResponse, NSError *error) {
            failure(error);
        }];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        NSError *error = [NSError boErrorForCode:BOErrorParsingError withMessage:nil];
        failure(error);
    }
}

@end
