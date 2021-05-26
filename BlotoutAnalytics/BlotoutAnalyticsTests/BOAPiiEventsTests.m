//
//  BOAPiiEventsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 19/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAPiiEvents.h"

@interface BOAPiiEventsTests : XCTestCase
@property (nonatomic) BOAPiiEvents *boaPiiEvents;
@end

@implementation BOAPiiEventsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boaPiiEvents = [BOAPiiEvents sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testTopViewController {
    //TODO: check with ankur for location related stuff
    BOOL status = [self.boaPiiEvents isSystemRequirementForLocationFullfilled];
    XCTAssertFalse(status);
    
    status = [self.boaPiiEvents isSystemRequirementForMotionFullfilled];
    XCTAssertFalse(status);
    
    status = [self.boaPiiEvents isSystemRequirementForPhotosFullfilled];
    XCTAssertFalse(status);
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:22.7196 longitude:75.8577];
    NSString *activityType = [self.boaPiiEvents getActivityTypeFromLocation: location];
    XCTAssertNotNil(activityType);
    XCTAssertEqual(activityType, @"static");
    
    [self.boaPiiEvents recordUserLocationEventFrom:location];
    
}

-(void)testStartCollectingUserLocationEvent {
    [self.boaPiiEvents startCollectingUserLocationEvent];
}

-(void)testStopCollectingUserLocationEvent {
    [self.boaPiiEvents stopCollectingUserLocationEvent];
}

-(void)testDealloc {
    self.boaPiiEvents = nil;
}

@end
