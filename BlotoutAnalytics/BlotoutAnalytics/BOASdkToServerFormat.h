//
//  BOASdkToServerFormat.h
//  BlotoutAnalytics
//
//  Created by Blotout on 20/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOAppSessionData.h"
#import "BOASystemAndDeveloperEvents.h"
#import "BOAAppLifetimeData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOASdkToServerFormat : NSObject

@property (assign, nonatomic) BOOL isPayingUser;

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

-(NSData*)serverFormatEventsJSONFrom:(BOAppSessionData*)sessionData;
-(NSData*)serverFormatRetentionEventsJSONFrom:(BOAppSessionData*)sessionData;
-(BOASystemAndDeveloperEvents*)serverFormatEventsFrom:(BOAppSessionData*)sessionData;
-(BOASystemAndDeveloperEvents*)serverFormatRetentionEventsFrom:(BOAppSessionData*)sessionData;

-(NSData*)serverFormatLifeTimeEventsJSONFrom:(BOAAppLifetimeData*)lifetimeSessionData;
-(NSData*)serverFormatLifeTimeRetentionEventsJSONFrom:(BOAAppLifetimeData*)lifetimeSessionData;
-(BOASystemAndDeveloperEvents*)serverFormatLifeTimeEventsFrom:(BOAAppLifetimeData*)lifetimeSessionData;
-(BOASystemAndDeveloperEvents*)serverFormatLifeTimeRetentionEventsFrom:(BOAAppLifetimeData*)lifetimeSessionData;
-(BOASystemAndDeveloperEvents*)serverFormatPIIPHIEventsFrom:(BOAppSessionData*)sessionData;
-(BOASystemAndDeveloperEvents*)createEventObject:(NSString*)eventName withEventCategory:(NSNumber*)eventCategory withEventSubcode:(NSNumber*)eventSubcode;

@end

NS_ASSUME_NONNULL_END
