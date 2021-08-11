//
//  BOAUtilitiesTests.m
//  BlotoutAnalyticsTests
//
//  Created by ankuradhikari on 13/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAUtilities.h"
#import <BlotoutFoundation/BlotoutFoundation.h>
#import "BOANetworkConstants.h"

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

- (void)testCurrentDateGeneration {
    NSDate *date = [BOAUtilities getCurrentDate];
    XCTAssertNotNil(date,@"Date Can't be null");
}


- (void)testTimestampLength {
    NSString *thirteenDigitTimeStampString = [NSString stringWithFormat:@"%lu",[BOAUtilities get13DigitIntegerTimeStamp]];
    XCTAssertTrue(thirteenDigitTimeStampString.length == 13);
}

-(void)testHashFunction {
    NSString* hashString = [BOAUtilities md5HashOfString:@"Date Can't be null"];
    XCTAssertNotNil(hashString);
}

-(void)testJsonStringFromDict {
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"blotoutuser" forKey:@"username"];
    NSString* jsonString = [BOAUtilities jsonStringFrom: dic withPrettyPrint:YES];
    XCTAssertNotNil(jsonString, @"Couldn't find json string for given dict");
}

-(void)testJsonDataFromDict {
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"blotoutuser" forKey:@"username"];
    NSData* jsonData = [BOAUtilities jsonDataFrom: dic withPrettyPrint:YES];
    XCTAssertNotNil(jsonData, @"Couldn't find json data for given dict");
}

-(void)testJsonObjectFromString {
    NSString *jsonStr = @"{\"username\" : \"blotoutuser\"}";
    id jsonObj = [BOAUtilities jsonObjectFromString: jsonStr];
    XCTAssertNotNil(jsonObj, @"Couldn't find json obj for given json string");
}

-(void)testJsonObjectFromData {
    NSString *jsonStr = @"{\"username\" : \"blotoutuser\"}";
    NSData *jsonData = [jsonStr dataUsingEncoding: kCFStringEncodingUTF8];
    id jsonObj = [BOAUtilities jsonObjectFromData: jsonData];
    XCTAssertNotNil(jsonObj, @"Couldn't find json obj for given data");
}

-(void)testGetCurrentDate {
    NSDate *currentDate = [BOAUtilities getCurrentDate];
    XCTAssertNotNil(currentDate, @"Couldn't find current date");
}

-(void)testGetMessageIDForEvent {
    NSString *mId = [BOAUtilities getMessageIDForEvent: @"DAU"];
    XCTAssertNotNil(mId, @"Couldn't find date with in given time interval");
}

