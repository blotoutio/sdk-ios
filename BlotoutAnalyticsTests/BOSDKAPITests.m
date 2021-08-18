//
//  BOSDKAPITests.m
//  BlotoutAnalyticsTests
//
//  Created by ankuradhikari on 12/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

@import XCTest;
@import BlotoutAnalyticsSDK;


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

@end
