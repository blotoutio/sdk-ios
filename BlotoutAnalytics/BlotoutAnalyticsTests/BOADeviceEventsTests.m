//
//  BOADeviceEventsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 19/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOADeviceEvents.h"

@interface BOADeviceEventsTests : XCTestCase
@property (nonatomic) BOADeviceEvents *boaDeviceEvents;

@end

@implementation BOADeviceEventsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boaDeviceEvents = [BOADeviceEvents sharedInstance];
    self.boaDeviceEvents.isEnabled = YES;
    [[self.boaDeviceEvents superclass] setIsSessionModelInitialised:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEventRecodringForAllTypes {
    //TODO: Need to discuss with ankur for void return type methods
    [self.boaDeviceEvents recordDeviceEvents];
    [self.boaDeviceEvents recordNetworkEvents];
    [self.boaDeviceEvents recordStorageEvents];
    [self.boaDeviceEvents recordMemoryEvents];
    [self.boaDeviceEvents recordAdInformation];
}

@end
