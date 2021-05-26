//
//  BOAJSONQueryEngineTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 11/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAJSONQueryEngine.h"

@interface BOAJSONQueryEngineTests : XCTestCase
@property(strong, nonatomic) NSDictionary *dict;
@end


@implementation BOAJSONQueryEngineTests

NSString *jsonStr = @"{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true}";

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.dict = @{
        @"10001":@[@"appBundle",@"date", @"singleDaySessions", @"sentToServer", @"systemUptime", @"lastServerSyncTimeStamp", @"allEventsSyncTimeStamp", @"appInfo", @"timeStamp", @"version", @"sdkVersion", @"name", @"bundle", @"language", @"launchTimeStamp", @"terminationTimeStamp", @"sessionsDuration", @"averageSessionsDuration", @"launchReason", @"currentLocation", @"city", @"state", @"country", @"zip", @"ubiAutoDetected", @"screenShotsTaken", @"currentView", @"appNavigation"],
        @"20001":@[@"click"],
    };
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAvailableValuesInDic {
    NSDictionary *categoryCodes = [BOAJSONQueryEngine predefinedKeysWithCategoryCode];
    XCTAssertNotNil(categoryCodes);
    NSArray *codes = [categoryCodes objectForKey:@"10001"];
    XCTAssertNotNil(codes);
    XCTAssertGreaterThan(codes.count, 0);
    
    BOOL status = [BOAJSONQueryEngine isKey:@"appBundle" belongsToPredefinedKeys:self.dict];
    XCTAssertTrue(status, @"Couldn't find key in dict");
    
    status = [BOAJSONQueryEngine isKey:@"10001" availableInDict:self.dict];
    XCTAssertTrue(status, @"Couldn't find key in dict");
    
    status = [BOAJSONQueryEngine isKey:@"unknown" availableInDict:self.dict];
    XCTAssertFalse(status, @"Couldn't find key in dict");
    
    status = [BOAJSONQueryEngine isValue:@"appBundle" availableInDict:self.dict];
    XCTAssertTrue(status, @"Couldn't find key in dict");
    
    status = [BOAJSONQueryEngine isKey:@"variableId" availableInJSON:jsonStr];
    XCTAssertTrue(status, @"Couldn't find key in json string");
    
    int count = [BOAJSONQueryEngine occuranceCountOfValue:@"appBundle" availableInDict:self.dict];
    XCTAssertEqual(count, 1);
    
    count = [BOAJSONQueryEngine occuranceCountOfValue:@"5006" availableInJSON:jsonStr];
    XCTAssertEqual(count, 1);
    
    NSDictionary *dict = [BOAJSONQueryEngine dictContainsKey:@"20001" fromRootDict:self.dict];
    XCTAssertNotNil(dict);
    
    dict = [BOAJSONQueryEngine dictContainsKey:@"unknown" fromRootDict:self.dict];
    XCTAssertNil(dict);
    
    id result = [BOAJSONQueryEngine valueForKey:@"10001" inNestedDict:self.dict];
    XCTAssertNotNil(result);
    
    result = [BOAJSONQueryEngine valueForKey:@"unknown" inNestedDict:self.dict];
    XCTAssertNil(result);
    
    result = [BOAJSONQueryEngine objectFromNestedJSON:jsonStr usingCascadedKeys:self.dict];
    XCTAssertNil(result);
    
    result = [BOAJSONQueryEngine dictContainsValue:@"appBundle" fromRootDict:self.dict];
    XCTAssertNotNil(result);
    
    NSString *key = [BOAJSONQueryEngine keyForValue:@"appBundle" inNestedDict:self.dict];
    XCTAssertNotNil(key);
    XCTAssertEqual(key, @"10001");
    
    result = [BOAJSONQueryEngine allDictContainsValue:@"appBundle" fromRootDict:self.dict];
    XCTAssertNotNil(result);
    
    result = [BOAJSONQueryEngine allKeysForValue:@"appBundle" inNestedDict:self.dict];
    XCTAssertNotNil(result);
}

- (void)testKeyPath {
    NSArray *result = [BOAJSONQueryEngine getAllKeyPathForKey:@"10001" inNestedDict:self.dict];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.count, 1);
    
    NSString *keyPath = [BOAJSONQueryEngine getKeyPathForKey:@"10001" inNestedDict:self.dict];
    XCTAssertNotNil(keyPath);
    
    NSArray *keyPathArr = [BOAJSONQueryEngine getAllKeyPathForKey:@"10001" inNestedDict:self.dict];
    XCTAssertNotNil(keyPathArr);
    XCTAssertEqual(keyPathArr.count, 1);
    
    NSArray *allValues = [BOAJSONQueryEngine allValueForKey:@"10001" inNestedDict:self.dict];
    XCTAssertNotNil(allValues);
    XCTAssertEqual(allValues.count, 1);
    
    allValues = [BOAJSONQueryEngine allValueForKey:@"unknown" inNestedDict:self.dict];
    XCTAssertNotNil(allValues);
    XCTAssertEqual(allValues.count, 0);
    
    allValues = [BOAJSONQueryEngine allDictContainsKey:@"10001" fromRootDict:self.dict];
    XCTAssertNotNil(allValues);
    XCTAssertEqual(allValues.count, 1);
    
    allValues = [BOAJSONQueryEngine allDictContainsKey:@"unknown" fromRootDict:self.dict];
    XCTAssertNotNil(allValues);
    XCTAssertEqual(allValues.count, 0);
    
    int occuranceCount = [BOAJSONQueryEngine occuranceCountOf:@"10001" availableInDict:self.dict];
    XCTAssertEqual(occuranceCount, 1);
    
    occuranceCount = [BOAJSONQueryEngine occuranceCountOf:@"unknown" availableInDict:self.dict];
    XCTAssertEqual(occuranceCount, 0);
    
    occuranceCount = [BOAJSONQueryEngine occuranceCountOf:@"variableId" availableInJSON:jsonStr];
    XCTAssertEqual(occuranceCount, 1);
    
    occuranceCount = [BOAJSONQueryEngine occuranceCountOf:@"unknown" availableInJSON:jsonStr];
    XCTAssertEqual(occuranceCount, 0);
    
    NSArray *parentKey = [BOAJSONQueryEngine getAllParentKeyForKey:@"click" inNestedDict:self.dict];
    XCTAssertNotNil(parentKey);
    XCTAssertEqual(parentKey.count, 0);
    
    NSString *key = [BOAJSONQueryEngine getParentKeyForKey:@"10001" inNestedDict:self.dict];
    XCTAssertNil(key);
    
}

@end
