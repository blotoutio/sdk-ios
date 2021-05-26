//
//  BlotoutAnalyticsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Blotout on 16/06/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BlotoutAnalytics.h"

@interface BlotoutAnalyticsTests : XCTestCase
@property (nonatomic) BlotoutAnalytics *blotoutAnalytics;
@end

@implementation BlotoutAnalyticsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.blotoutAnalytics = [BlotoutAnalytics sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testIsDeviceCompromised {
    XCTAssertTrue([self.blotoutAnalytics isDeviceCompromised]);
}

- (void)testIsSimulator {
    XCTAssertTrue([self.blotoutAnalytics isSimulator]);
}

- (void)testIsRunningOnVM {
    XCTAssertTrue([self.blotoutAnalytics isRunningOnVM]);
}

- (void)testSetPayingUser {
    [self.blotoutAnalytics setPayingUser:true];
    XCTAssertTrue([self.blotoutAnalytics isPayingUser]);
}


- (void)testIsAppCompromised {
    XCTAssertTrue(![self.blotoutAnalytics isAppCompromised]);
}

- (void)testIsNetworkProxied {
    XCTAssertTrue(![self.blotoutAnalytics isNetworkProxied]);
}

- (void)testisEnvironmentSecure {
    XCTAssertTrue(![self.blotoutAnalytics isEnvironmentSecure]);
}

-(void)testInitSDKWithoutKeys {
    // Create an expectation object.
    // This test only has one, but it's possible to wait on multiple expectations.
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"sdk init"];
    [self.blotoutAnalytics setIsEnabled:YES];
    [self.blotoutAnalytics initializeAnalyticsEngineUsingKey:@"" url:@"http://dev.blotout.io" andCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        if(isSuccess) {
            XCTFail();
        } else {
            [completionExpectation fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


@end

