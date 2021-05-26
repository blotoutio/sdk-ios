//
//  BOASessionEvents.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAEvents.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOAAppSessionEvents : BOAEvents

@property (nonatomic, readwrite) BOOL isEnabled;
@property (nonatomic, strong) NSMutableDictionary *appSessionUD;
@property (nonatomic, strong) NSMutableDictionary *sessionAppInfo;

- (instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (instancetype)sharedInstance;

-(void)startRecordingEvnets;
-(void)stopRecordingEvnets;
//-(void)recordAppState:(NSString*)appState withInfo:(NSNotification *) noteInfo;
-(void)postInitLaunchEventsRecording;

-(void)recordSessionOnDayChangeOrAppTermination:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler;
-(void)recordLifeTimeOnDayChangeOrAppTermination:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler;

//Refactor for proper code place
-(NSDictionary*)getGeoIPAndPublishWith:(void (^)(NSDictionary *currentLocation, NSError * _Nullable error))completionHandler;

-(void)resetAverageSessionDuration;
-(void)appTerminationFunctionalityOnDayChange;

-(void)recordAppInformation:(nullable NSNotification*)notification;

-(void)averageAppSessionDurationForTheDay;
-(void)registerForNotifications;
-(void)storeGeoLocation:(NSDictionary *)currentLocation;



@end

NS_ASSUME_NONNULL_END
