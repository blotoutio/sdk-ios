//
//  BOEventsOperationExecutorTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 23/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

@import XCTest;
@import BlotoutAnalyticsSDK;

@interface BOEventsOperationExecutorTests : XCTestCase
@property (nonatomic) BOEventsOperationExecutor *boEventsOperationExecutor;
@end

@implementation BOEventsOperationExecutorTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boEventsOperationExecutor = [BOEventsOperationExecutor sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDispatchEvents {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"dispatchEventsInBackground"];
    [self.boEventsOperationExecutor dispatchEventsInBackground:^{
        [completionExpectation fulfill];
    }];
    
    completionExpectation = [self expectationWithDescription:@"dispatchDeviceOperationInBackground"];
    [self.boEventsOperationExecutor dispatchDeviceOperationInBackground:^{
        [completionExpectation fulfill];
    }];
    
    completionExpectation = [self expectationWithDescription:@"dispatchInBackgroundAndWait"];
    [self.boEventsOperationExecutor dispatchInBackgroundAndWait:^{
        [completionExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    
}

@end

