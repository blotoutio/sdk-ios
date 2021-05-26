//
//  BOCommonEventsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 21/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOCommonEvents.h"
#import "BOAppSessionData.h"

@interface BOCommonEventsTests : XCTestCase
@property (nonatomic) BOCommonEvents *boCommonEvents;
@end

@implementation BOCommonEventsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boCommonEvents = [BOCommonEvents sharedInstance];
    [[self.boCommonEvents superclass] setIsSessionModelInitialised:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRecordFunnelReceiveAndTrigger {
    //TODO: Need to discuss with ankur for void type of methods
    [self.boCommonEvents recordFunnelReceived];
    NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.commonEvents mutableCopy];
    XCTAssertNotNil(existingData);
    
    [self.boCommonEvents recordFunnelTriggered];
    existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.commonEvents mutableCopy];
    XCTAssertNotNil(existingData);
}

- (void)testRecordSegmentReceiveAndTrigger {
    //TODO: Need to discuss with ankur for void type of methods
    [self.boCommonEvents recordSegmentReceived];
    NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.commonEvents mutableCopy];
    XCTAssertNotNil(existingData);
    
    [self.boCommonEvents recordSegmentTriggered];
    existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.commonEvents mutableCopy];
    XCTAssertNotNil(existingData);
}



@end
