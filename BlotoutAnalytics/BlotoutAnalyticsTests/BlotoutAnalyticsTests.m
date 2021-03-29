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

@end

