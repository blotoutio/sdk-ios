//
//  BOADeveloperEventModel.m
//  BlotoutAnalytics
//
//  Created by Blotout on 30/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOADeveloperEventModel.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"


@implementation BOADeveloperEventModel

-(instancetype)initWithEventName:(NSString*)eventName andEventInfo:(NSDictionary*)eventInfo{
    
    if ((eventName == nil) || (!eventName.length) || ([eventName isEqualToString:@""]) || ([eventName isEqualToString:@" "]) || (eventName == NULL)) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.eventName = eventName;
        self.eventInfo = eventInfo;
        self.eventTimeReference = [BOAUtilities get13DigitNumberObjTimeStamp];
        self.eventDate = [BOAUtilities getCurrentDate];
        self.eventID   = [NSString stringWithFormat:@"%@_%@_%@", self.eventName, self.eventDate, self.eventTimeReference];
    }
    return self;
}

-(NSString*)updateEventID{
    @try {
        self.eventID = [NSString stringWithFormat:@"%@_%@_%@", self.eventName, self.eventDate, self.eventTimeReference];
        return self.eventID;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSDictionary*)eventInfoForStorage{
    @try {
        NSMutableDictionary *eventInStorageFormat = [NSMutableDictionary dictionary];
        [eventInStorageFormat setObject:_eventName forKey:@"eventName"];
        [eventInStorageFormat setObject:_eventDate forKey:@"eventDate"];
        [eventInStorageFormat setObject:_eventTimeReference forKey:@"eventTime"];
        
        if (_eventStartDate) {
            [eventInStorageFormat setObject:_eventStartDate forKey:@"eventStartDate"];
        }
        if (_eventStartTimeReference != nil) {
            [eventInStorageFormat setObject:_eventStartTimeReference forKey:@"eventStartTimeReference"];
        }
        if (_eventEndDate != nil) {
            [eventInStorageFormat setObject:_eventEndDate forKey:@"eventEndDate"];
        }
        if (_eventEndTimeReference != nil) {
            [eventInStorageFormat setObject:_eventEndTimeReference forKey:@"eventEndTimeReference"];
        }
        if (_eventDuration != nil) {
            [eventInStorageFormat setObject:_eventDuration forKey:@"eventDuration"];
        }
        
        if (self.eventInfo && self.eventInfo.allKeys.count > 0) {
            for (NSString *key in [_eventInfo allKeys]) {
                [eventInStorageFormat setObject:[_eventInfo objectForKey:key] forKey:key];
            }
        }
        return eventInStorageFormat;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end
