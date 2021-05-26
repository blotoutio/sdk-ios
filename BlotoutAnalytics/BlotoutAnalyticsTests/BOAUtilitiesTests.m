//
//  BOAUtilitiesTests.m
//  BlotoutAnalyticsTests
//
//  Created by ankuradhikari on 13/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAConstants.h"


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

- (void)testAllDateGeneration {
    NSDate *date = [BOAUtilities getCurrentDate];
    NSDate *referenceDate = [BOAUtilities getDateWithTimeInterval:[BOAUtilities get13DigitIntegerTimeStamp] sinceDate:date];
    XCTAssertNotNil(referenceDate,@"Date Can't be null");
    
    NSTimeInterval referenceTimeIntervalFromNow = [BOAUtilities getTimeIntervalSicneNowOfDate:date];
    XCTAssertTrue(referenceTimeIntervalFromNow);
    
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-13T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-13T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSTimeInterval miliSecondsInterval = [BOAUtilities milliSecondsIntervalBetween:date1 andDate2:date2];
    XCTAssertTrue(miliSecondsInterval == 1);
    
    NSTimeInterval secondsInterval = [BOAUtilities secondsIntervalBetween:date1 andDate2:date2];
    XCTAssertTrue(secondsInterval == 1000);
    
    NSNumber *dateObject = [NSNumber numberWithLong:[BOAUtilities get13DigitIntegerTimeStamp]];
    NSNumber *roundOffTimeStamp = [BOAUtilities roundOffTimeStamp:dateObject];
    XCTAssertNotNil(roundOffTimeStamp);
}

- (void)testTimestampLength {
    NSString *tenDigitTimeStampString = [NSString stringWithFormat:@"%lu",[BOAUtilities get10DigitIntegerTimeStamp]];
    XCTAssertTrue(tenDigitTimeStampString.length == 10);
    
    NSString *thirteenDigitTimeStampString = [NSString stringWithFormat:@"%lu",[BOAUtilities get13DigitIntegerTimeStamp]];
    XCTAssertTrue(thirteenDigitTimeStampString.length == 13);
}

