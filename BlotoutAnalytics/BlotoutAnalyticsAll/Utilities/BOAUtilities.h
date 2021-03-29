//
//  BOAUtilities.h
//  BlotoutAnalytics
//
//  Created by Blotout on 22/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOAUtilities : NSObject

+(NSString*)jsonStringFrom:(NSDictionary*)dictObject withPrettyPrint:(BOOL) prettyPrint;
+(NSData*)jsonDataFrom:(NSDictionary*)dictObject withPrettyPrint:(BOOL) prettyPrint;
+(id)jsonObjectFromString:(NSString*)jsonString;
+(id)jsonObjectFromData:(NSData*)jsonData;

+(NSDate*)getCurrentDate;
+(NSDate*)getDateWithTimeInterval:(NSTimeInterval)timeInterval sinceDate:(NSDate*)referenceDate;
+(NSDate*)getDateWithTimeInterval:(NSTimeInterval)timeInterval;

//timeIntervalSince1970 is the number of seconds since January, 1st, 1970, 12:00 am (mid night)
+(NSTimeInterval)getTimeIntervalSicne1970OfDate:(NSDate*)referenceDate;
//timeIntervalSinceReferenceDate is the number of seconds since January, 1st, 2001: 12:00 am (mid night)
+(NSTimeInterval)getTimeIntervalSicneReferenceDate;
+(NSTimeInterval)getTimeIntervalSicneReferenceDateOfDate:(NSDate*)referenceDate;
//timeIntervalSinceNow is the number of seconds since now
+(NSTimeInterval)getTimeIntervalSicneNowOfDate:(NSDate*)referenceDate;

+(NSTimeInterval)milliSecondsIntervalBetween:(NSDate*)date1 andDate2:(NSDate*)date2;
+(NSUInteger)secondsIntervalBetween:(NSDate*)date1 andDate2:(NSDate*)date2;
+(NSNumber*)roundOffTimeStamp:(NSNumber*)timeStamp;
+(int)getCurrentTimezoneOffsetInMin;
+(int)getCurrentTimezoneOffsetInMin:(NSTimeZone*)timeZone;

//Reference date is 1 Jan 1970 UTC time as per apple guidelines and if date is nil then current date time is used as default
+(NSNumber*)get13DigitNumberObjTimeStampFor:(NSDate*)date;
+(NSInteger)get13DigitIntegerTimeStampFor:(NSDate*)date;

+(NSNumber*)get13DigitNumberObjTimeStamp;
+(NSInteger)get13DigitIntegerTimeStamp;

+(NSInteger)getDayFromDateString:(NSString*)dateString inFormat:(NSString*)format;
+(NSInteger)getDayFromDate:(NSDate*)date;
+(NSInteger)getDayFromTodayDate;

+(NSInteger)getMonthFromDateString:(NSString*)dateString inFormat:(NSString*)format;
+(NSInteger)getMonthFromDate:(NSDate*)date;
+(NSInteger)getMonthFromTodayDate;

+(NSInteger)getYearFromDateString:(NSString*)dateString inFormat:(NSString*)format;
+(NSInteger)getYearFromDate:(NSDate*)date;
+(NSInteger)getYearFromTodayDate;

+(NSString*)convertDate:(nonnull NSDate*)date inFormat:(nullable NSString*)dateFormat;
+(NSString*)convertDateStr:(nonnull NSString*)dateStr inFormat:(nullable NSString*)dateFormat;

+(NSDate*)date:(nonnull NSDate*)date inFormat:(nullable NSString*)dateFormat;
+(NSDate*)dateStr:(nonnull NSString*)dateStr inFormat:(nullable NSString*)dateFormat;

+(NSDate*)dateInFormat:(nonnull NSString*)dateFormat;
+(NSString*)dateStringInFormat:(nullable NSString*)dateFormat;

+(BOOL)isDate:(NSDate*)date1 greaterThan:(NSDate*)date2;
+(BOOL)isDate:(NSDate*)date1 greaterThanEqualTo:(NSDate*)date2;
+(BOOL)isDate:(NSDate*)date1 lessThan:(NSDate*)date2;
+(BOOL)isDate:(NSDate*)date1 lessThanEqualTo:(NSDate*)date2;
+(BOOL)isDate:(NSDate*)date1 equalTo:(NSDate*)date2;
//Comparision includes graterThanEqualTo date1 and lessThanEqualTo date2
+(BOOL)isDate:(NSDate*)testDate between:(NSDate*)date1 andDate2:(NSDate*)date2;

