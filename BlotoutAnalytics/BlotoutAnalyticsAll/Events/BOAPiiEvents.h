//
//  BOAPiiEvents.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAEvents.h"
#import <CoreLocation/CoreLocation.h>


NS_ASSUME_NONNULL_BEGIN

@interface BOAPiiEvents : BOAEvents

@property (nonatomic, readwrite) BOOL isEnabled;

-(void)startCollectingUserLocationEvent;
-(void)stopCollectingUserLocationEvent;

- (instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (instancetype)sharedInstance;

-(BOOL)isSystemRequirementForLocationFullfilled;
-(BOOL)isSystemRequirementForMotionFullfilled;
-(BOOL)isSystemRequirementForPhotosFullfilled;
-(NSString*)getActivityTypeFromLocation:(CLLocation*)location;
-(void)recordUserLocationEventFrom:(CLLocation*)location;

@end

NS_ASSUME_NONNULL_END


