//
//  BOEventPostAPI.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOEventPostAPI.h"
#import "BOAUtilities.h"
#import "BlotoutAnalytics_Internal.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOANetworkConstants.h"
#import "NSError+BOAdditions.h"

@implementation BOEventPostAPI

-(void)postEventDataModel:(NSData*)eventData withAPICode:(BOUrlEndPoint)urlEndPoint success:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure {
  @try {
    NSString *apiEndPoint = [self resolveAPIEndPoint:urlEndPoint];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiEndPoint]];
    [urlRequest setHTTPMethod:EPAPostAPI];
    [urlRequest setAllHTTPHeaderFields:[self prepareRequestHeaders]];
    
    if (eventData != nil) {
      [urlRequest setHTTPBody:eventData];
    }
    
    BOFLogDebug(@"DebugAPI_payload Event Data in Body %@", [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding]);
    
    [BONetworkManager asyncRequest:urlRequest success:^(id data , NSURLResponse *dataResponse) {
      if (!data) {
        success(dataResponse);
        return;
      }
      
      NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
      success(dict);
    } failure:^(id data, NSURLResponse *dataResponse, NSError *error) {
      NSDictionary *dict1 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
      BOFLogDebug(@"%@",dict1);
      failure(dataResponse,data,error);
    }];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    NSError *error = [NSError boErrorForCode:BOErrorParsingError withMessage:nil];
    failure(nil,nil,error);
  }
}
@end
