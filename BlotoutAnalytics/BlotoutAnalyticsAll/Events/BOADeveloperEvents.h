//
//  BOADeveloperEvents.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOADeveloperEvents : BOAEvents

@property (nonatomic, readwrite) BOOL isEnabled;
@property (nonatomic, strong) NSMutableDictionary *devEventUD;

- (instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (instancetype)sharedInstance;

-(void)startTimedEvent:(NSString*)eventName withInformation:(NSDictionary*)startEventInfo;
-(void)endTimedEvent:(NSString*)eventName withInformation:(NSDictionary*)endEventInfo;

-(void)logEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo withEventCode:(NSNumber*)eventCode;
-(void)logEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime;
-(void)logPIIEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime;
-(void)logPHIEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime;

@end

NS_ASSUME_NONNULL_END
