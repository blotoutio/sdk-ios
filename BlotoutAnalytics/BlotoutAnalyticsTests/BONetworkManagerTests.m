//
//  BONetworkManagerTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 15/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

@import XCTest;
#import "BONetworkManager.h"

@interface BONetworkManagerTests : XCTestCase

@end

@implementation BONetworkManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAsyncRequestSuccess {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"async request"];
    
    [BONetworkManager asyncRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://jsonplaceholder.typicode.com/todos/1"]] success:^(id data , NSURLResponse *dataResponse) {
        if (data) {
            [completionExpectation fulfill];
        } else {
            XCTFail();
        }
        
    } failure:^(id data, NSURLResponse *dataResponse, NSError *error) {
        XCTFail();
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testAsyncRequestFailure {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"async request"];
    
    [BONetworkManager asyncRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://jsonplaceholdertest.typicode.com/todos/1"]] success:^(id data , NSURLResponse *dataResponse) {
        if (data) {
            XCTFail();
            
        } else {
            [completionExpectation fulfill];
        }
        
    } failure:^(id data, NSURLResponse *dataResponse, NSError *error) {
        [completionExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
