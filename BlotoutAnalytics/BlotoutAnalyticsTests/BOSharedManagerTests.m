//
//  BOSharedManagerTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 23/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOSharedManager.h"

@interface BOSharedManagerTests : XCTestCase

@end

@implementation BOSharedManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSharedInstance {
    BOSharedManager *boaAppSessionEvents = [BOSharedManager sharedInstance];
    XCTAssertNotNil(boaAppSessionEvents);
}


@end
