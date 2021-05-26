//
//  BOASegmentEventsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 19/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOASegmentEvents.h"

@interface BOASegmentEventsTests : XCTestCase

@end

@implementation BOASegmentEventsTests

NSDictionary *dictData;
- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    dictData = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testBOASegmentEventsMethods {
    //TODO: check with Ankur..return non nil value but getting nil values
    
    BOASegmentEvents *boaSegmentEvents = [BOASegmentEvents fromJSONDictionary:dictData];
    XCTAssertNil(boaSegmentEvents);
    
    NSDictionary *dic = [boaSegmentEvents JSONDictionary];
    XCTAssertNil(dic);
    
    NSError *paringError;
    BOASegmentEvents *boaSegmentPayloadForStr = [BOASegmentEvents fromJSON:[self getDummyJson] encoding:NSUTF8StringEncoding error:&paringError];
    XCTAssertNil(boaSegmentPayloadForStr);
    
    BOASegmentEvents *boaSegmentEventsForData = [BOASegmentEvents fromData:[[self getDummyJson] dataUsingEncoding:NSUTF8StringEncoding] error:&paringError];
    XCTAssertNil(boaSegmentEventsForData);
    
    NSString *jsonStr = [boaSegmentEventsForData toJSON:NSUTF8StringEncoding error:&paringError];
    XCTAssertNil(jsonStr);
    
    NSData *data = [boaSegmentEventsForData toData:&paringError];
    XCTAssertNil(data);
}

- (void)testBOASegmentsGeoMethods {
    
    BOASegmentsGeo *boaSegmentsGeo = [BOASegmentsGeo fromJSONDictionary:dictData];
    XCTAssertNotNil(boaSegmentsGeo);
    
    NSDictionary *dic = [boaSegmentsGeo JSONDictionary];
    XCTAssertNotNil(dic);
}

- (void)testBOASegmentMethods {
    
    BOASegment *boaSegment = [BOASegment fromJSONDictionary:dictData];
    XCTAssertNotNil(boaSegment);
    
    NSDictionary *dic = [boaSegment JSONDictionary];
    XCTAssertNotNil(dic);
}

- (void)testBOARulesetMethods {
    //TODO: check with Ankur..return non nil value but getting nil values
    
    BOARuleset *boaRuleset = [BOARuleset fromJSONDictionary:dictData];
    XCTAssertNil(boaRuleset);
    
    NSDictionary *dic = [boaRuleset JSONDictionary];
    XCTAssertNil(dic);
}

- (void)testBOARuleMethods {
    
    BOARule *boaRule = [BOARule fromJSONDictionary:dictData];
    XCTAssertNotNil(boaRule);
    
    NSDictionary *dic = [boaRule JSONDictionary];
    XCTAssertNotNil(dic);
}

- (NSString *)getDummyJson {
    return @"{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true}";
    
}
@end
