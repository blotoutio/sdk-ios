//
//  BOASDKServerPostSyncEventConfiguration.h
//  BlotoutAnalytics
//
//  Created by Blotout on 27/02/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOAppSessionData.h"
#import "BOAAppLifetimeData.h"
#import "BOASystemAndDeveloperEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOASDKServerPostSyncEventConfiguration : NSObject

@property (strong, nonatomic) BOAppSessionData *sessionObject;
@property (strong, nonatomic) BOAAppLifetimeData *lifetimeDataObject;

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

-(void)updateSentToServerForSessionEvents:(BOASystemAndDeveloperEvents*)events;
-(void)updateSentToServerForLifeTimeEvents:(BOASystemAndDeveloperEvents*)events;

-(void)updateSentToServerForEvents:(BOASystemAndDeveloperEvents*)groupedEvents forSessionData:(BOAppSessionData*)sessionData;
-(void)updateSentToServerForEvents:(BOASystemAndDeveloperEvents*)groupedEvents forLifeTimeData:(BOAAppLifetimeData*)lifeTimeData;

-(void)updateConfigForEvent:(BOAEvent*)serverEvent having:(NSNumber*)eventCode andSubCode:(NSNumber*)subCode withMID:(NSString*)messageID inSessionDataObject:(BOAppSessionData*)sessionData;
-(void)updateConfigForEvent:(BOAEvent*)serverEvent having:(NSNumber*)eventCode andSubCode:(NSNumber*)subCode withMID:(NSString*)messageID inLifetimeDataObject:(BOAAppLifetimeData*)lifetimeData;

-(void)updateDeveloperCodifiedEvents:(BOAEvent*)serverEvent forSession:(BOAppSessionData*)sessionObject;

-(void)updateSentToServerForPIIPHIEvents:(BOASystemAndDeveloperEvents*)groupedEvents forSessionData:(BOAppSessionData*)sessionData;

@end

NS_ASSUME_NONNULL_END
