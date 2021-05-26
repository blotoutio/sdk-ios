//
//  BOARetentionEventsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 20/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOARetentionEvents.h"
#import "BOAppSessionData.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>


@interface BOARetentionEventsTests : XCTestCase
@property (nonatomic) BOARetentionEvents *boaRetentionEvents;
@end

@implementation BOARetentionEventsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boaRetentionEvents = [BOARetentionEvents sharedInstance];
    [[self.boaRetentionEvents superclass] setIsSessionModelInitialised:YES];
    
    [BOFFileSystemManager isFirstLaunchBOSDKFileSystemCheck];
    [[self.boaRetentionEvents superclass] setIsSessionModelInitialised:YES];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRecordWithPayload {
    //TODO: Need to discuss with ankur for void type methods
    NSDictionary *eventInfo = [NSDictionary dictionaryWithObject:@"screenVisit" forKey:@"eventName"];
    [self.boaRetentionEvents recordDAUwithPayload:eventInfo];
    BODau *dau = [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.dau;
    XCTAssertNotNil(dau);
    
    [self.boaRetentionEvents recordDPUwithPayload:nil];
    BODpu *dpu = [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.dpu;
    XCTAssertNotNil(dpu);
    
    [self.boaRetentionEvents recordAppInstalled:YES withPayload:eventInfo];
    BOAppInstalled *appInstalled = [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.appInstalled;
    XCTAssertNotNil(appInstalled);
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"testuser" forKey:@"userName"];
    [self.boaRetentionEvents recordNewUser:YES withPayload:userInfo];
    BONewUser *newUser = [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.theNewUser;
    XCTAssertNotNil(newUser);
    
    BOAppSessionData *apSessionData = [BOAppSessionData sharedInstanceFromJSONDictionary: eventInfo];
    [self.boaRetentionEvents storeDASTupdatedSessionFile:apSessionData];
    
    [self.boaRetentionEvents recordCustomEventsWithName:@"testEvent" andPaylod:eventInfo];
    NSMutableArray *customEvents = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.retentionEvent.customEvents mutableCopy];
    XCTAssertNotNil(customEvents);
    
    NSDictionary *sessionDict = [NSDictionary dictionaryWithObject:@"zasdsffsdsfs" forKey:@"sessionId"];
    [self.boaRetentionEvents recordDAST:[NSNumber numberWithInt:10] forSession:sessionDict withPayload:eventInfo];
    apSessionData = [BOAppSessionData fromJSONDictionary:sessionDict];
    BODast *dast = apSessionData.singleDaySessions.retentionEvent.dast;
    XCTAssertNil(dast);
    
}
@end
