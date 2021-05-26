//
//  BOAFunnelPayloadTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 19/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAFunnelPayload.h"

@interface BOAFunnelPayloadTests : XCTestCase

@end

@implementation BOAFunnelPayloadTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testBOAFunnelPayloadMethods {
    NSDictionary *dict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    
    BOAFunnelPayload *boaFunnelPayload = [BOAFunnelPayload fromJSONDictionary:dict];
    XCTAssertNotNil(boaFunnelPayload);
    
    NSDictionary *dic = [boaFunnelPayload JSONDictionary];
    XCTAssertNotNil(dic);
    
    NSError *paringError;
    BOAFunnelPayload *boaFunnelPayloadForStr = [BOAFunnelPayload fromJSON:[self getDummyJson] encoding:NSUTF8StringEncoding error:&paringError];
    XCTAssertNotNil(boaFunnelPayloadForStr);
    
    BOAFunnelPayload *boaFunnelPayloadForData = [BOAFunnelPayload fromData:[[self getDummyJson] dataUsingEncoding:NSUTF8StringEncoding] error:&paringError];
    XCTAssertNotNil(boaFunnelPayloadForData);
    
    NSString *jsonStr = [boaFunnelPayloadForData toJSON:NSUTF8StringEncoding error:&paringError];
    XCTAssertNotNil(jsonStr);
    
    NSData *data = [boaFunnelPayloadForData toData:&paringError];
    XCTAssertNotNil(data);
}

- (void)testBOAFunnelEventMethods {
    NSDictionary *dict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    
    BOAFunnelEvent *boaFunnelEvent = [BOAFunnelEvent fromJSONDictionary:dict];
    XCTAssertNotNil(boaFunnelEvent);
    
    NSDictionary *dic = [boaFunnelEvent JSONDictionary];
    XCTAssertNotNil(dic);
}

- (void)testBOAFunnelGeoMethods {
    NSDictionary *dict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    
    BOAFunnelGeo *boaFunnelGeo = [BOAFunnelGeo fromJSONDictionary:dict];
    XCTAssertNotNil(boaFunnelGeo);
    
    NSDictionary *dic = [boaFunnelGeo JSONDictionary];
    XCTAssertNotNil(dic);
}

- (void)testBOAFunnelMetaMethods {
    NSDictionary *dict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    
    BOAFunnelMeta *boaFunnelMeta = [BOAFunnelMeta fromJSONDictionary:dict];
    XCTAssertNil(boaFunnelMeta);
    
    NSDictionary *dic = [boaFunnelMeta JSONDictionary];
    XCTAssertNil(dic);
}

- (NSString *)getDummyJson {
    return @"{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true}";
    
}

@end
