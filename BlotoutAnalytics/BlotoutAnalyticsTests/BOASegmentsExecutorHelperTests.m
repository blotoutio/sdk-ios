//
//  BOASegmentsExecutorHelperTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 15/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOASegmentsExecutorHelper.h"

@interface BOASegmentsExecutorHelperTests : XCTestCase
@property (nonatomic) BOASegmentsExecutorHelper *boaSegmentsExecutorHelper;
@property(nonatomic) NSDictionary *predefinedKeys;
@end

@implementation BOASegmentsExecutorHelperTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boaSegmentsExecutorHelper = [BOASegmentsExecutorHelper sharedInstanceSegmentExeHelper];
    NSDictionary *innerDict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    self.predefinedKeys = @{
        @"10001":@[@"appBundle",@"date", @"singleDaySessions", @"sentToServer", @"systemUptime", @"lastServerSyncTimeStamp", @"allEventsSyncTimeStamp", @"appInfo", @"timeStamp", @"version", @"sdkVersion", @"name", @"bundle", @"language", @"launchTimeStamp", @"terminationTimeStamp", @"sessionsDuration", @"averageSessionsDuration", @"launchReason", @"currentLocation", @"city", @"state", @"country", @"zip", @"ubiAutoDetected", @"screenShotsTaken", @"currentView", @"appNavigation"],
        @"20001":@[@"click"],
        @"30001":innerDict,
    };
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testResetSettings {
    [self.boaSegmentsExecutorHelper resetSettings];
}

- (void)testKeyAndValueMethods {
    BOOL status = [self.boaSegmentsExecutorHelper isKey:@"10001" foundIn:self.predefinedKeys];
    XCTAssertTrue(status);
    
    status = [self.boaSegmentsExecutorHelper isKey:@"appBundle" foundIn:self.predefinedKeys];
    XCTAssertTrue(status);
    
    status = [self.boaSegmentsExecutorHelper doesKey:@"20001" conatainsValues:[NSArray arrayWithObjects:@"click", nil] byOperator:[NSNumber numberWithInt:805] inDict:self.predefinedKeys];
    XCTAssertFalse(status);
    
    status = [self.boaSegmentsExecutorHelper doesKey:@"20001" conatainsValues:[NSArray arrayWithObjects:@"click", nil] byOperator:[NSNumber numberWithInt:805] inDict:self.predefinedKeys forEventName:@"click"];
    XCTAssertFalse(status);
    
    status = [self.boaSegmentsExecutorHelper conditionalResultForCondition:@"AND" onvalue1:@"Blotout" andValue2:@"SDK"];
    XCTAssertTrue(status);
    
    status = [self.boaSegmentsExecutorHelper resultsOfBitwiseOperator:@"AND" onResult1:YES andResult2:YES];
    XCTAssertTrue(status);
}


@end
