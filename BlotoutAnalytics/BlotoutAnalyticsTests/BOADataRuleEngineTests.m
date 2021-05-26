//
//  BOADataRuleEngineTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 11/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOADataRuleEngine.h"

@interface BOADataRuleEngineTests : XCTestCase
@property(nonatomic) NSDictionary *dataDict;
@end

NSString *const k_Platform = @"platform";
NSString *const k_BuildType = @"buildType";
NSString *const k_BuildVersion = @"buildVersion";
NSString *const k_UnknownKey = @"unknown";
NSString *const k_UnknownValue = @"unknownValue";
NSString *const k_OSVersion = @"osVersion";

@implementation BOADataRuleEngineTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.dataDict = @{k_Platform: @"iOS", k_BuildType: @"dev", k_BuildVersion: @"1.0.0", k_OSVersion: @14.0};
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAvailableValuesInDic {
    BOOL status = [BOADataRuleEngine isKey:k_Platform availableIn:self.dataDict];
    XCTAssertTrue(status, @"Couldn't find key in dict");
    
    status = [BOADataRuleEngine isValue:@"iOS" availableIn:self.dataDict];
    XCTAssertTrue(status, @"Couldn't find value in dict");
    
    //    TODO: Need to check with Ankur
    //    status = [BOADataRuleEngine is:@"dev" availableIn:self.dataDict];
    //    XCTAssertTrue(status, @"Couldn't find value in dict");
    
}

- (void)testDictContains {
    BOOL status = [BOADataRuleEngine dictContainsKey:k_Platform fromRootDict:self.dataDict];
    XCTAssertTrue(status, @"Couldn't find key in dict");
    
    status = [BOADataRuleEngine dictContains:@"iOS" fromRootDict:self.dataDict];
    XCTAssertTrue(status, @"Couldn't find value in dict");
    
    NSArray *arr = [BOADataRuleEngine allDictContainsValue:@"iOS" fromRootDict:self.dataDict];
    XCTAssertNotNil(arr);
    XCTAssertGreaterThan(arr.count, 0);
}

- (void)testValueForKey {
    id value = [BOADataRuleEngine valueForKey:k_Platform inDict:self.dataDict];
    XCTAssertNotNil(value);
    XCTAssertEqual(value, @"iOS");
    
    value = [BOADataRuleEngine valueForKey:k_Platform inDict:self.dataDict whereItContains:@"OS"];
    XCTAssertNotNil(value);
    XCTAssertEqual(value, @"iOS");
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThan:11.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThanOrEqualTo:14.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsLessThan:14.0];
    XCTAssertNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsLessThanOrEqualTo:14.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsEqualTo:14.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsNotEqualTo:14.0];
    XCTAssertNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThan:10.0 ANDLessThan:15.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThanEqualTo:14.0 ANDLessThan:18.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThanEqualTo:14.0 ANDLessThan:18.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThan:12.0 ANDLessThanEqualTo:14.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThanEqualTo:12.0 ANDLessThanEqualTo:14.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThan:12.0 ORLessThan:16.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThanEqualTo:14.0 ORLessThan:16.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThan:12.0 ORLessThanEqualTo:14.0];
    XCTAssertNotNil(value);
    
    value = [BOADataRuleEngine valueForKey:k_OSVersion inDict:self.dataDict whereItIsGreaterThanEqualTo:12.0 ORLessThanEqualTo:14.0];
    XCTAssertNotNil(value);
    
}

@end
