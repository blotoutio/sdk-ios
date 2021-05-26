//
//  BOAAppSessionEventsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 21/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAAppSessionEvents.h"
#import "BOAppSessionData.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAConstants.h"

@interface BOAAppSessionEventsTests : XCTestCase
@property (nonatomic) BOAAppSessionEvents *boaAppSessionEvents;
@end

@implementation BOAAppSessionEventsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boaAppSessionEvents = [BOAAppSessionEvents sharedInstance];
    [self.boaAppSessionEvents  setIsEnabled:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEventRecording {
    [self.boaAppSessionEvents startRecordingEvnets];
    XCTAssertTrue(self.boaAppSessionEvents.isEnabled);
    
    [self.boaAppSessionEvents stopRecordingEvnets];
    XCTAssertFalse(self.boaAppSessionEvents.isEnabled);
    
    [self.boaAppSessionEvents averageAppSessionDurationForTheDay];
    NSNumber *num = [self.boaAppSessionEvents.sessionAppInfo objectForKey:@"averageSessionsDuration"];
    XCTAssertNotNil(num);
    XCTAssertGreaterThan([num integerValue], 0);
    
    [self.boaAppSessionEvents resetAverageSessionDuration];
}

- (void)testRecordSessionOnDayChangeOrAppTermination {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Record Session On Day Change Or App Termination"];
    [self.boaAppSessionEvents recordSessionOnDayChangeOrAppTermination:^(BOOL isSuccess, NSError * _Nullable error) {
        if(isSuccess){
            [completionExpectation fulfill];
        } else {
            XCTFail();
        }
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRecordLifeTimeOnDayChangeOrAppTermination {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Record Life Time On Day Change Or App Termination"];
    [self.boaAppSessionEvents recordLifeTimeOnDayChangeOrAppTermination:^(BOOL isSuccess, NSError * _Nullable error) {
        if(isSuccess){
            [completionExpectation fulfill];
        } else {
            XCTFail();
        }
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRegisterForNotifications {
    //TODO: ask ankur for void methods check
    [self.boaAppSessionEvents registerForNotifications];
    NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.appStates.appInBackground mutableCopy];
    XCTAssertNil(existingData);
}

- (void)testStoreGeoLocation {
    NSArray *values = [NSArray arrayWithObjects:@"12.43423433", @"24.4564543", @"+91", @"india", @"MP", @"indore", @"452001", nil];
    NSArray *keys = [NSArray arrayWithObjects:@"latitude", @"longitude", @"continentCode",@"country", @"state", @"city", @"zip", nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects: values forKeys: keys];
    [self.boaAppSessionEvents storeGeoLocation:dict];
    
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    NSString *locationStr = [analyticsRootUD objectForKey:BO_ANALYTICS_CURRENT_LOCATION_DICT];
    XCTAssertNotNil(locationStr);
    
    [self.boaAppSessionEvents postInitLaunchEventsRecording];
}



/*
 - (void)testGetGeoIPAndPublishWith {
 //TODO: ask ankur for void methods check
 XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Record Life Time On Day Change Or App Termination"];
 [self.boaAppSessionEvents getGeoIPAndPublishWith:^(NSDictionary * _Nonnull currentLocation, NSError * _Nullable error) {
 if(currentLocation != nil) {
 [completionExpectation fulfill];
 } else {
 XCTFail();
 }
 }];
 [self waitForExpectationsWithTimeout:5.0 handler:nil];
 }
 */


@end

/*
 -(void)recordNotificationsInBackgroundWith:(NSDictionary*)notificationData{
 -(void)recordSystemUptime:(nullable NSNumber*)time{
 -(void)decideAndRecordLaunchReason:(nullable NSNotification*)notification{
 -(void)recordAppInformation:(nullable NSNotification*)notification{
 -(void)postInitLaunchEventsRecording{
 
 */
