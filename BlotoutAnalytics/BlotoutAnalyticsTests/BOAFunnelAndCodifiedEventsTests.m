//
//  BOAFunnelAndCodifiedEventsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 18/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAFunnelAndCodifiedEvents.h"

@interface BOAFunnelAndCodifiedEventsTests : XCTestCase
@property (nonatomic) BOAFunnelAndCodifiedEvents *boaFunnelAndCodifiedEvents;
@end

@implementation BOAFunnelAndCodifiedEventsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testBOAFunnelAndCodifiedEvents {
    NSError *paringError;
    BOAFunnelAndCodifiedEvents *funnelsAndCodifiedEvents = [BOAFunnelAndCodifiedEvents fromJSON:[self getDummyJson] encoding:NSUTF8StringEncoding error:&paringError];;
    XCTAssertNotNil(funnelsAndCodifiedEvents);
    
    NSData *data = [[self getDummyJson] dataUsingEncoding:NSUTF8StringEncoding];
    BOAFunnelAndCodifiedEvents *funnelsAndCodifiedEventsForData = [BOAFunnelAndCodifiedEvents fromData:data error:&paringError];
    XCTAssertNotNil(funnelsAndCodifiedEventsForData);
    
    
    NSData *dataHold = [funnelsAndCodifiedEventsForData toData:&paringError];
    XCTAssertNotNil(dataHold);
    
    NSString *jsonStr = [funnelsAndCodifiedEventsForData toJSON:NSUTF8StringEncoding error:&paringError];
    XCTAssertNotNil(jsonStr);
}

- (void)testBOAEventsCodified{
    NSDictionary *innerDict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    BOAEventsCodified *boaEventsCodified = [BOAEventsCodified fromJSONDictionary:innerDict];
    XCTAssertNotNil(boaEventsCodified);
    NSDictionary *dic = [BOAEventsCodified properties];
    XCTAssertNotNil(dic);
    
    BOAEventsCodified *eventObj = [boaEventsCodified initWithJSONDictionary:innerDict];
    XCTAssertNotNil(eventObj);
    
    [boaEventsCodified setValue:@"value" forKey:@"key"];
    
    NSDictionary *values = [boaEventsCodified JSONDictionary];
    XCTAssertNotNil(values);
}


- (void)testBOAEventList{
    NSDictionary *innerDict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    BOAEventList *boaEventList = [BOAEventList fromJSONDictionary:innerDict];
    XCTAssertNotNil(boaEventList);
    NSDictionary *dic = [BOAEventList properties];
    XCTAssertNotNil(dic);
    
    BOAEventList *eventObj = [boaEventList initWithJSONDictionary:innerDict];
    XCTAssertNotNil(eventObj);
    
    [boaEventList setValue:@"value" forKey:@"key"];
    
    NSDictionary *values = [boaEventList JSONDictionary];
    XCTAssertNotNil(values);
}

- (void)testBOAEventsFunnel{
    NSDictionary *innerDict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    BOAEventsFunnel *boaEventsFunnel = [BOAEventsFunnel fromJSONDictionary:innerDict];
    XCTAssertNotNil(boaEventsFunnel);
    NSDictionary *dic = [BOAEventsFunnel properties];
    XCTAssertNotNil(dic);
    
    BOAEventsFunnel *eventObj = [boaEventsFunnel initWithJSONDictionary:innerDict];
    XCTAssertNotNil(eventObj);
    
    [boaEventsFunnel setValue:@"value" forKey:@"key"];
    
    NSDictionary *values = [boaEventsFunnel JSONDictionary];
    XCTAssertNotNil(values);
}

- (void)testBOAGeoFunnelAndCodifed{
    NSDictionary *innerDict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    BOAGeoFunnelAndCodifed *boaGeoFunnelAndCodifed = [BOAGeoFunnelAndCodifed fromJSONDictionary:innerDict];
    XCTAssertNotNil(boaGeoFunnelAndCodifed);
    NSDictionary *dic = [BOAGeoFunnelAndCodifed properties];
    XCTAssertNotNil(dic);
    
    BOAGeoFunnelAndCodifed *eventObj = [boaGeoFunnelAndCodifed initWithJSONDictionary:innerDict];
    XCTAssertNotNil(eventObj);
    
    [boaGeoFunnelAndCodifed setValue:@"value" forKey:@"key"];
    
    NSDictionary *values = [boaGeoFunnelAndCodifed JSONDictionary];
    XCTAssertNotNil(values);
}

- (NSString *)getDummyJson {
    return @"{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true}";
    
}

@end
