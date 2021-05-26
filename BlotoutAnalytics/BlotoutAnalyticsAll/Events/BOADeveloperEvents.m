//
//  BOADeveloperEvents.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOADeveloperEvents.h"
#import "BOADeveloperEventModel.h"
#import "BOAConstants.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOALocalDefaultJSONs.h"
#import "BOAppSessionData.h"
#import "BOAAppLifetimeData.h"
#import "BOAEvents.h"
#import "BOAUtilities.h"
#import "BOASdkToServerFormat.h"
#import "BOAFunnelSyncController.h"
#import "BOAConstants.h"
#import "BOANetworkConstants.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOSharedManager.h"

static id sBOADevEventsSharedInstance = nil;

@interface BOADeveloperEvents (){
    BOAppSessionData *appSessionModel;
    BOAAppLifetimeData *appLifeTimeModel;
}
@property (nonatomic, strong) BOAFunnelSyncController *funnelSyncController;
@end

@implementation BOADeveloperEvents

-(instancetype)init{
    self = [super init];
    if (self) {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        self.devEventUD = [[analyticsRootUD objectForKey:BO_ANALYTICS_DEV_EVENT_USER_DEFAULTS_KEY] mutableCopy];
        if (!self.devEventUD) {
            self.devEventUD = [NSMutableDictionary dictionary];
            [analyticsRootUD setObject:self.devEventUD forKey:BO_ANALYTICS_DEV_EVENT_USER_DEFAULTS_KEY];
        }
        self.isEnabled = YES;
        //default is enabled
        self.funnelSyncController = [BOAFunnelSyncController sharedInstanceFunnelController];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaDeveloperEventsOnceToken = 0;
    dispatch_once(&boaDeveloperEventsOnceToken, ^{
        sBOADevEventsSharedInstance = [[[self class] alloc] init];
    });
    return  sBOADevEventsSharedInstance;
}

-(void)startTimedEvent:(NSString*)eventName withInformation:(NSDictionary*)startEventInfo{
    @try {
        if (!self.isEnabled) {
            return;
        }
        //Write cleanup feature for the events which got started but never ended even after 30 days
        NSMutableDictionary *eventStartInfo = [self.devEventUD objectForKey:eventName];
        if (eventStartInfo && (eventStartInfo.allKeys.count > 0)) {
            [eventStartInfo setObject:@"Yes" forKey:@"autoEnd"];
            [self endTimedEvent:eventName withInformation:eventStartInfo];
            [self.devEventUD removeObjectForKey:eventName];
        }
        BOADeveloperEventModel *event = [[BOADeveloperEventModel alloc] initWithEventName:eventName andEventInfo:startEventInfo];
        event.eventStartTimeReference = [BOAUtilities get13DigitNumberObjTimeStamp];
        event.eventStartDate = [BOAUtilities getCurrentDate];
        
        NSMutableDictionary *eventStartStorage = [[event eventInfoForStorage] mutableCopy];
        [eventStartStorage setObject:[NSString stringWithFormat:@"%@",[[self topViewController] class]] forKey:@"startVisibleClassName"];
        [self.devEventUD setObject:eventStartStorage forKey:event.eventName];
        //Merge with end
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)endTimedEvent:(NSString*)eventName withInformation:(NSDictionary*)endEventInfo{
    @try {
        if (!self.isEnabled) {
            return;
        }
        NSDictionary *eventStartInfo = [self.devEventUD objectForKey:eventName];
        if (!eventStartInfo) {
            [self logEvent:eventName withInformation:endEventInfo withEventCode:[NSNumber numberWithInt:0]];
        }
        
        BOADeveloperEventModel *event = [[BOADeveloperEventModel alloc] initWithEventName:eventName andEventInfo:endEventInfo];
        event.eventEndTimeReference = [BOAUtilities get13DigitNumberObjTimeStamp];
        event.eventEndDate = [BOAUtilities getCurrentDate];
        
        double eventDuration = [event.eventEndTimeReference doubleValue] - [(NSNumber*)[eventStartInfo objectForKey:@"eventStartTimeReference"] doubleValue];
        event.eventDuration = [NSNumber numberWithDouble:eventDuration];
        
        NSMutableDictionary *eventEndAndStartInfo = [[event eventInfoForStorage] mutableCopy];
        if (eventStartInfo.allKeys.count > 0) {
            [eventEndAndStartInfo setObject:eventStartInfo forKey:@"eventStartInfo"];
            [self.devEventUD removeObjectForKey:eventName];
        }
        [eventEndAndStartInfo setObject:event.eventDuration forKey:@"eventDuration"];
        NSDictionary *timeEventInfo = @{};
        NSDictionary *timeEventDict = @{
            @"sentToServer":[NSNumber numberWithBool:NO],
            @"mid": [BOAUtilities getMessageIDForEvent:eventName],
            @"timeStamp": event.eventEndTimeReference,
            @"eventName": eventName,
            @"startTime": [eventStartInfo objectForKey:@"eventStartTimeReference"],
            @"startVisibleClassName": [eventStartInfo objectForKey:@"startVisibleClassName"],
            @"endVisibleClassName": [NSString stringWithFormat:@"%@",[[self topViewController] class]],
            @"endTime": event.eventEndTimeReference,
            @"eventDuration": event.eventDuration,
            @"timedEvenInfo" : timeEventInfo,
            @"session_id":[BOSharedManager sharedInstance].sessionId
        };
        BOTimedEvent *timedEvent = [BOTimedEvent fromJSONDictionary:timeEventDict];
        NSMutableArray *existingTimedEvent = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified.timedEvent mutableCopy];
        [existingTimedEvent addObject:timedEvent];
        [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified setTimedEvent:existingTimedEvent];
        
        NSNumber *eventSubCode = [BOAUtilities codeForCustomCodifiedEvent:NSNullifyCheck(eventName)];
        //Funnel execution and testing based
        [[BOAFunnelSyncController sharedInstanceFunnelController] recordDevEvent:eventName withEventSubCode:eventSubCode withDetails:timeEventDict];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)logEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo withEventCode:(NSNumber*)eventCode{
    @try {
        if (!self.isEnabled) {
            return;
        }
        [self logEvent:eventName withInformation:eventInfo happendAt:nil withEventCode:eventCode];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)logEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime{
    
}

-(void)logEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime withEventCode:(NSNumber*)eventCode{
    @try {
        if (!self.isEnabled) {
            return;
        }
        if (BOAEvents.isSessionModelInitialised) {
            NSNumber *timeStamp = eventTime ? [BOAUtilities get13DigitNumberObjTimeStampFor:eventTime] : [BOAUtilities get13DigitNumberObjTimeStamp];
            
            NSString *visibleVC = [self topViewController] ? [NSString stringWithFormat:@"%@",[[self topViewController] class]] : [NSString stringWithFormat:@"%@",[[[UIApplication sharedApplication] delegate] class]];
            
            //if ([eventName isEqualToString:@"customeEvent"])
            NSNumber *eventSubCode = [[NSNumber alloc] init];
            if([eventCode intValue] == 0) {
                eventSubCode = [BOAUtilities codeForCustomCodifiedEvent:NSNullifyCheck(eventName)];
            } else {
                eventSubCode = eventCode;
            }
            NSDictionary *customEventModelDict = @{
                BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:eventName],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP: timeStamp,
                BO_EVENT_NAME: NSNullifyCheck(eventName),
                BO_EVENT_SUB_CODE: eventSubCode,
                BO_VISIBLE_CLASS_NAME: visibleVC,
                BO_EVENT_INFO: NSNullifyDictCheck(eventInfo)
            };
            BOCustomEvent *costumEventModel = [BOCustomEvent fromJSONDictionary:customEventModelDict];
            NSMutableArray *existingCustomEvent = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified.customEvents mutableCopy];
            [existingCustomEvent addObject:costumEventModel];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified setCustomEvents:existingCustomEvent];
            
            //Funnel execution and testing based
            [[BOAFunnelSyncController sharedInstanceFunnelController] recordDevEvent:NSNullifyCheck(eventName) withEventSubCode:eventSubCode withDetails:customEventModelDict];
            
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)logPIIEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime{
    @try {
        if (!self.isEnabled) {
            return;
        }
        if (BOAEvents.isSessionModelInitialised) {
            NSNumber *timeStamp = eventTime ? [BOAUtilities get13DigitNumberObjTimeStampFor:eventTime] : [BOAUtilities get13DigitNumberObjTimeStamp];
            
            NSString *visibleVC = [self topViewController] ? [NSString stringWithFormat:@"%@",[[self topViewController] class]] : [NSString stringWithFormat:@"%@",[[[UIApplication sharedApplication] delegate] class]];
            
            //if ([eventName isEqualToString:@"customeEvent"])
            NSNumber *eventSubCode = [BOAUtilities codeForCustomCodifiedEvent:NSNullifyCheck(eventName)];
            NSDictionary *customEventModelDict = @{
                BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:eventName],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP: timeStamp,
                BO_EVENT_NAME: NSNullifyCheck(eventName),
                BO_EVENT_SUB_CODE: eventSubCode,
                BO_VISIBLE_CLASS_NAME: visibleVC,
                BO_EVENT_INFO: NSNullifyDictCheck(eventInfo)
            };
            BOCustomEvent *costumEventModel = [BOCustomEvent fromJSONDictionary:customEventModelDict];
            NSMutableArray *existingCustomEvent = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified.piiEvents mutableCopy];
            [existingCustomEvent addObject:costumEventModel];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified setPiiEvents:existingCustomEvent];
            
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)logPHIEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime{
    @try {
        if (!self.isEnabled) {
            return;
        }
        if (BOAEvents.isSessionModelInitialised) {
            NSNumber *timeStamp = eventTime ? [BOAUtilities get13DigitNumberObjTimeStampFor:eventTime] : [BOAUtilities get13DigitNumberObjTimeStamp];
            
            NSString *visibleVC = [self topViewController] ? [NSString stringWithFormat:@"%@",[[self topViewController] class]] : [NSString stringWithFormat:@"%@",[[[UIApplication sharedApplication] delegate] class]];
            
            //if ([eventName isEqualToString:@"customeEvent"])
            NSNumber *eventSubCode = [BOAUtilities codeForCustomCodifiedEvent:NSNullifyCheck(eventName)];
            NSDictionary *customEventModelDict = @{
                BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:eventName],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP: timeStamp,
                BO_EVENT_NAME: NSNullifyCheck(eventName),
                BO_EVENT_SUB_CODE: eventSubCode,
                BO_VISIBLE_CLASS_NAME: visibleVC,
                BO_EVENT_INFO: NSNullifyDictCheck(eventInfo)
            };
            BOCustomEvent *costumEventModel = [BOCustomEvent fromJSONDictionary:customEventModelDict];
            NSMutableArray *existingCustomEvent = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified.phiEvents mutableCopy];
            [existingCustomEvent addObject:costumEventModel];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified setPhiEvents:existingCustomEvent];
            
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

@end
