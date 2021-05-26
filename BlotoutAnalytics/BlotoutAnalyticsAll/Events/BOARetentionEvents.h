//
//  BOANonPiiEvents.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOARetentionEvents : BOAEvents

@property (nonatomic, readwrite) BOOL isEnabled;

- (instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (instancetype)sharedInstance;

-(void)recordDAUwithPayload:(nullable NSDictionary*)eventInfo;
-(void)recordDPUwithPayload:(nullable NSNotification*)eventInfo;
-(void)recordAppInstalled:(BOOL)isFirstLaunch withPayload:(nullable NSDictionary*)eventInfo;
-(void)recordNewUser:(BOOL)isNewUser withPayload:(nullable NSDictionary*)eventInfo;
//-(void)recordDAST:(NSNumber*)averageTime withPayload:(nullable NSDictionary*)eventInfo;
-(void)recordDAST:(NSNumber*)averageTime forSession:(NSDictionary*)sessionDict withPayload:(nullable NSDictionary<NSString *, NSString *>*)eventInfo;
-(void)recordCustomEventsWithName:(NSString*)eventName andPaylod:(nullable NSDictionary*)eventInfo;
-(void)storeDASTupdatedSessionFile:(BOAppSessionData*)apSessionData;

@end

NS_ASSUME_NONNULL_END
