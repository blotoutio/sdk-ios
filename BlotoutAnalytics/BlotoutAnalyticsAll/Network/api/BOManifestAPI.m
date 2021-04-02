//
//  BOEventPostAPI.m
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOManifestAPI.h"
#import "BOAUtilities.h"
#import "BlotoutAnalytics_Internal.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOANetworkConstants.h"
#import "NSError+BOAdditions.h"
#import "BOASDKManifest.h"

@implementation BOManifestAPI

-(void)getManifestDataModel:(NSData*)eventData success:(void (^)(id responseObject, id data))success failure:(void (^)(NSError *error))failure {
    @try {
        
        NSString *apiEndPoint = [self resolveAPIEndPoint:BOUrlEndPointManifestGET];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiEndPoint]];
        [urlRequest setHTTPMethod:EPAPostAPI];
        
        [urlRequest setAllHTTPHeaderFields:[self prepareRequestHeaders]];
        
        if(eventData != nil) {
            [urlRequest setHTTPBody:eventData];
        }
        BOFLogDebug(@"DebugAPI_payload Event Data in Body %@", [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding]);
        
        [BONetworkManager asyncRequest:urlRequest success:^(id data , NSURLResponse *dataResponse) {
            data = [self checkForNullValue:data];
            NSError *manifestReadError;
            BOASDKManifest *sdkManifestM = [BOASDKManifest fromData:data error:&manifestReadError];
            if(manifestReadError == nil) {
                success(sdkManifestM,data);
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
