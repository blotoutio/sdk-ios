//
//  BOPendingEvents.h
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 24/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, BOPendingEventType) {
    BO_PENDING_EVENT_TYPE_SESSION = 0,
    BO_PENDING_EVENT_TYPE_SESSION_WITH_TIME = 1,
    BO_PENDING_EVENT_TYPE_PII = 2,
    BO_PENDING_EVENT_TYPE_PHI = 3,
    BO_PENDING_EVENT_TYPE_START_TIMED_EVENT = 4,
    BO_PENDING_EVENT_TYPE_END_TIMED_EVENT = 5,
    BO_PENDING_EVENT_TYPE_RETENTION_EVENT = 6
};


@interface BOPendingEvents : NSObject

@property(nonatomic,strong) NSString *eventName;
@property(nonatomic,strong) NSDictionary *eventInfo;
@property(nonatomic,strong) NSDate *eventTime;
@property(nonatomic,readwrite) BOPendingEventType eventType;
@property (nonatomic, nullable, strong) NSNumber *eventCode;

@end

NS_ASSUME_NONNULL_END
