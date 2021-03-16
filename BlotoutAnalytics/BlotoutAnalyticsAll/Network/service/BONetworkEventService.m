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
#import "BOAUtilities.h"
#import "BOSharedManager.h"
#import <BlotoutFoundation/BOReachability.h>

@implementation BONetworkEventService

+(void)sendSdkStartEvent:(NSString*)screenName {
    
    if ([[BOReachability reachabilityForInternetConnection] currentReachabilityStatus] == BONotReachable) {
        BOAppSessionData *sInstance = [BOAppSessionData sharedInstanceFromJSONDictionary:nil];
        
        BOApp *appStates = [BOApp fromJSONDictionary:@{
            BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
            BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_SDK_START], // discuss this
            BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
            BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
            BO_VISIBLE_CLASS_NAME:screenName
        }];
        NSMutableArray *existingData = [sInstance.singleDaySessions.appStates.sdkStart mutableCopy];
        [existingData addObject:appStates];
        [sInstance.singleDaySessions.appStates setSdkStart:existingData];
    } else {
        [[BOEventsOperationExecutor sharedInstance] dispatchInitializationInBackground:^{
            BOASystemAndDeveloperEvents *event = [[BOASdkToServerFormat sharedInstance] createEventObject:BO_SDK_START withScreenName:screenName withEventSubcode:[NSNumber numberWithInt:BO_EVENT_SDK_START]];
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
        } afterDelay:0];
    }
}

+(void)sendPageHideEvent:(NSString*)screenName storeEvents:(BOOL)storeEvent {
    
    if ([[BOReachability reachabilityForInternetConnection] currentReachabilityStatus] == BONotReachable || storeEvent) {
        BOAppSessionData *sInstance = [BOAppSessionData sharedInstanceFromJSONDictionary:nil];
        
        BOApp *appStates = [BOApp fromJSONDictionary:@{
            BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
            BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_PAGE_HIDE], // discuss this
            BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
            BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
            BO_VISIBLE_CLASS_NAME:screenName
        }];
        NSMutableArray *existingData = [sInstance.singleDaySessions.appStates.pageHide mutableCopy];
        [existingData addObject:appStates];
        [sInstance.singleDaySessions.appStates setPageHide:existingData];
    } else {
        [[BOEventsOperationExecutor sharedInstance] dispatchInitializationInBackground:^{
            BOASystemAndDeveloperEvents *event = [[BOASdkToServerFormat sharedInstance] createEventObject:BO_PAGE_HIDE withScreenName:screenName withEventSubcode:[NSNumber numberWithInt:BO_EVENT_PAGE_HIDE]];
            NSError *dataError = nil;
            NSUInteger apiEnumCode = BOUrlEndPointEventDataPOST;
            NSData *eventJSONData = [event toEventsData:&dataError];
            
            if (eventJSONData && !dataError) {
                BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
                [api postEventDataModel:eventJSONData withAPICode:apiEnumCode success:^(id  _Nonnull responseObject) {
                    BOFLogDebug(@"pagehide event sent");
                } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
                    BOFLogDebug(@"pagehide event failed");
                }];
            }
        } afterDelay:0];
    }
    
}

@end