-(void)testCalendarDay {
    
    NSInteger day = [BOAUtilities getDayFromDateString:@"2020-09-13T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    XCTAssertTrue(day == 13);
    
    NSDate *date = [BOAUtilities dateStr:@"2020-09-13T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSInteger dayFromDate = [BOAUtilities getDayFromDate:date];
    XCTAssertTrue(dayFromDate == 13);
}

-(void)testCalendarMonth {
    
    NSInteger month = [BOAUtilities getMonthFromDateString:@"2020-09-13T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    XCTAssertTrue(month == 9);
    
    NSDate *date = [BOAUtilities dateStr:@"2020-09-13T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSInteger monthFromDate = [BOAUtilities getMonthFromDate:date];
    XCTAssertTrue(monthFromDate == 9);
}

-(void)testCalendarYear {
    
    NSInteger year = [BOAUtilities getYearFromDateString:@"2020-09-13T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    XCTAssertTrue(year == 2020);
    
    NSDate *date = [BOAUtilities dateStr:@"2020-09-13T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSInteger yearFromDate = [BOAUtilities getYearFromDate:date];
    XCTAssertTrue(yearFromDate == 2020);
}

-(void)testDateComparison {
    
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-13T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    BOOL isDateGreater = [BOAUtilities isDate:date1 greaterThan:date2];
    XCTAssertTrue(isDateGreater);
    
    isDateGreater = [BOAUtilities isDate:date2 greaterThan:date1];
    XCTAssertTrue(!isDateGreater);
    
    
    BOOL isDateLessThan = [BOAUtilities isDate:date1 lessThan:date2];
    XCTAssertFalse(isDateLessThan);
    
    isDateLessThan = [BOAUtilities isDate:date2 lessThan:date1];
    XCTAssertFalse(!isDateLessThan);
    
    
    NSDate *date3 = [BOAUtilities dateStr:@"2020-09-14T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    BOOL isDateEqual = [BOAUtilities isDate:date1 equalTo:date3];
    XCTAssertFalse(isDateEqual);
    
    isDateEqual = [BOAUtilities isDate:date1 equalTo:date1];
    XCTAssertTrue(isDateEqual);
    
    
    NSDate *date4 = [BOAUtilities dateStr:@"2020-09-14T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    BOOL isDateBetween = [BOAUtilities isDate:date4 between:date1 andDate2:date2];
    XCTAssertFalse(isDateBetween);
}

-(void)testDateEquality {
    
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-15T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    BOOL isDaySame = [BOAUtilities isDaySameOfDate:date1 andDate2:date2];
    XCTAssertTrue(isDaySame);
    
    BOOL isMonthSame = [BOAUtilities isMonthSameOfDate:date1 andDate2:date2];
    XCTAssertTrue(isMonthSame);
    
    BOOL isYearSame = [BOAUtilities isYearSameOfDate:date1 andDate2:date2];
    XCTAssertTrue(isYearSame);
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

-(void)testGetDateWithTimeIntervalSinceDate {
    NSDate *date = [BOAUtilities getDateWithTimeInterval:[BOAUtilities get13DigitIntegerTimeStamp] sinceDate:date];
    XCTAssertNotNil(date, @"Couldn't find date with in given time interval");
}

-(void)testGetDateWithTimeInterval {
    NSDate *date = [BOAUtilities getDateWithTimeInterval:[BOAUtilities get13DigitIntegerTimeStamp]];
    XCTAssertNotNil(date, @"Couldn't find date with in given time interval");
}

-(void)testGetStringMD5CustomIntSumWithCharIndexAdded {
    int eventNameIntSum = [BOAUtilities getStringMD5CustomIntSumWithCharIndexAdded:@"appEvent" usingCaseSenstive:NO];
    XCTAssertGreaterThan(eventNameIntSum, 0, @"Couldn't find string md5 custom int sum with char index");
}

-(void)testGetMessageIDForEvent {
    NSString *mId = [BOAUtilities getMessageIDForEvent: @"DAU"];
    XCTAssertNotNil(mId, @"Couldn't find date with in given time interval");
}

-(void)testGetMessageIDForEventAndIdentifier {
    NSString *mId = [BOAUtilities getMessageIDForEvent: @"DAU" andIdentifier: [NSNumber numberWithInt:41001]];
    XCTAssertNotNil(mId, @"Couldn't find date with in given time interval and indentifier");
}

-(void)testGenerateMessageIDForEvent {
    NSString *mId = [BOAUtilities generateMessageIDForEvent:@"testevent" evnetCode: @"41001" happenedAt:[BOAUtilities get13DigitNumberObjTimeStamp]];
    XCTAssertNotNil(mId, @"Couldn't generate message id for event");
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

-(void)testGetOnlyAsciiCharsCustomIntSumFromUnicode {
    int asciiSum = [BOAUtilities getOnlyAsciiCharsCustomIntSumFromUnicode:@"abc" usingCaseSenstive: YES];
    XCTAssertEqual(asciiSum, 36, @"Couldn't find ascii char custom int sum for given unicode");
}

-(void)testGetStringMD5CustomIntSum {
    int asciiSum = [BOAUtilities getStringMD5CustomIntSum:@"abc" usingCaseSenstive: YES];
    XCTAssertEqual(asciiSum, 229, @"Couldn't find ascii char custom int sum for given unicode");
}

-(void)testGetAllDatesBetween {
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-10T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-20T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSArray *dates = [BOAUtilities getAllDatesBetween: date1 andDate2: date2];
    XCTAssertGreaterThan(dates.count, 0, @"Couldn't find dates in given range");
}

-(void)testGetDateBetween {
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-10T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-12T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date = [BOAUtilities getDateBetween: date1 andDate2: date2];
    XCTAssertNotNil(date, @"Couldn't find date in given range");
}

-(void)testGetDateGreaterThan {
    NSDate *date = [BOAUtilities dateStr:@"2020-09-10T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *greaterThanDate = [BOAUtilities getDateGreaterThan:date];
    XCTAssertNotNil(greaterThanDate, @"Couldn't find greater than date");
}

-(void)testGetDateLessThan {
    NSDate *date = [BOAUtilities dateStr:@"2020-09-10T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *lessThanDate = [BOAUtilities getDateLessThan:date];
    XCTAssertNotNil(lessThanDate, @"Couldn't find less than date");
}

-(void)testGetPreviousDayDateFrom {
    NSDate *date = [BOAUtilities dateStr:@"2020-09-10T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *prevDayDate = [BOAUtilities getPreviousDayDateFrom:date];
    XCTAssertNotNil(prevDayDate, @"Couldn't find previous day date");
}

-(void)testGetPreviousDayDateInFormat {
    NSDate *prevDayDate = [BOAUtilities getPreviousDayDateFrom:@"2020-10-23" inFormat:@"yyyy-MM-dd"];
    XCTAssertNotNil(prevDayDate, @"Couldn't find previous day date in given format");
}

-(void)testGetPreviousDayDateFromInFormatFromDate {
    NSDate *date = [BOAUtilities dateStr:@"2020-09-10T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *prevDayDateStr = [BOAUtilities getPreviousDayDateInFormat:@"yyyy-MM-dd" fromReferenceDate:date];
    XCTAssertNotNil(prevDayDateStr, @"Couldn't find previous day date in given format from date");
}

-(void)testIsWeekSameOfDate {
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-16T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    BOOL status = [BOAUtilities isWeekSameOfDate:date1 andDate2:date2];
    XCTAssertTrue(status, @"Couldn't find given dates are of same week");
}

-(void)testIsMonthAndYearSameOfDate {
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-16T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    BOOL status = [BOAUtilities isMonthAndYearSameOfDate:date1 andDate2:date2];
    XCTAssertTrue(status, @"Couldn't find month and year are of same for given date");
}

-(void)testIsDateGreaterThanEqualTo {
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-16T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    BOOL status = [BOAUtilities isDate:date1 greaterThanEqualTo:date2];
    XCTAssertTrue(!status, @"Couldn't find month and year are of same for given date");
    
    status = [BOAUtilities isDate:date2 greaterThanEqualTo:date1];
    XCTAssertTrue(status, @"Couldn't find month and year are of same for given date");
    
}


-(void)testIsMonthAndYearSameOfDateInFormat {
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *date2Str = @"2020-09-16";
    BOOL status = [BOAUtilities isMonthAndYearSameOfDate:date1 andDateStr:date2Str inFormat:@"yyyy-MM-dd"];
    XCTAssertTrue(status, @"Couldn't find month and year are of same for given date format");
}

-(void)testIsDayMonthAndYearSameOfDate {
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-15T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    BOOL status = [BOAUtilities isDayMonthAndYearSameOfDate:date1 andDate2:date2];
    XCTAssertTrue(status, @"Couldn't find day month and year are of same for given date");
}

-(void)testIsDayMonthAndYearSameOfDateWithFormat {
    NSString *dateStr1 = @"2020-09-15T12:30:40.200Z";
    NSString *dateStr2 = @"2020-09-15T12:30:40.200Z";
    BOOL status = [BOAUtilities isDayMonthAndYearSameOfDate:dateStr1 andDate2:dateStr2 inFomrat:@"yyyy-MM-dd"];
    XCTAssertTrue(status, @"Couldn't find day month and year are of same for given date");
}

-(void)testIsDayMonthAndYearSameOfDateStrWithFormat {
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *dateStr2 = @"2020-09-15";
    BOOL status = [BOAUtilities isDayMonthAndYearSameOfDate:date1 andDateStr:dateStr2 inFomrat:@"yyyy-MM-dd"];
    XCTAssertTrue(status, @"Couldn't find day month and year are of same for given date");
}

-(void)testIsDateUnderWeek {
    NSDate *date = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    BOOL status = [BOAUtilities isDate: date underWeek: 3];
    XCTAssertTrue(status, @"Couldn't find date is under in given week");
}

-(void)testIsDateUnderWeekOfYear {
    NSDate *date = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    BOOL status = [BOAUtilities isDate:date underWeekOfYear:38];
    XCTAssertTrue(status, @"Couldn't find date is under in given week of year");
}

-(void)testIsDateUnderMonth {
    NSDate *date = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    BOOL status = [BOAUtilities isDate:date underMonth:9];
    XCTAssertTrue(status, @"Couldn't find date is under in given month");
}

-(void)testGetCurrentTimezoneOffsetInMin {
    int value = [BOAUtilities getCurrentTimezoneOffsetInMin];
    XCTAssertEqual(value, 330);
    
    value = [BOAUtilities getCurrentTimezoneOffsetInMin:[NSTimeZone timeZoneWithName:@"UTC"]];
    XCTAssertEqual(value, 0);
}

-(void)testWeekMonthYearMethods {
    NSInteger startDay = [BOAUtilities weekStartDay];
    XCTAssertGreaterThan(startDay, 0, @"Couldn't find weeks start day");
    
    NSInteger endDay = [BOAUtilities weekEndDay];
    XCTAssertGreaterThan(endDay, 0, @"Couldn't find weeks end day");
    
    NSInteger weekOfMonth = [BOAUtilities weekOfMonth];
    XCTAssertGreaterThan(weekOfMonth, 0, @"Couldn't find week of month");
    
    NSInteger weekOfYear = [BOAUtilities weekOfYear];
    XCTAssertGreaterThan(weekOfYear, 0, @"Couldn't find week of year");
    
    NSInteger monthStartDay = [BOAUtilities monthStartDay];
    XCTAssertGreaterThan(monthStartDay, 0, @"Couldn't find month start day");
    
    NSInteger monthEndDay = [BOAUtilities monthEndDay];
    XCTAssertGreaterThan(monthEndDay, 0, @"Couldn't find month end day");
    
    NSInteger monthLength = [BOAUtilities monthLength];
    XCTAssertGreaterThan(monthLength, 0, @"Couldn't find month length");
    
    NSDate *date = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSInteger weekOfYearForDate = [BOAUtilities weekOfYearForDate: date];
    XCTAssertEqual(weekOfYearForDate, 38, @"Couldn't find date is under in given week of year");
    
    NSTimeInterval elapsedTime = 1604389885869;
    NSInteger weekOfYearForInterval = [BOAUtilities weekOfYearForDateInterval: elapsedTime];
    XCTAssertEqual(weekOfYearForInterval, 45, @"Couldn't find week of year for interval");
    
    NSInteger monthOfYearForDate = [BOAUtilities monthOfYearForDate: date];
    XCTAssertEqual(monthOfYearForDate, 9, @"Couldn't find month of year for date");
    
    NSInteger monthOfYearForDateInterval = [BOAUtilities monthOfYearForDateInterval: elapsedTime];
    XCTAssertEqual(monthOfYearForDateInterval, 11, @"Couldn't find month of year for interval");
}

-(void)testTenAndThrteenDigitTimeStamp {
    //TODO: check this method only
    NSDate *date = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSNumber *tenDigitTimeStampNumber = [BOAUtilities get10DigitNumberObjTimeStampFor: date];
    NSString *str = [NSString stringWithFormat:@"%@", tenDigitTimeStampNumber];
    XCTAssertTrue([str length] == 9);
    
    NSInteger tenDigitIntTimeStamp = [BOAUtilities get10DigitIntegerTimeStampFor: date];
    str = [NSString stringWithFormat:@"%ld", (long)tenDigitIntTimeStamp];
    XCTAssertTrue([str length] == 10);
    
    NSNumber *thrteenDigitNumTimeStamp = [BOAUtilities get13DigitNumberObjTimeStampFor: date];
    str = [NSString stringWithFormat:@"%@", thrteenDigitNumTimeStamp];
    XCTAssertTrue([str length] == 13);
    
    NSInteger thrteenDigitIntTimeStamp = [BOAUtilities get13DigitIntegerTimeStampFor: date];
    str = [NSString stringWithFormat:@"%ld", (long)thrteenDigitIntTimeStamp];
    XCTAssertTrue([str length] == 13);
    
    NSNumber *tenDigitNumTimeStamp = [BOAUtilities get10DigitNumberObjTimeStamp];
    str = [NSString stringWithFormat:@"%@", tenDigitNumTimeStamp];
    XCTAssertTrue([str length] == 10);
    
    NSNumber *thrteenDigitsNumTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
    str = [NSString stringWithFormat:@"%@", thrteenDigitsNumTimeStamp];
    XCTAssertTrue([str length] == 13);
    
    NSInteger thrteenDigitsIntTimeStamp = [BOAUtilities get13DigitIntegerTimeStamp];
    str = [NSString stringWithFormat:@"%ld", (long)thrteenDigitsIntTimeStamp];
    XCTAssertTrue([str length] == 13);
}

-(void)testGetDayMonthYearFromDate {
    NSDate *date = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *dateString = @"2020-09-15";
    
    NSInteger day = [BOAUtilities getDayFromDateString:dateString inFormat:@"yyyy-MM-dd"];
    XCTAssertEqual(day, 15);
    
    day = [BOAUtilities getDayFromDate:date];
    XCTAssertEqual(day, 15);
    
    day = [BOAUtilities getDayFromTodayDate];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd"];
    NSString *dayString = [df stringFromDate:[NSDate date]];
    XCTAssertEqual(day, [dayString intValue]);
    
    NSInteger month = [BOAUtilities getMonthFromDateString:dateString inFormat:@"yyyy-MM-dd"];
    XCTAssertEqual(month, 9);
    
    month = [BOAUtilities getMonthFromDate:date];
    XCTAssertEqual(month, 9);
    
    month = [BOAUtilities getMonthFromTodayDate];
    [df setDateFormat:@"MM"];
    NSString *monthString = [df stringFromDate:[NSDate date]];
    XCTAssertEqual(month, [monthString intValue]);
    
    NSInteger year = [BOAUtilities getYearFromDateString:dateString inFormat:@"yyyy-MM-dd"];
    XCTAssertEqual(year, 2020);
    
    year = [BOAUtilities getYearFromDate:date];
    XCTAssertEqual(year, 2020);
    
    year = [BOAUtilities getYearFromTodayDate];
    [df setDateFormat:@"yyyy"];
    NSString *yearString = [df stringFromDate:[NSDate date]];
    XCTAssertEqual(year, [yearString intValue]);
}

-(void)testDateConversionMethods{
    NSDate *date = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSString *convertedDate = [BOAUtilities convertDate:date inFormat:@"EE"];
    NSString *strDay = [NSString stringWithFormat:@"Tue"];
    XCTAssertEqual(convertedDate, strDay);
    
    NSString *dateString = @"1604388636629";
    convertedDate = [BOAUtilities convertDateStr:dateString inFormat:@"epoc"];
    XCTAssertEqual(dateString, dateString);
    
    NSDate *dateInReqFormat = [BOAUtilities date:date inFormat:@"dd/MM/yy"];
    XCTAssertNotNil(dateInReqFormat);
    
    
    dateInReqFormat = [BOAUtilities dateInFormat:@"dd/MM/yy"];
    XCTAssertNotNil(dateInReqFormat);
    
    NSString *dateInStrFormat = [BOAUtilities dateStringInFormat:@"dd/MM/yy"];
    XCTAssertNotNil(dateInStrFormat);
}

-(void)testGetTimeIntervalSicne1970OfDate{
    NSDate *date = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSTimeInterval interval = [BOAUtilities getTimeIntervalSicne1970OfDate:date];
    XCTAssertEqual(interval, 1600153240.2);
}

-(void)testGetTimeIntervalSicneReferenceDate {
    NSTimeInterval interval = [BOAUtilities getTimeIntervalSicneReferenceDate];
    XCTAssertGreaterThan(interval, 0);
}

-(void)testGetTimeIntervalSicneReferenceDateOfDate {
    NSDate *date = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSTimeInterval interval = [BOAUtilities getTimeIntervalSicneReferenceDateOfDate:date];
    XCTAssertGreaterThan(interval, 0);
}

-(void)testRandomFloatAndIntGeneration{
    float randomFloat = [BOAUtilities randomFloatBetween:1.25 and:2.00];
    XCTAssertGreaterThan(randomFloat, 1.25);
    XCTAssertLessThan(randomFloat, 2.00);
    
    float randomInt = [BOAUtilities randomIntBetween:5 and:10];
    XCTAssertEqual(randomInt, 5);
    
    NSString *strNo = [BOAUtilities generateRandomNumber:5];
    XCTAssertEqual([strNo length], 5);
    
    NSString *uuid = [BOAUtilities getUUIDStringFromString:@"blotoutanalytics"];
    XCTAssertNotNil(uuid);
    
    uuid = [BOAUtilities getUUIDStringFromString:@"b"];
    XCTAssertNotNil(uuid);
    
}

-(void)testConvertTo64CharUUID{
    NSString *uuid = [BOAUtilities convertTo64CharUUID:@"abfdfredskdfredk"];
    XCTAssertNotNil(uuid);
}

-(void)testIsDatelessThanEqualTo{
    NSDate *date1 = [BOAUtilities dateStr:@"2020-09-15T12:30:40.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date2 = [BOAUtilities dateStr:@"2020-09-15T12:30:41.200Z" inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    BOOL status = [BOAUtilities isDate:date1 lessThanEqualTo:date2];
    XCTAssertTrue(status, @"Couldn't find date is under in given month");
    
}




@end
