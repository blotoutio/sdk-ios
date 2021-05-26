//
//  BOServerDataConverterTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 23/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOServerDataConverter.h"
#import "BOAppSessionData.h"
#import "BOALocalDefaultJSONs.h"

@interface BOServerDataConverterTests : XCTestCase

@end

@implementation BOServerDataConverterTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPrepareMetaData {
    NSDictionary *metaData = [BOServerDataConverter prepareMetaData];
    XCTAssertNotNil(metaData);
    NSString *appn = [metaData valueForKey:@"appn"];
    XCTAssertGreaterThan([appn length], 0);
}

- (void)testPrepareGeoData {
    NSDictionary *geoData = [BOServerDataConverter prepareGeoData];
    XCTAssertNotNil(geoData);
    NSString *country = [geoData valueForKey:@"couc"];
    XCTAssertNotNil(country);
}

- (void)testPreparePreviousMetaData {
    //    TODO: Discuss with ankur...getting nil but should get non nil value
    BOAppSessionData *appSessionData = [BOAppSessionData sharedInstanceFromJSONDictionary:[BOALocalDefaultJSONs appSessionJSONDict]];
    NSDictionary *preMetaData = [BOServerDataConverter preparePreviousMetaData: appSessionData];
    XCTAssertNotNil(preMetaData);
}


- (void)testStorePreviousDayAppInfoViaNotification {
    //    TODO: Discuss with ankur...getting nil but should get non nil value
    NSNotification *notification = [[NSNotification alloc] initWithName:@"testNoti" object:self userInfo:nil];
    [BOServerDataConverter storePreviousDayAppInfoViaNotification: notification];
}
@end

/*
 + (NSDictionary *)preparePreviousMetaData:(nullable BOAppSessionData*)sessionData;
 + (void)storePreviousDayAppInfoViaNotification:(nullable NSNotification*)notification;
 
 */
