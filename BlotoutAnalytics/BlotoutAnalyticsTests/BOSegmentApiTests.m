//
//  BOSegmentApiTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 15/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOSegmentAPI.h"
#import "BOASegmentsSyncController.h"
#import "BlotoutAnalytics.h"

@interface BOSegmentApiTests : XCTestCase
@property (nonatomic) BlotoutAnalytics *blotoutAnalytics;
@end

@implementation BOSegmentApiTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.blotoutAnalytics = [BlotoutAnalytics sharedInstance];
    [self initSDK];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)initSDK {
    [self.blotoutAnalytics setIsEnabled:YES];
    [self.blotoutAnalytics initializeAnalyticsEngineUsingKey:@"B6PSYZ355NS383V" url:@"https://stage.blotout.io" andCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
    }];
}

- (void)testGetSegmentDataModel {
    BOSegmentAPI *segmentAPI = [[BOSegmentAPI alloc] init];
    BOASegmentsSyncController *segmentsSyncController = [BOASegmentsSyncController sharedInstanceSegmentSyncController];
    NSData *dataPayload = [segmentsSyncController getSegmentPayload];
    [segmentAPI getSegmentDataModel:dataPayload success:^(id  _Nonnull responseObject) {
        XCTAssertNotNil(responseObject);
    } failure:^(NSError * _Nonnull error) {
        XCTFail();
    }];
}

- (void)testPostSegmentDataModel {
    BOSegmentAPI *segmentAPI = [[BOSegmentAPI alloc] init];
    BOASegmentsSyncController *segmentsSyncController = [BOASegmentsSyncController sharedInstanceSegmentSyncController];
    NSData *dataPayload = [segmentsSyncController getSegmentPayload];
    [segmentAPI postSegmentDataModel:dataPayload success:^(id  _Nonnull responseObject) {
        XCTAssertNotNil(responseObject);
    } failure:^(NSError * _Nonnull error) {
        XCTFail();
    }];
}


@end
