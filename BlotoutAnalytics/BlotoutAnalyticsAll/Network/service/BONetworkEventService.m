//
//  BONetworkEventService.m
//  BlotoutAnalytics
//
//  Created by Pawan Singh Jat on 19/01/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "BONetworkEventService.h"
#import "BOEventsOperationExecutor.h"
#import "BOASdkToServerFormat.h"
#import "BOANetworkConstants.h"
#import "BOBaseAPI.h"
#import "BOEventPostAPI.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

@implementation BONetworkEventService

+(void)sendSdkStartEvent {
    
    [[BOEventsOperationExecutor sharedInstance] dispatchInitializationInBackground:^{
        BOASystemAndDeveloperEvents *event = [[BOASdkToServerFormat sharedInstance] createEventObject:BO_SDK_START withEventCategory:[NSNumber numberWithInt:BO_EVENT_SYSTEM_KEY] withEventSubcode:[NSNumber numberWithInt:BO_EVENT_SDK_START]];
        NSError *dataError = nil;
        NSUInteger apiEnumCode = BOUrlEndPointEventDataPOST;
        NSData *eventJSONData = [event toEventsData:&dataError];
                
        if (eventJSONData && !dataError) {
            BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
            [api postEventDataModel:eventJSONData withAPICode:apiEnumCode success:^(id  _Nonnull responseObject) {
                BOFLogDebug(@"sdk_start event sent");
            } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
                BOFLogDebug(@"sdk_start event failed");
            }];
        }
    } afterDelay:BO_DEFAULT_EVENT_PUSH_TIME];
}

@end



