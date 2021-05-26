//
//  BOSDKAPITests.m
//  BlotoutAnalyticsTests
//
//  Created by ankuradhikari on 12/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAUtilities.h"
#import "BlotoutAnalytics_Internal.h"
#import "BOBaseAPI.h"
#import "BOANetworkConstants.h"


@interface BOSDKAPITests : XCTestCase
@property(nonatomic,strong) BOBaseAPI *baseApi;
@end

@implementation BOSDKAPITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.baseApi = [[BOBaseAPI alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testSDKStagingEndPoint {
    [BlotoutAnalytics sharedInstance].isProductionMode = NO;
    NSString *endPoint = [self.baseApi getBaseServerUrl];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"https://stage-sdk.blotout.io/sdk"]);
}

-(void)testSDKProductionEndPoint {
    [BlotoutAnalytics sharedInstance].isProductionMode = YES;
    NSString *endPoint = [self.baseApi getBaseServerUrl];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"https://sdk.blotout.io/sdk"]);
}

-(void)testSDKEventPostEndPoint {
    [BlotoutAnalytics sharedInstance].isProductionMode = YES;
    NSString *endPoint = [self.baseApi resolveAPIEndPoint:BOUrlEndPointEventDataPOST];
    XCTAssertTrue([endPoint isEqualToString:@"https://sdk.blotout.io/sdk/v1/events/publish"]);
}

-(void)testSDKRetentionEventPostEndPoint {
    [BlotoutAnalytics sharedInstance].isProductionMode = YES;
    NSString *endPoint = [self.baseApi resolveAPIEndPoint:BOUrlEndPointRetentionEventDataPOST];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"https://sdk.blotout.io/sdk/v1/events/retention/publish"]);
}

-(void)testSDKGeoAPIEndPoint {
    [BlotoutAnalytics sharedInstance].isProductionMode = YES;
    NSString *endPoint = [self.baseApi resolveAPIEndPoint:BOUrlEndPointGeoDataGET];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"https://sdk.blotout.io/sdk/v1/geo/city"]);
}

-(void)testSDKFetchSegmentEndPoint {
    [BlotoutAnalytics sharedInstance].isProductionMode = YES;
    NSString *endPoint = [self.baseApi resolveAPIEndPoint:BOUrlEndPointSegmentEventDataGET];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"https://sdk.blotout.io/sdk/v1/segment/pull" ]);
}

-(void)testSDKPostSegmentAPIEndPoint {
    [BlotoutAnalytics sharedInstance].isProductionMode = YES;
    NSString *endPoint = [self.baseApi resolveAPIEndPoint:BOUrlEndPointSegmentEventDataPOST];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"https://sdk.blotout.io/sdk/v1/segment/custom/feedback"]);
}

-(void)testSDKFetchFunnelEndPoint {
    [BlotoutAnalytics sharedInstance].isProductionMode = YES;
    NSString *endPoint = [self.baseApi resolveAPIEndPoint:BOUrlEndPointFunnelEventDataGET];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"https://sdk.blotout.io/sdk/v1/funnel/pull"]);
}

-(void)testSDKPostFunnelAPIEndPoint {
    [BlotoutAnalytics sharedInstance].isProductionMode = YES;
    NSString *endPoint = [self.baseApi resolveAPIEndPoint:BOUrlEndPointFunnelEventDataPOST];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"https://sdk.blotout.io/sdk/v1/funnel/feedback"]);
}

-(void)testBaseUrl {
    
    NSString *endPoint = [self.baseApi validateAndReturnServerEndPoint:@"http://api.blotout.io"];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"http://api.blotout.io/sdk"]);
}

-(void)testBaseUrlWithSlash {
    
    NSString *endPoint = [self.baseApi validateAndReturnServerEndPoint:@"http://api.blotout.io/"];
    XCTAssertNotNil(endPoint);
    XCTAssertTrue([endPoint isEqualToString:@"http://api.blotout.io/sdk"]);
}

-(void)testGetJsonData {
    NSString *jsonStr = @"{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true}";
    NSData* jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [self.baseApi getJsonData:jsonData];
    XCTAssertNotNil(json);
    XCTAssertNotNil([json valueForKey:@"variableId"]);
}

-(void)testCheckForNullValue{
    NSString *jsonStr = @"{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":null,\"isEditable\":true}";
    NSData* data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    data = [self.baseApi checkForNullValue:data];
    XCTAssertNotNil(data);
}
/*
 -(void)testPrepareRequestHeaders {
 [[BlotoutAnalytics sharedInstance] setIsEnabled:YES];
 [[BlotoutAnalytics sharedInstance] initializeAnalyticsEngineUsingKey:@"" url:@"http://dev.blotout.io" andCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
 NSDictionary *reqHeaders = [self.baseApi prepareRequestHeaders];
 XCTAssertEqual([reqHeaders valueForKey:BO_ACCEPT], @"application/json");
 }];
 }
 */

@end
