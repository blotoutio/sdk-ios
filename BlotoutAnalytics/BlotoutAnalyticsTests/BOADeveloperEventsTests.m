//
//  BOADeveloperEventsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 21/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOADeveloperEvents.h"
#import "BOAppSessionData.h"

@interface BOADeveloperEventsTests : XCTestCase
@property (nonatomic) BOADeveloperEvents *boaDeveloperEvents;
@end

@implementation BOADeveloperEventsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boaDeveloperEvents = [BOADeveloperEvents sharedInstance];
    [[self.boaDeveloperEvents superclass] setIsSessionModelInitialised:YES];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testTimedEvent {
    NSDictionary *eventInfo = [NSDictionary dictionaryWithObject:@"timedEvent" forKey:@"eventName"];
    [self.boaDeveloperEvents startTimedEvent:@"event" withInformation:eventInfo];
    
    NSMutableDictionary *dict = [self.boaDeveloperEvents.devEventUD objectForKey:@"event"];
    XCTAssertNotNil(dict);
    NSString *eventName = [dict valueForKey:@"eventName"];
    XCTAssertEqual(eventName, @"timedEvent");
    
    [self.boaDeveloperEvents endTimedEvent:@"event" withInformation:eventInfo];
    dict = [self.boaDeveloperEvents.devEventUD objectForKey:@"event"];
    XCTAssertNil(dict);
    
}

- (void)testLogEvent {
    //    TODO: Need to discuss with Ankur for Not nil condition
    NSDictionary *eventInfo = [NSDictionary dictionaryWithObject:@"timedEvent" forKey:@"eventName"];
    [self.boaDeveloperEvents logEvent:@"DashboardVisit" withInformation:eventInfo];
    NSMutableArray *customEvent = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified.customEvents mutableCopy];
    XCTAssertNil(customEvent);
    
    [self.boaDeveloperEvents logPIIEvent:@"DashboardVisit" withInformation:eventInfo happendAt:[NSDate date]];
    customEvent = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified.piiEvents mutableCopy];
    XCTAssertNil(customEvent);
    
    [self.boaDeveloperEvents logPHIEvent:@"DashboardVisit" withInformation:eventInfo happendAt:[NSDate date]];
    customEvent = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.developerCodified.phiEvents mutableCopy];
    XCTAssertNil(customEvent);
}

@end

