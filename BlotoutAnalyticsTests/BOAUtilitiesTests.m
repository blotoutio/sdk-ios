//
//  BOAUtilitiesTests.m
//  BlotoutAnalyticsTests
//
//  Created by ankuradhikari on 13/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

@import XCTest;
@import BlotoutAnalyticsSDK;

@interface BOAUtilitiesTests : XCTestCase

@end

@implementation BOAUtilitiesTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDeviceIdGeneration {
    NSString *deviceId = [BOAUtilities getDeviceId];
    XCTAssertNotNil(deviceId,@"Unique Device Can't be null");
    
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    [analyticsRootUD removeObjectForKey:BO_ANALYTICS_USER_UNIQUE_KEY];
    
    deviceId = [BOAUtilities getDeviceId];
    XCTAssertNotNil(deviceId,@"Unique Device Can't be null");
    
    
    NSString *fetchDeviceIDAgain = [BOAUtilities getDeviceId];
    XCTAssertTrue([deviceId isEqualToString:fetchDeviceIDAgain]);
}

- (void)testTimestampLength {
    NSString *thirteenDigitTimeStampString = [NSString stringWithFormat:@"%lu",[BOAUtilities get13DigitIntegerTimeStamp]];
    XCTAssertTrue(thirteenDigitTimeStampString.length == 13);
}

-(void)testJsonDataFromDict {
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"blotoutuser" forKey:@"username"];
    NSData* jsonData = [BOAUtilities jsonDataFrom: dic withPrettyPrint:YES];
    XCTAssertNotNil(jsonData, @"Couldn't find json data for given dict");
}

-(void)testGetMessageIDForEvent {
    NSString *mId = [BOAUtilities getMessageIDForEvent: @"DAU"];
    XCTAssertNotNil(mId, @"Couldn't find date with in given time interval");
}


-(void)testCurrentPlatformCode {
    int platformCode = [BOAUtilities currentPlatformCode];
    XCTAssertGreaterThan(platformCode, 0, @"Couldn't find current platform code");
}

-(void)testgetDeviceId {
    NSString *deviceId = [BOAUtilities getDeviceId];
    XCTAssertNotNil(deviceId, @"Couldn't find device id");
}

-(void)testGetUUIDString {
    NSString *deviceId = [BOAUtilities getUUIDString];
    XCTAssertNotNil(deviceId, @"Couldn't find device uuid");
}

-(void)testTopViewController {
    UIViewController *cont = [[UIViewController alloc] init];
    UIViewController *controller = [BOAUtilities topViewController: cont];
    XCTAssertNotNil(controller, @"Couldn't find top view controller");
    
    UINavigationController *navCont = [[UINavigationController alloc] initWithRootViewController:cont];
    controller = [BOAUtilities topViewController: navCont];
    XCTAssertNotNil(controller, @"Couldn't find top view controller");
    
    UITabBarController *tabCont = [[UITabBarController alloc] init];
    [tabCont setViewControllers:[NSArray arrayWithObject:cont] animated:NO];
    controller = [BOAUtilities topViewController: tabCont];
    XCTAssertNotNil(controller, @"Couldn't find top view controller");
}

-(void)testConvertTo64CharUUID{
    NSString *uuid = [BOAUtilities convertTo64CharUUID:@"abfdfredskdfredk"];
    XCTAssertNotNil(uuid);
}

@end
