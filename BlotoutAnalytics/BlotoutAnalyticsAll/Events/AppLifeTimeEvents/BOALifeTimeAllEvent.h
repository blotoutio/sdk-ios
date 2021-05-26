//
//  BOALifeTimeAllEvent.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOAEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOALifeTimeAllEvent : BOAEvents

- (instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (instancetype)sharedInstance;

+(NSDictionary*)appLifeTimeDefaultSingleDayDict;
+(NSDictionary*)appLifeTimeDefaultRetentionInfo;

+(NSArray*)getAllSessionFilesForTheWeek:(NSInteger)weekOfYear;
+(NSInteger)getWASTForTheWeek:(NSInteger)weekOfYear;
+(NSArray*)getAllSessionFilesForTheMonth:(NSInteger)monthOfyear;
+(NSInteger)getMASTForTheMonth:(NSInteger)monthOfyear;
+(NSArray*)lastWeekAllFiles:(NSDate*)currentDate;
+(NSInteger)lastWeekWAST:(NSDate*)currentDate;
+(NSArray*)lastMonthAllFiles:(NSDate*)currentDate;
+(NSInteger)lastMonthMAST:(NSDate*)currentDate;

-(BOOL)isWASTAlreadySetForLastWeek;
-(BOOL)isMASTAlreadySetForLastMonth;

//On App Termination
-(void)recordDAST:(nullable NSNumber*)averageTimeDAST withPayload:(nullable NSDictionary*)eventInfo;
-(void)recordWAST:(nullable NSNumber*)averageTimeWAST withPayload:(nullable NSDictionary*)eventInfo;
-(void)recordMAST:(nullable NSNumber*)averageTimeMAST withPayload:(nullable NSDictionary*)eventInfo;
-(void)recordCustomEventsWithName:(NSString*)eventName andPaylod:(nullable NSDictionary*)eventInfo;

-(void)setAppLifeTimeSystemInfoOnAppLaunch;
-(void)setLifeTimeRetentionEventsOnAppLaunch;
-(void)recordPayingUsersRetention;
-(void)recordIfAppFirstLaunch;
-(void)recordNewUser;


@end

NS_ASSUME_NONNULL_END

