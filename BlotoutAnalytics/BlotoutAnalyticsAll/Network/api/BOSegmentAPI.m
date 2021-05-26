//
//  BOEventPostAPI.m
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOSegmentAPI.h"
#import "BOAUtilities.h"
#import "BlotoutAnalytics_Internal.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
#import "BOANetworkConstants.h"
#import "NSError+BOAdditions.h"
#import "BOASegmentEvents.h"

@implementation BOSegmentAPI

/* These method used to Post Qualified Segment to server */
-(void)postSegmentDataModel:(NSData*)eventData success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    
    @try {
        NSString *apiEndPoint = [self resolveAPIEndPoint:BOUrlEndPointSegmentEventDataPOST];
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

/* These method used to get new segments from server */
-(void)getSegmentDataModel:(NSData*)eventData success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    @try {
        
        NSString *apiEndPoint = [self resolveAPIEndPoint:BOUrlEndPointSegmentEventDataGET];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiEndPoint]];
        [urlRequest setHTTPMethod:EPAPostAPI];
        
        [urlRequest setAllHTTPHeaderFields:[self prepareRequestHeaders]];
        
        if(eventData != nil) {
            [urlRequest setHTTPBody:eventData];
        }
        BOFLogDebug(@"DebugAPI_payload Event Data in Body %@", [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding]);
        
        [BONetworkManager asyncRequest:urlRequest success:^(id data , NSURLResponse *dataResponse) {
            
            NSError *segmentDecodeError = nil;
            BOASegmentEvents *segmentEvents = [BOASegmentEvents fromData:data error:&segmentDecodeError];
            if(segmentDecodeError == nil) {
                success(segmentEvents);
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
