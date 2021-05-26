//
//  BOAPiiEvents.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAPiiEvents.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <Photos/Photos.h>
#import <CoreMotion/CoreMotion.h>

#import "BOAppSessionData.h"
#import "BOAAppLifetimeData.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
#import "BOSharedManager.h"

static id sBOAPiiEvnetsSharedInstance = nil;

@interface BOAPiiEvents () <CLLocationManagerDelegate>
{
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *previousLocation;
@end

@implementation BOAPiiEvents

-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaPiiEventsOnceToken = 0;
    dispatch_once(&boaPiiEventsOnceToken, ^{
        sBOAPiiEvnetsSharedInstance = [[[self class] alloc] init];
    });
    return  sBOAPiiEvnetsSharedInstance;
}

-(BOOL)isSystemRequirementForLocationFullfilled{
    @try {
        BOOL isFullFilled = NO;
        NSString *alwaysAndWhenInUseOnLocationKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"];
        NSString *alwaysOnLocationKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"];
        NSString *inUseOnLocationKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"];
        NSString *oldLocationKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationUsageDescription"];
        
        if ((NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) && oldLocationKey) {
            isFullFilled = YES;
        }
        if ((NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) && (alwaysOnLocationKey || inUseOnLocationKey || alwaysAndWhenInUseOnLocationKey)) {
            isFullFilled = YES;
        }
        if (isFullFilled && [CLLocationManager locationServicesEnabled]) {
            CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
            if(authStatus == kCLAuthorizationStatusDenied || authStatus == kCLAuthorizationStatusRestricted || authStatus == kCLAuthorizationStatusNotDetermined){
                isFullFilled = NO;
            }
        }
        return isFullFilled;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}
-(BOOL)isSystemRequirementForMotionFullfilled{
    @try {
        NSString *motionUsageKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSMotionUsageDescription"];
        if (motionUsageKey) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(BOOL)isSystemRequirementForPhotosFullfilled{
    @try {
        NSString *photoUsageKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        if (photoUsageKey && [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(NSString*)getActivityTypeFromLocation:(CLLocation*)location{
    @try {
        if (location.speed > 10.0) {
            return @"driving";
        }else if ((location.speed > 2.0) && (location.speed < 10.0)){
            return @"running";
        }else if ((location.speed > 0.1) && (location.speed < 2.0)){
            return @"walking";
        }
        return @"static";
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return @"static";
}

-(void)recordUserLocationEventFrom:(CLLocation*)location{
    @try {
        CLLocationCoordinate2D coordinate = [location coordinate];
        if (BOAEvents.isSessionModelInitialised) {
            
            BOPiiLocation *piiLocation = [BOPiiLocation fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent:@"PIILocation"],
                @"latitude":[NSString stringWithFormat:@"%f", coordinate.latitude],
                @"longitude":[NSString stringWithFormat:@"%f", coordinate.longitude],
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }];
            
            CLGeocoder *reverseGeoCoder = [[CLGeocoder alloc] init];
            [reverseGeoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                BONonPIILocation *nonPIILocation = nil;
                if (!error && (placemarks.count > 0)) {
                    CLPlacemark *placeMark = [placemarks objectAtIndex:0];
                    
                    nonPIILocation = [BONonPIILocation fromJSONDictionary:@{
                        @"sentToServer":[NSNumber numberWithBool:NO],
                        @"mid": [BOAUtilities getMessageIDForEvent:@"NonPIILocation"],
                        @"city": placeMark.locality,
                        @"state":placeMark.administrativeArea,
                        @"zip":placeMark.postalCode,
                        @"country": placeMark.country,
                        @"activity": [self getActivityTypeFromLocation:location],
                        @"source":@"geo",
                        @"session_id":[BOSharedManager sharedInstance].sessionId
                    }];
                }
                BOLocation *location = [BOLocation fromJSONDictionary:@{
                    @"sentToServer": [NSNumber numberWithBool:NO],
                    @"mid": [BOAUtilities getMessageIDForEvent:@"PiiNonPiiLocation"],
                    @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                    @"piiLocation": piiLocation,
                    @"nonPIILocation": nonPIILocation,
                    @"session_id":[BOSharedManager sharedInstance].sessionId
                }
                                        ];
                NSMutableArray *existingLocation = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.location mutableCopy];
                [existingLocation addObject:location];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setLocation:existingLocation];
            }];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)startCollectingUserLocationEvent{
    @try {
        if (self.isEnabled && [self isSystemRequirementForLocationFullfilled]) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.desiredAccuracy =  kCLLocationAccuracyBest;
            [self.locationManager startMonitoringVisits];
            [self.locationManager startMonitoringSignificantLocationChanges];
            CLLocation *location = [self.locationManager location];
            if (location) {
                [self  recordUserLocationEventFrom:location];
            }else{
                self.locationManager.delegate =  self;
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    @try {
        if (locations.count > 0) {
            CLLocation *currentLocation = [locations lastObject];
            CLLocationDistance distance = [self.previousLocation distanceFromLocation:currentLocation]; // distance is in meters
            NSString *activity = [self getActivityTypeFromLocation:currentLocation];
            if ((distance > 500.0) && [activity isEqualToString:@"static"]) {
                self.previousLocation = currentLocation;
                [self  recordUserLocationEventFrom:currentLocation];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)stopCollectingUserLocationEvent{
    @try {
        [self.locationManager stopMonitoringVisits];
        [self.locationManager stopMonitoringSignificantLocationChanges];
        self.locationManager.delegate =  nil;
        self.locationManager = nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)dealloc{
    @try {
        [self.locationManager stopMonitoringVisits];
        [self.locationManager stopMonitoringSignificantLocationChanges];
        self.locationManager.delegate =  nil;
        self.locationManager = nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}
@end
