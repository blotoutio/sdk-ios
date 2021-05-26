//
//  BOCommonEvents.m
//  BlotoutAnalytics
//
//  Created by Blotout on 23/05/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import "BOCommonEvents.h"
#import "BOAppSessionData.h"
#import "BOAConstants.h"
#import "BOAUtilities.h"
#import "BOANetworkConstants.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOSharedManager.h"
static id sBOCommonEventsSharedInstance = nil;

@interface BOCommonEvents (){
    BOOL isEnabled;
}
@end

@implementation BOCommonEvents

-(instancetype)init{
    self = [super init];
    if (self) {
        isEnabled = YES;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaLifeTimeEventsOnceToken = 0;
    dispatch_once(&boaLifeTimeEventsOnceToken, ^{
        sBOCommonEventsSharedInstance = [[[self class] alloc] init];
    });
    return  sBOCommonEventsSharedInstance;
}

-(void)recordFunnelReceived{
    @try {
        if (BOAEvents.isSessionModelInitialised && isEnabled) {
            NSString *eventName = @"funnelReceived";
            NSNumber *eventCode = [NSNumber numberWithInt: BO_EVENT_FUNNEL_KEY];
            NSNumber *eventSubCode = [NSNumber numberWithInt: BO_FUNNEL_RECEIVED];
            BOCommonEvent *eventInfo = [BOCommonEvent fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent: eventName],
                @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                @"eventInfo": NSNull.null,
                @"eventSubCode":NSNullifyCheck(eventSubCode),
                @"eventCode":NSNullifyCheck(eventCode),
                @"eventName":NSNullifyDictCheck(eventName),
                @"visibleClassName":NSNullifyCheck([NSString stringWithFormat:@"%@",[[self topViewController] class]]),
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }
                                        ];
            NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.commonEvents mutableCopy];
            [existingData addObject:eventInfo];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setCommonEvents:existingData];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordFunnelTriggered{
    @try {
        if (BOAEvents.isSessionModelInitialised && isEnabled) {
            NSString *eventName = @"funnelTriggered";
            NSNumber *eventCode = [NSNumber numberWithInt: BO_EVENT_FUNNEL_KEY];
            NSNumber *eventSubCode = [NSNumber numberWithInt: BO_FUNNEL_TRIGGERED];
            BOCommonEvent *eventInfo = [BOCommonEvent fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent: eventName],
                @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                @"eventInfo": NSNull.null,
                @"eventSubCode":NSNullifyCheck(eventSubCode),
                @"eventCode":NSNullifyCheck(eventCode),
                @"eventName":NSNullifyDictCheck(eventName),
                @"visibleClassName":NSNullifyCheck([NSString stringWithFormat:@"%@",[[self topViewController] class]]),
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }
                                        ];
            NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.commonEvents mutableCopy];
            [existingData addObject:eventInfo];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setCommonEvents:existingData];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordSegmentReceived{
    @try {
        if (BOAEvents.isSessionModelInitialised && isEnabled) {
            NSString *eventName = @"segmentReceived";
            NSNumber *eventCode = [NSNumber numberWithInt: BO_EVENT_SEGMENT_KEY];
            NSNumber *eventSubCode = [NSNumber numberWithInt: BO_SEGMENT_RECEIVED];
            BOCommonEvent *eventInfo = [BOCommonEvent fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent: eventName],
                @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                @"eventInfo": NSNull.null,
                @"eventSubCode":NSNullifyCheck(eventSubCode),
                @"eventCode":NSNullifyCheck(eventCode),
                @"eventName":NSNullifyDictCheck(eventName),
                @"visibleClassName":NSNullifyCheck([NSString stringWithFormat:@"%@",[[self topViewController] class]]),
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }
                                        ];
            NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.commonEvents mutableCopy];
            [existingData addObject:eventInfo];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setCommonEvents:existingData];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordSegmentTriggered{
    @try {
        if (BOAEvents.isSessionModelInitialised && isEnabled) {
            NSString *eventName = @"segmentTriggered";
            NSNumber *eventCode = [NSNumber numberWithInt: BO_EVENT_SEGMENT_KEY];
            NSNumber *eventSubCode = [NSNumber numberWithInt: BO_SEGMENT_TRIGGERED];
            BOCommonEvent *eventInfo = [BOCommonEvent fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent: eventName],
                @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                @"eventInfo": NSNull.null,
                @"eventSubCode":NSNullifyCheck(eventSubCode),
                @"eventCode":NSNullifyCheck(eventCode),
                @"eventName":NSNullifyDictCheck(eventName),
                @"visibleClassName":NSNullifyCheck([NSString stringWithFormat:@"%@",[[self topViewController] class]]),
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }
                                        ];
            NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.commonEvents mutableCopy];
            [existingData addObject:eventInfo];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setCommonEvents:existingData];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}
@end