-(void)testCodeForCustomCodifiedEvent {
    NSNumber *eventSubCode = [BOAUtilities codeForCustomCodifiedEvent: @"awesome_event"];
    XCTAssertNotNil(eventSubCode, @"Couldn't find code for custom codified event");
    XCTAssertEqual(eventSubCode.intValue, 24008, @"name with underscore");
    
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    [analyticsRootUD removeObjectForKey: BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS];
    
    eventSubCode = [BOAUtilities codeForCustomCodifiedEvent: @"TestInfo"];
    XCTAssertNotNil(eventSubCode, @"Couldn't find code for custom codified event");
    
    NSNumber *eventSubCodeSpaces = [BOAUtilities codeForCustomCodifiedEvent: @"some awesome event"];
    XCTAssertEqual(eventSubCodeSpaces.intValue, 24016, @"name has spaces");
    
    NSNumber *eventSubCodeAscii = [BOAUtilities codeForCustomCodifiedEvent: @"目_awesome_event"];
    XCTAssertEqual(eventSubCodeAscii.intValue, 24049, @"name has asc11");
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

-(void)testMd5CharDataOfString {
    NSData *data = [BOAUtilities md5CharDataOfString:@"String to encrypt"];
    XCTAssertNotNil(data, @"Couldn't find md5 char data of string");
}

-(void)testIntValueForChar {
    int value = [BOAUtilities intValueForChar: [@"0" characterAtIndex:0]];
    XCTAssertEqual(value, 0, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"1" characterAtIndex:0]];
    XCTAssertEqual(value, 1, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"2" characterAtIndex:0]];
    XCTAssertEqual(value, 2, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"3" characterAtIndex:0]];
    XCTAssertEqual(value, 3, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"4" characterAtIndex:0]];
    XCTAssertEqual(value, 4, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"5" characterAtIndex:0]];
    XCTAssertEqual(value, 5, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"6" characterAtIndex:0]];
    XCTAssertEqual(value, 6, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"7" characterAtIndex:0]];
    XCTAssertEqual(value, 7, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"8" characterAtIndex:0]];
    XCTAssertEqual(value, 8, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"9" characterAtIndex:0]];
    XCTAssertEqual(value, 9, @"Couldn't find int value for char");
    
    value = [BOAUtilities intValueForChar: [@" " characterAtIndex:0]];
    XCTAssertEqual(value, 10, @"Couldn't find int value for char");
    
    value = [BOAUtilities intValueForChar: [@"a" characterAtIndex:0]];
    XCTAssertEqual(value, 11, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"b" characterAtIndex:0]];
    XCTAssertEqual(value, 12, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"c" characterAtIndex:0]];
    XCTAssertEqual(value, 13, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"d" characterAtIndex:0]];
    XCTAssertEqual(value, 14, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"e" characterAtIndex:0]];
    XCTAssertEqual(value, 15, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"f" characterAtIndex:0]];
    XCTAssertEqual(value, 16, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"g" characterAtIndex:0]];
    XCTAssertEqual(value, 17, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"h" characterAtIndex:0]];
    XCTAssertEqual(value, 18, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"i" characterAtIndex:0]];
    XCTAssertEqual(value, 19, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"j" characterAtIndex:0]];
    XCTAssertEqual(value, 20, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"k" characterAtIndex:0]];
    XCTAssertEqual(value, 21, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"l" characterAtIndex:0]];
    XCTAssertEqual(value, 22, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"m" characterAtIndex:0]];
    XCTAssertEqual(value, 23, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"n" characterAtIndex:0]];
    XCTAssertEqual(value, 24, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"o" characterAtIndex:0]];
    XCTAssertEqual(value, 25, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"p" characterAtIndex:0]];
    XCTAssertEqual(value, 26, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"q" characterAtIndex:0]];
    XCTAssertEqual(value, 27, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"r" characterAtIndex:0]];
    XCTAssertEqual(value, 28, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"s" characterAtIndex:0]];
    XCTAssertEqual(value, 29, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"t" characterAtIndex:0]];
    XCTAssertEqual(value, 30, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"u" characterAtIndex:0]];
    XCTAssertEqual(value, 31, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"v" characterAtIndex:0]];
    XCTAssertEqual(value, 32, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"w" characterAtIndex:0]];
    XCTAssertEqual(value, 33, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"x" characterAtIndex:0]];
    XCTAssertEqual(value, 34, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"y" characterAtIndex:0]];
    XCTAssertEqual(value, 35, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"z" characterAtIndex:0]];
    
    XCTAssertEqual(value, 36, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"A" characterAtIndex:0]];
    XCTAssertEqual(value, 37, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"B" characterAtIndex:0]];
    XCTAssertEqual(value, 38, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"C" characterAtIndex:0]];
    XCTAssertEqual(value, 39, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"D" characterAtIndex:0]];
    XCTAssertEqual(value, 40, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"E" characterAtIndex:0]];
    XCTAssertEqual(value, 41, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"F" characterAtIndex:0]];
    XCTAssertEqual(value, 42, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"G" characterAtIndex:0]];
    XCTAssertEqual(value, 43, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"H" characterAtIndex:0]];
    XCTAssertEqual(value, 44, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"I" characterAtIndex:0]];
    XCTAssertEqual(value, 45, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"J" characterAtIndex:0]];
    XCTAssertEqual(value, 46, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"K" characterAtIndex:0]];
    XCTAssertEqual(value, 47, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"L" characterAtIndex:0]];
    XCTAssertEqual(value, 48, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"M" characterAtIndex:0]];
    XCTAssertEqual(value, 49, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"N" characterAtIndex:0]];
    XCTAssertEqual(value, 50, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"O" characterAtIndex:0]];
    XCTAssertEqual(value, 51, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"P" characterAtIndex:0]];
    XCTAssertEqual(value, 52, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"Q" characterAtIndex:0]];
    XCTAssertEqual(value, 53, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"R" characterAtIndex:0]];
    XCTAssertEqual(value, 54, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"S" characterAtIndex:0]];
    XCTAssertEqual(value, 55, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"T" characterAtIndex:0]];
    XCTAssertEqual(value, 56, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"U" characterAtIndex:0]];
    XCTAssertEqual(value, 57, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"V" characterAtIndex:0]];
    XCTAssertEqual(value, 58, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"W" characterAtIndex:0]];
    XCTAssertEqual(value, 59, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"X" characterAtIndex:0]];
    XCTAssertEqual(value, 60, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"Y" characterAtIndex:0]];
    XCTAssertEqual(value, 61, @"Couldn't find int value for char");
    value = [BOAUtilities intValueForChar: [@"Z" characterAtIndex:0]];
    XCTAssertEqual(value, 62, @"Couldn't find int value for char");
}

-(void)testIsNumberChar {
    NSString *str = @"123";
    char one = [str characterAtIndex:0];
    BOOL status = [BOAUtilities isNumberChar: one];
    XCTAssertTrue(status, @"Couldn't find either char is number of charecter");
}

-(void)testGetAsciiSum {
    int asciiSum = [BOAUtilities getAsciiSum:@"abc" usingCaseSenstive: YES];
    XCTAssertEqual(asciiSum, 294, @"Couldn't find ascii sum for given string");
}

-(void)testGetAsciiCustomIntSum {
    int asciiSum = [BOAUtilities getAsciiCustomIntSum:@"abc" usingCaseSenstive: YES];
    XCTAssertEqual(asciiSum, 36, @"Couldn't find ascii custom int sum for given string");
}

-(void)testGetCurrentTimezoneOffsetInMin {
    int value = [BOAUtilities getCurrentTimezoneOffsetInMin];
    XCTAssertEqual(value, 330);
    
    value = [BOAUtilities getCurrentTimezoneOffsetInMin:[NSTimeZone timeZoneWithName:@"UTC"]];
    XCTAssertEqual(value, 0);
}

-(void)testConvertTo64CharUUID{
    NSString *uuid = [BOAUtilities convertTo64CharUUID:@"abfdfredskdfredk"];
    XCTAssertNotNil(uuid);
}

@end