+(NSInteger)weekStartDay;
+(NSInteger)weekEndDay;
+(NSInteger)weekOfMonth;
+(NSInteger)weekOfYear;
+(NSInteger)weekOfYearForDate:(NSDate*)date;
+(NSInteger)weekOfYearForDateInterval:(NSTimeInterval)dateInterval;
+(NSInteger)monthStartDay;
+(NSInteger)monthEndDay;
+(NSInteger)monthOfYearForDate:(NSDate*)date;
+(NSInteger)monthOfYearForDateInterval:(NSTimeInterval)dateInterval;
+(NSInteger)monthLength;

+(BOOL)isDate:(NSDate*)date underWeek:(NSInteger)weekOfMonth;
+(BOOL)isDate:(NSDate*)date underWeekOfYear:(NSInteger)weekOfYear;
+(BOOL)isDate:(NSDate*)date underMonth:(NSInteger)monthOfYear;

+(BOOL)isDaySameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2;
+(BOOL)isWeekSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2;
+(BOOL)isMonthSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2;
+(BOOL)isYearSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2;
+(BOOL)isMonthAndYearSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2;
+(BOOL)isMonthAndYearSameOfDate:(NSDate*)date1 andDateStr:(NSString*)date2Str inFormat:(NSString*)format;
+(BOOL)isDayMonthAndYearSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2;
+(BOOL)isDayMonthAndYearSameOfDate:(NSString*)date1Str andDate2:(NSString*)date2Str inFomrat:(NSString*)format;
+(BOOL)isDayMonthAndYearSameOfDate:(NSDate*)date1 andDateStr:(NSString*)date2Str inFomrat:(NSString*)format;

+(NSArray<NSDate*>*)getAllDatesBetween:(NSDate*)startDate andDate2:(NSDate*)endDate;
+(NSDate*)getDateGreaterThan:(NSDate*)date;
+(NSDate*)getDateLessThan:(NSDate*)date;
+(NSDate*)getPreviousDayDateFrom:(NSDate*)date;
+(NSDate*)getPreviousDayDateFrom:(NSString*)dateStr inFormat:(NSString*)dateFormat;
+(NSString*)getPreviousDayDateInFormat:(NSString*)dateFormat fromReferenceDate:(NSDate*)referenceDate;

//=============================================== other utility methods =====================================
+(NSString*)md5HashOfString:(NSString*)strToHash;
+(NSData*)md5CharDataOfString:(NSString*)strToHash;
+(int)intValueForChar:(char)sChar;
+(BOOL)isNumberChar:(char)sChar;
+(int)getAsciiSum:(NSString*)input usingCaseSenstive:(BOOL)isCaseSenstive;
+(int)getAsciiCustomIntSum:(NSString*)input usingCaseSenstive:(BOOL)isCaseSenstive;

+(NSString*)getMessageIDForEvent:(NSString*)eventName;
+(NSNumber*)codeForCustomCodifiedEvent:(NSString*)eventName;

+(int)currentPlatformCode;

+(NSString*)getDeviceId;
+(NSString *)getUUIDString;

+(UIViewController *)topViewController:(UIViewController *)rootViewController;

+(NSString*)convertTo64CharUUID:(NSString*)stringToConvert;
+(NSString *)generateRandomNumber:(int)len;
+(NSString *)getUUIDStringFromString:(NSString *)uuidStr;

+ (NSString *)systemName;
+ (NSString *)systemVersion;
+ (NSString *)deviceModel;
+ (NSNumber *)getUserBirthTimeStamp;
+ (NSData *_Nullable)dataFromPlist:(nonnull id)plist;
+ (id _Nullable)plistFromData:(NSData *_Nonnull)data;
+(NSString*)getIDFA;
+(BOOL)getAdTrackingEnabled;

@end

NS_ASSUME_NONNULL_END
