//
//  BOASegmentsSyncControllerTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 15/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOASegmentsSyncController.h"
#import "BONetworkManager.h"

@interface BOASegmentsSyncControllerTests : XCTestCase
@property (nonatomic) BOASegmentsSyncController *boaSegmentsSyncController;

@end

@implementation BOASegmentsSyncControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boaSegmentsSyncController = [BOASegmentsSyncController sharedInstanceSegmentSyncController];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPrepareSegmentsSyncAndAnalyser {
    [self.boaSegmentsSyncController prepareSegmentsSyncAndAnalyser];
}

- (void)testPauseSegmentsSyncAndAnalyser {
    [self.boaSegmentsSyncController pauseSegmentsSyncAndAnalyser];
}

- (void)testIsSegmentAvailable {
    BOOL status = [self.boaSegmentsSyncController isSegmentAvailable];
    XCTAssertFalse(status);
}

- (void)testAppStateInfo {
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"appState" forKey:@"info"];
    [self.boaSegmentsSyncController appLaunchedWithInfo: dic];
    [self.boaSegmentsSyncController appInBackgroundWithInfo: dic];
    [self.boaSegmentsSyncController appWillTerminatWithInfo: dic];
}


@end
