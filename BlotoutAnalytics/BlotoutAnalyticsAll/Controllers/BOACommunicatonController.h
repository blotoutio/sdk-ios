//
//  BOACommunicatonController.h
//  BlotoutAnalytics
//
//  Created by Blotout on 23/11/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOANotificationConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOACommunicatonController : NSObject

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

//Generic Delegate based message communication, will plan later
//@property (strong, nonatomic) NSMutableDictionary <NSString*, NSMutableArray*>*notificationReceivers;

-(void)postMessage:(NSString*)messageName asNotifications:(BOOL)notify;
-(void)postMessage:(NSString*)messageStr withObject:(id)extraInfo asNotifications:(BOOL)notify;
-(void)postMessage:(NSString*)messageStr withObject:(id)extraInfo andUserInfo:(NSDictionary*)userInfo asNotifications:(BOOL)notify;

@end

NS_ASSUME_NONNULL_END
