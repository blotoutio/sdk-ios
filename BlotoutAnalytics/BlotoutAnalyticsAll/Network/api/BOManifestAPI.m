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
#import "BOEventsOperationExecutor.h"

@implementation BOManifestAPI

-(void)getManifestDataModel:(void (^)(id responseObject, id data))success failure:(void (^)(NSError *error))failure {
  @try {
    NSString *apiEndPoint = [self resolveAPIEndPoint:BOUrlEndPointManifestPull];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiEndPoint]];
    [urlRequest setHTTPMethod:EPAPostAPI];
    [urlRequest setAllHTTPHeaderFields:[self prepareRequestHeaders]];
    
     
    [BONetworkManager asyncRequest:urlRequest success:^(id data, NSURLResponse *dataResponse) {
   
        __block id blockData = data;
        [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
            blockData = [self checkForNullValue:blockData];
      NSError *manifestReadError;
      BOASDKManifest *sdkManifestM = [BOASDKManifest fromData:blockData error:&manifestReadError];
      if (manifestReadError == nil) {
        success(sdkManifestM, blockData);
        return;
      }
      
      NSError *error = [NSError boErrorForCode:BOErrorParsingError withMessage:nil];
      failure(error);
        }];
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
