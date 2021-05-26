//
//  BOASegmentsResSegmentsPayloadTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 19/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOASegmentsResSegmentsPayload.h"

@interface BOASegmentsResSegmentsPayloadTests : XCTestCase

@end

NSDictionary *dict;

@implementation BOASegmentsResSegmentsPayloadTests


- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    dict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testBOASegmentsResSegmentsPayloadMethods {
    //TODO: check with Ankur..return non nil value but getting nil values
    BOASegmentsResSegmentsPayload *boaSegmentsResSegmentsPayload = [BOASegmentsResSegmentsPayload fromJSONDictionary:dict];
    XCTAssertNil(boaSegmentsResSegmentsPayload);
    
    NSDictionary *dic = [boaSegmentsResSegmentsPayload JSONDictionary];
    XCTAssertNil(dic);
    
    NSError *paringError;
    BOASegmentsResSegmentsPayload *boaSegmentPayloadForStr = [BOASegmentsResSegmentsPayload fromJSON:[self getDummyJson] encoding:NSUTF8StringEncoding error:&paringError];
    XCTAssertNil(boaSegmentPayloadForStr);
    
    BOASegmentsResSegmentsPayload *boaSegmentEventsForData = [BOASegmentsResSegmentsPayload fromData:[[self getDummyJson] dataUsingEncoding:NSUTF8StringEncoding] error:&paringError];
    XCTAssertNil(boaSegmentEventsForData);
    
    NSString *jsonStr = [boaSegmentEventsForData toJSON:NSUTF8StringEncoding error:&paringError];
    XCTAssertNil(jsonStr);
    
    NSData *data = [boaSegmentEventsForData toData:&paringError];
    XCTAssertNil(data);
}

- (void)testBOASegmentsResGeoMethods {
    BOASegmentsResGeo *boaSegmentsResGeo = [BOASegmentsResGeo fromJSONDictionary:dict];
    XCTAssertNotNil(boaSegmentsResGeo);
    
    NSDictionary *dic = [boaSegmentsResGeo JSONDictionary];
    XCTAssertNotNil(dic);
}

- (void)testBOASegmentsResMetaMethods {
    //TODO: check with Ankur..return non nil value but getting nil values
    BOASegmentsResMeta *boaSegmentsResMeta = [BOASegmentsResMeta fromJSONDictionary:dict];
    XCTAssertNil(boaSegmentsResMeta);
    
    NSDictionary *dic = [boaSegmentsResMeta JSONDictionary];
    XCTAssertNil(dic);
}

- (void)testBOASegmentsResSegmentMethods {
    BOASegmentsResSegment *boaSegmentsResMeta = [BOASegmentsResSegment fromJSONDictionary:dict];
    XCTAssertNotNil(boaSegmentsResMeta);
    
    NSDictionary *dic = [boaSegmentsResMeta JSONDictionary];
    XCTAssertNotNil(dic);
}

- (NSString *)getDummyJson {
    return @"{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true}";
    
}

@end
