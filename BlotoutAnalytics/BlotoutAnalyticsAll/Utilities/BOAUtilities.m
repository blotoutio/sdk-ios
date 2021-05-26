//
//  BOAUtilities.m
//  BlotoutAnalytics
//
//  Created by Blotout on 22/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAUtilities.h"
#import <CommonCrypto/CommonDigest.h>
#import "BOANetworkConstants.h"
#import "BOAConstants.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import <BlotoutFoundation/BOFLogs.h>
#import <UIKit/UIKit.h>
#import "BOASDKManifestController.h"
#import "BlotoutAnalytics_Internal.h"
#import <BlotoutFoundation/BOFUtilities.h>

@implementation BOAUtilities

+(NSString*)jsonStringFrom:(NSDictionary*)dictObject withPrettyPrint:(BOOL) prettyPrint {
    @try {
        if (dictObject && (dictObject.allKeys.count > 0)) {
            NSError *error;
            NSData *jsonData = dictObject ? [NSJSONSerialization dataWithJSONObject:dictObject
                                                                            options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                                              error:&error] : nil;
            
            if (! jsonData) {
                BOFLogDebug(@"%s: error: %@", __func__, error.localizedDescription);
                return nil;
            } else {
                return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSData*)jsonDataFrom:(NSDictionary*)dictObject withPrettyPrint:(BOOL) prettyPrint {
    @try {
        if (dictObject && (dictObject.allKeys.count > 0)) {
            NSError *error;
            NSData *jsonData = dictObject ? [NSJSONSerialization dataWithJSONObject:dictObject
                                                                            options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                                              error:&error] : nil;
            
            if (! jsonData) {
                BOFLogDebug(@"%s: error: %@", __func__, error.localizedDescription);
                return nil;
            } else {
                return jsonData;
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)jsonObjectFromString:(NSString*)jsonString{
    @try {
        if (jsonString) {
            NSError *error = nil;
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            id json = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error] : nil;
            return error ? nil : json;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)jsonObjectFromData:(NSData*)jsonData{
    @try {
        if (jsonData) {
            NSError *error = nil;
            id json = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil] : nil;
            return error ? nil : json;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * Gets current date
 *
 * @return: current date object
 */
+(NSDate*)getCurrentDate{
    @try {
        return [NSDate date];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDate*)getDateWithTimeInterval:(NSTimeInterval)timeInterval sinceDate:(NSDate*)referenceDate{
    @try {
        return [NSDate dateWithTimeInterval:timeInterval sinceDate:referenceDate];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDate*)getDateWithTimeInterval:(NSTimeInterval)timeInterval{
    @try {
        int dateIntervalL = timeInterval / 1000;
        return [NSDate dateWithTimeIntervalSince1970:dateIntervalL];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
//timeIntervalSince1970 is the number of seconds since January, 1st, 1970, 12:00 am (mid night)
+(NSTimeInterval)getTimeIntervalSicne1970OfDate:(NSDate*)referenceDate;{
    @try {
        return [referenceDate timeIntervalSince1970];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

//timeIntervalSinceReferenceDate is the number of seconds since January, 1st, 2001: 12:00 am (mid night)
+(NSTimeInterval)getTimeIntervalSicneReferenceDate{
    @try {
        return [NSDate timeIntervalSinceReferenceDate];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSTimeInterval)getTimeIntervalSicneReferenceDateOfDate:(NSDate*)referenceDate{
    @try {
        return [referenceDate timeIntervalSinceReferenceDate];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

//timeIntervalSinceNow is the number of seconds since now
+(NSTimeInterval)getTimeIntervalSicneNowOfDate:(NSDate*)referenceDate{
    @try {
        return [referenceDate timeIntervalSinceNow];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSTimeInterval)milliSecondsIntervalBetween:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        return [date2 timeIntervalSinceDate:date1];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSUInteger)secondsIntervalBetween:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        return (NSUInteger)([date2 timeIntervalSinceDate:date1]*1000);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSNumber*)roundOffTimeStamp:(NSNumber*)timeStamp{
    @try {
        if(timeStamp !=nil && timeStamp.integerValue <= 0) {
            return 0;
        }
        if([[BOASDKManifestController sharedInstance] sdkMapUserId]) {
            return timeStamp;
        }
        
        int dateIntervalL = [timeStamp doubleValue] / 1000;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateIntervalL];
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate: date];
        if(dateComponents.minute <= 58) {
            dateComponents.minute = 0;
            dateComponents.second = 0;
        } else {
            dateComponents.hour = dateComponents.hour + 1;
            dateComponents.minute = 0;
            dateComponents.second = 0;
        }
        NSDate *finalDate = [calendar dateFromComponents:dateComponents];
        NSNumber *millis = [BOAUtilities get13DigitNumberObjTimeStampFor:finalDate];
        return millis;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(int)getCurrentTimezoneOffsetInMin {
    @try {
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        NSInteger seconds = [timeZone secondsFromGMT];
        int offset = (int)seconds / 60;
        return offset;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.debugDescription);
    }
    return 0;
}

+(int)getCurrentTimezoneOffsetInMin:(NSTimeZone*)timeZone {
    @try {
        NSInteger seconds = [timeZone secondsFromGMT];
        int offset = (int)seconds / 60;
        return offset;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.debugDescription);
    }
    return 0;
}

//public static int getCurrentTimezoneOffsetInMin(TimeZone timeZOne) {
//       try {
//           Date now = new Date();
//           return timeZOne.getOffset(now.getTime()) / (1000 * 60);
//       } catch (Exception e) {
//           Logger.INSTANCE.e(TAG, e.getMessage());
//           return 0;
//       }
//   }

+(NSNumber*)get10DigitNumberObjTimeStampFor:(NSDate*)date{
    @try {
        NSDate *dateL = date ?  date : [NSDate date];
        NSInteger timeStamp = (NSInteger)([dateL timeIntervalSinceReferenceDate]);
        NSNumber *timeStampObj = [NSNumber numberWithInteger:timeStamp];
        return timeStampObj;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSInteger)get10DigitIntegerTimeStampFor:(NSDate*)date{
    @try {
        NSDate *dateL = date ?  date : [NSDate date];
        NSInteger timeStamp = (NSInteger)([dateL timeIntervalSince1970]);
        return timeStamp;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSNumber*)get13DigitNumberObjTimeStampFor:(NSDate*)date{
    @try {
        NSDate *dateL = date ?  date : [NSDate date];
        NSInteger timeStamp = (NSInteger)([dateL timeIntervalSince1970] * 1000);
        NSNumber *timeStampObj = [NSNumber numberWithInteger:timeStamp];
        return timeStampObj;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSInteger)get13DigitIntegerTimeStampFor:(NSDate*)date{
    @try {
        NSDate *dateL = date ?  date : [NSDate date];
        NSInteger timeStamp = (NSInteger)([dateL timeIntervalSince1970] * 1000);
        return timeStamp;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSNumber*)get10DigitNumberObjTimeStamp{
    @try {
        NSInteger timeStamp = (NSInteger)([[NSDate date] timeIntervalSince1970]);
        NSNumber *timeStampObj = [NSNumber numberWithInteger:timeStamp];
        return timeStampObj;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSInteger)get10DigitIntegerTimeStamp{
    @try {
        NSInteger timeStamp = (NSInteger)([[NSDate date] timeIntervalSince1970]);
        return timeStamp;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSNumber*)get13DigitNumberObjTimeStamp{
    @try {
        NSInteger timeStamp = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
        NSNumber *timeStampObj = [NSNumber numberWithInteger:timeStamp];
        return timeStampObj;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSInteger)get13DigitIntegerTimeStamp{
    @try {
        NSInteger timeStamp = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
        return timeStamp;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)getDayFromDateString:(NSString*)dateString inFormat:(NSString*)format {
    @try {
        NSString *dateFormat = format ? format : @"yyyy-MM-dd";
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat]; //yyyy-MM-dd //MM-dd-yyyy
        
        NSDate *date = [dateFormatter dateFromString:dateString];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitDay | NSCalendarUnitWeekday fromDate: date];
        
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.weekday); // Day in week: 3
        BOFLogDebug(@"Day in month: %ld", (long)dateComponents.day);    // Day in month: 25
        
        return dateComponents.day;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(long)getDayFromDate:(NSDate*)date{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitDay | NSCalendarUnitWeekday fromDate: date];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.weekday); // Day in week: 3
        BOFLogDebug(@"Day in month: %ld", (long)dateComponents.day);    // Day in month: 25
        return dateComponents.day;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(long)getDayFromTodayDate{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitDay | NSCalendarUnitWeekday fromDate: [NSDate date]];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.weekday); // Day in week: 3
        BOFLogDebug(@"Day in month: %ld", (long)dateComponents.day);    // Day in month: 25
        return dateComponents.day;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(long)getMonthFromDateString:(NSString*)dateString inFormat:(NSString*)format{
    @try {
        NSString *dateFormat = format ? format : @"yyyy-MM-dd";
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat]; //yyyy-MM-dd //MM-dd-yyyy
        NSDate *date = [dateFormatter dateFromString:dateString];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitMonth fromDate: date];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.month); // Day in week: 3
        return dateComponents.month;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(long)getMonthFromDate:(NSDate*)date{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitMonth fromDate: date];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.month); // Day in week: 3
        return dateComponents.month;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(long)getMonthFromTodayDate{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitMonth fromDate: [NSDate date]];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.month); // Day in week: 3
        return dateComponents.month;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(long)getYearFromDateString:(NSString*)dateString inFormat:(NSString*)format{
    @try {
        NSString *dateFormat = format ? format : @"yyyy-MM-dd";
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat]; //yyyy-MM-dd //MM-dd-yyyy
        NSDate *date = [dateFormatter dateFromString:dateString];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitYear fromDate: date];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.year); // Day in week: 3
        return dateComponents.year;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(long)getYearFromDate:(NSDate*)date{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitYear fromDate: date];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.year); // Day in week: 3
        return dateComponents.year;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(long)getYearFromTodayDate{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitYear fromDate: [NSDate date]];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.year); // Day in week: 3
        return dateComponents.year;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}


+(NSString*)convertDate:(nonnull NSDate*)date inFormat:(nullable NSString*)dateFormat{
    @try {
        if (!date) {
            return nil;
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFomratL = dateFormat ? dateFormat : @"yyyy-MM-dd";
        [dateFormatter setDateFormat:dateFomratL];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)convertDateStr:(nonnull NSString*)dateStr inFormat:(nullable NSString*)dateFormat{
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFomratL = dateFormat ? dateFormat : @"yyyy-MM-dd";
        
        NSTimeInterval dateInterVal = 0;
        int dateInterValInt = 0;
        if ([dateFomratL isEqualToString:@"epoc"]) {
            dateInterVal = [dateStr doubleValue];
            if (dateStr.length == 13) {
                dateInterValInt = dateInterVal / 1000;
            }else{
                dateInterValInt = dateInterVal;
            }
            dateFomratL = @"yyyy-MM-dd";
            dateStr = [NSString stringWithFormat:@"%d",dateInterValInt];
        }else if(dateStr.length == 13){
            dateInterVal = [dateStr doubleValue];
            dateInterValInt = dateInterVal / 1000;
            dateStr = [NSString stringWithFormat:@"%d",dateInterValInt];
        }
        
        [dateFormatter setDateFormat:dateFomratL];
        NSDate *date  = [dateFormatter dateFromString:dateStr];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDate*)date:(nonnull NSDate*)date inFormat:(nullable NSString*)dateFormat{
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFomratL = dateFormat ? dateFormat : @"yyyy-MM-dd";
        [dateFormatter setDateFormat:dateFomratL];
        NSString *dateStr = [dateFormatter stringFromDate:date];
        NSDate *dateL  = [dateFormatter dateFromString:dateStr];
        return dateL;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDate*)dateStr:(nonnull NSString*)dateStr inFormat:(nullable NSString*)dateFormat{
    @try {
        if (dateStr && ![dateStr isEqualToString:@""]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSString *dateFomratL = dateFormat ? dateFormat : @"yyyy-MM-dd";
            [dateFormatter setDateFormat:dateFomratL];
            NSDate *dateL  = [dateFormatter dateFromString:dateStr];
            return dateL;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDate*)dateInFormat:(nonnull NSString*)dateFormat{
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFomratL = dateFormat ? dateFormat : @"yyyy-MM-dd";
        [dateFormatter setDateFormat:dateFomratL];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        NSDate *dateL  = [dateFormatter dateFromString:dateStr];
        return dateL;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)dateStringInFormat:(nullable NSString*)dateFormat{
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFomratL = dateFormat ? dateFormat : @"yyyy-MM-dd";
        [dateFormatter setDateFormat:dateFomratL];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        return dateStr;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(BOOL)isDate:(NSDate*)date1 greaterThan:(NSDate*)date2{
    @try {
        NSComparisonResult resut = [date2 compare:date1];
        if (resut == NSOrderedAscending) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}
+(BOOL)isDate:(NSDate*)date1 greaterThanEqualTo:(NSDate*)date2{
    @try {
        NSComparisonResult resut = [date2 compare:date1];
        if ((resut == NSOrderedAscending) || (resut == NSOrderedSame)) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}
+(BOOL)isDate:(NSDate*)date1 lessThan:(NSDate*)date2{
    @try {
        NSComparisonResult resut = [date2 compare:date1];
        if (resut == NSOrderedDescending) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isDate:(NSDate*)date1 lessThanEqualTo:(NSDate*)date2{
    @try {
        NSComparisonResult resut = [date2 compare:date1];
        if ((resut == NSOrderedDescending) || (resut == NSOrderedSame)) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isDate:(NSDate*)date1 equalTo:(NSDate*)date2{
    @try {
        NSComparisonResult resut = [date2 compare:date1];
        if (resut == NSOrderedSame) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isDate:(NSDate*)testDate between:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        BOOL result1 = [self isDate:testDate greaterThanEqualTo:date1];
        BOOL result2 = [self isDate:testDate lessThanEqualTo:date2];
        return (result1 && result2);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(NSInteger)weekStartDay{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitDay | NSCalendarUnitWeekday fromDate: [NSDate date]];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.weekday); // Day in week: 3
        BOFLogDebug(@"Day in month: %ld", (long)dateComponents.day);    // Day in month: 25
        NSInteger weekStartDay = dateComponents.day - (dateComponents.weekday - 1);
        return weekStartDay;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)weekEndDay{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitDay | NSCalendarUnitWeekday fromDate: [NSDate date]];
        BOFLogDebug(@"Day in week: %ld", (long)dateComponents.weekday); // Day in week: 3
        BOFLogDebug(@"Day in month: %ld", (long)dateComponents.day);    // Day in month: 25
        NSInteger weekStartDay = dateComponents.day + (7 - dateComponents.weekday);
        return weekStartDay;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)weekOfMonth{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth fromDate: [NSDate date]];
        return dateComponents.weekOfMonth;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)weekOfYear{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate: [NSDate date]];
        return dateComponents.weekOfYear;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)weekOfYearForDate:(NSDate*)date{
    @try {
        if (date) {
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * dateComponents = [calendar components: NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:date];
            return dateComponents.weekOfYear;
        }
        return 0;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)weekOfYearForDateInterval:(NSTimeInterval)dateInterval{
    @try {
        if (dateInterval > 0) {
            int dateIntervalL = dateInterval / 1000;
            NSDate *dateObj = [NSDate dateWithTimeIntervalSince1970:dateIntervalL];
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * dateComponents = [calendar components: NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:dateObj];
            return dateComponents.weekOfYear;
        }
        return 0;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)monthStartDay{
    return 1;
}

+(NSInteger)monthEndDay{
    @try {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
        NSUInteger numberOfDaysInMonth = range.length;
        return numberOfDaysInMonth;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)monthOfYearForDate:(NSDate*)date{
    @try {
        if (date) {
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * dateComponents = [calendar components: NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth fromDate:date];
            return dateComponents.month;
        }
        return 0;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)monthOfYearForDateInterval:(NSTimeInterval)dateInterval{
    @try {
        if (dateInterval > 0) {
            int dateIntervalL = dateInterval / 1000;
            NSDate *dateObj = [NSDate dateWithTimeIntervalSince1970:dateIntervalL];
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * dateComponents = [calendar components: NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth fromDate:dateObj];
            return dateComponents.month;
        }
        return 0;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSInteger)monthLength{
    @try {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
        NSUInteger numberOfDaysInMonth = range.length;
        return numberOfDaysInMonth;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(BOOL)isDate:(NSDate*)date underWeek:(NSInteger)weekOfMonth{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitWeekOfMonth fromDate: date];
        return (dateComponents.weekOfMonth == weekOfMonth);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isDate:(NSDate*)date underWeekOfYear:(NSInteger)weekOfYear{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitWeekOfYear fromDate: date];
        return (dateComponents.weekOfYear == weekOfYear);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}
+(BOOL)isDate:(NSDate*)date underMonth:(NSInteger)monthOfYear{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitMonth fromDate: date];
        return (dateComponents.month == monthOfYear);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}


+(BOOL)isDaySameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents1 = [calendar components: NSCalendarUnitDay fromDate: date1];
        NSDateComponents * dateComponents2 = [calendar components: NSCalendarUnitDay fromDate: date2];
        return (dateComponents1.day == dateComponents2.day);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isWeekSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents1 = [calendar components: NSCalendarUnitWeekOfYear fromDate: date1];
        NSDateComponents * dateComponents2 = [calendar components: NSCalendarUnitWeekOfYear fromDate: date2];
        return (dateComponents1.weekOfYear == dateComponents2.weekOfYear);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isMonthSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        if (date1 && date2) {
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * dateComponents1 = [calendar components: NSCalendarUnitMonth fromDate: date1];
            NSDateComponents * dateComponents2 = [calendar components: NSCalendarUnitMonth fromDate: date2];
            return (dateComponents1.month == dateComponents2.month);
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isYearSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents1 = [calendar components: NSCalendarUnitYear fromDate: date1];
        NSDateComponents * dateComponents2 = [calendar components: NSCalendarUnitYear fromDate: date2];
        return (dateComponents1.year == dateComponents2.year);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isMonthAndYearSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents1 = [calendar components: NSCalendarUnitMonth | NSCalendarUnitYear fromDate: date1];
        NSDateComponents * dateComponents2 = [calendar components: NSCalendarUnitMonth | NSCalendarUnitYear fromDate: date2];
        return ((dateComponents1.month == dateComponents2.month) && (dateComponents1.year == dateComponents2.year));
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isMonthAndYearSameOfDate:(NSDate*)date1 andDateStr:(NSString*)date2Str inFormat:(NSString*)format{
    @try {
        if (format && date1 && date2Str && ![date2Str isEqualToString:@""]) {
            NSDate *date2 = [self dateStr:date2Str inFormat:format];
            return [self isMonthAndYearSameOfDate:date1 andDate2:date2];
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isDayMonthAndYearSameOfDate:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        if (date1 && date2) {
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * dateComponents1 = [calendar components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: date1];
            NSDateComponents * dateComponents2 = [calendar components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: date2];
            return ((dateComponents1.day == dateComponents2.day) && (dateComponents1.month == dateComponents2.month) && (dateComponents1.year == dateComponents2.year));
        }else{
            return NO;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isDayMonthAndYearSameOfDate:(NSString*)date1Str andDate2:(NSString*)date2Str inFomrat:(NSString*)format{
    @try {
        if (format && date1Str && ![date1Str isEqualToString:@""] && date2Str && ![date2Str isEqualToString:@""]) {
            NSDate *date1 = [self dateStr:date1Str inFormat:format];
            NSDate *date2 = [self dateStr:date2Str inFormat:format];
            
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * dateComponents1 = [calendar components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: date1];
            NSDateComponents * dateComponents2 = [calendar components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: date2];
            return ((dateComponents1.day == dateComponents2.day) && (dateComponents1.month == dateComponents2.month) && (dateComponents1.year == dateComponents2.year));
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isDayMonthAndYearSameOfDate:(NSDate*)date1 andDateStr:(NSString*)date2Str inFomrat:(NSString*)format{
    @try {
        //TODO: IMP: Check on day change, once received [date2Str isEqualToString:@""] as [NSNull isEqualToString:@""] exception
        //FOUND reason: mention in BOAEvents initSuccessForAppDailySession on day change, which will keep causing,
        //now trying to fix
        if (format && date1 && ![date1 isEqual:NSNull.null] && date2Str && ![date2Str isEqual:NSNull.null] && ![date2Str isEqualToString:@""]) {
            NSDate *date2 = [self dateStr:date2Str inFormat:format];
            if (date2) {
                NSCalendar * calendar = [NSCalendar currentCalendar];
                NSDateComponents * dateComponents1 = [calendar components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: date1];
                NSDateComponents * dateComponents2 = [calendar components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: date2];
                return ((dateComponents1.day == dateComponents2.day) && (dateComponents1.month == dateComponents2.month) && (dateComponents1.year == dateComponents2.year));
            }
            return NO;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}


+(NSArray<NSDate*>*)getAllDatesBetween:(NSDate*)startDate andDate2:(NSDate*)endDate{
    @try {
        //NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
        NSMutableArray *dates = [NSMutableArray array];
        
        //NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSCalendar *gregorianCalendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        
        for (int i = 1; i < components.day; ++i) {
            NSDateComponents *newComponents = [NSDateComponents new];
            newComponents.day = i;
            
            NSDate *date = [gregorianCalendar dateByAddingComponents:newComponents
                                                              toDate:startDate
                                                             options:0];
            [dates addObject:date];
        }
        return dates;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return  nil;
}

+(float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    @try {
        float diff = bigNumber - smallNumber;
        return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return smallNumber + 0.0;
}

+(float)randomIntBetween:(int)smallNumber and:(int)bigNumber {
    @try {
        int diff = bigNumber - smallNumber;
        return (((arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return smallNumber + 0;
}

+(NSDate*)getDateBetween:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        NSArray<NSDate*> *dates = [self getAllDatesBetween:date1 andDate2:date2];
        //int indexValue  = [self randomIntBetween:0 and:(dates.count-1)];
        return (dates.count > 0) ? [dates objectAtIndex:0] : nil; // can randomise if needed using indexValue
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDate*)getDateGreaterThan:(NSDate*)date{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitDay fromDate: date];
        dateComponents.day = dateComponents.day + 1;
        
        NSDate *newDate = [calendar dateByAddingComponents:dateComponents
                                                    toDate:date
                                                   options:0];
        
        return newDate;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
+(NSDate*)getDateLessThan:(NSDate*)date{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitDay fromDate: date];
        dateComponents.day = dateComponents.day - 1; // we can randomise this if needed using random number
        
        NSDate *newDate = [calendar dateByAddingComponents:dateComponents
                                                    toDate:date
                                                   options:0];
        
        return newDate;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}


+(NSDate*)getPreviousDayDateFrom:(NSDate*)date{
    @try {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * dateComponents = [calendar components: NSCalendarUnitDay fromDate: date];
        dateComponents.day = dateComponents.day - 1;
        
        NSDate *newDate = [calendar dateByAddingComponents:dateComponents
                                                    toDate:date
                                                   options:0];
        
        return newDate;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDate*)getPreviousDayDateFrom:(NSString*)dateStr inFormat:(NSString*)dateFormat{
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFomratL = dateFormat ? dateFormat : @"yyyy-MM-dd";
        [dateFormatter setDateFormat:dateFomratL];
        NSDate *referenceDate  = [dateFormatter dateFromString:dateStr];
        NSDate *previousDate = [self getPreviousDayDateFrom:referenceDate];
        return previousDate;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)getPreviousDayDateInFormat:(NSString*)dateFormat fromReferenceDate:(NSDate*)referenceDate{
    @try {
        NSDate *previousDate = [self getPreviousDayDateFrom:referenceDate];
        return [self convertDate:previousDate inFormat:dateFormat];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

//================================================ other utility methods ===============================
+(NSString*)md5HashOfString:(NSString*)strToHash{
    @try {
        // Create pointer to the string as UTF8
        const char *ptr = [strToHash UTF8String];
        // Create byte array of unsigned chars
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        // Create 16 byte MD5 hash value, store in buffer
        CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
        // Convert MD5 value in the buffer to NSString of hex values
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
        return output;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return  nil;
}

// returns, nsdata for actual md5 bytes not hex string
+(NSData*)md5CharDataOfString:(NSString*)strToHash{
    @try {
        // Create pointer to the string as UTF8
        const char *ptr = [strToHash UTF8String];
        // Create byte array of unsigned chars
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        // Create 16 byte MD5 hash value, store in buffer
        CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
        NSData *data = [NSData dataWithBytes:(const void *)md5Buffer length:sizeof(unsigned char)*CC_MD5_DIGEST_LENGTH];
        return data;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return  nil;
    
}

+(int)getAsciiSum:(NSString*)input usingCaseSenstive:(BOOL)isCaseSenstive
{
    @try {
        input = isCaseSenstive ? input : [input lowercaseString];
        int sum = 0;
        if ([input canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            for (NSInteger index = 0; index < input.length; index++)
            {
                char c = [input characterAtIndex:index];
                sum = sum + c;
            }
        }
        return sum;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(int)getHashIntSum:(NSString*)input {
    
    @try {
        input = [input lowercaseString];
        NSString *encoded = [BOFUtilities getSHA1:input];
        int sum = 0;
        for (int index = 0; index < encoded.length; index++) {
            char c = [encoded characterAtIndex:index];
            sum = sum + c;
        }
        return sum;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        return 0;
    }
}

+(int)getAsciiCustomIntSum:(NSString*)input usingCaseSenstive:(BOOL)isCaseSenstive
{
    @try {
        input = isCaseSenstive ? input : [input lowercaseString];
        int sum = 0;
        if ([input canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            for (NSInteger index = 0; index < input.length; index++)
            {
                char c = [input characterAtIndex:index];
                sum = sum + [self intValueForChar:c];
            }
        }
        return sum;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(int)getOnlyAsciiCharsCustomIntSumFromUnicode:(NSString *)input usingCaseSenstive:(BOOL)isCaseSenstive{
    @try {
        input = isCaseSenstive ? input : [input lowercaseString];
        int sum = 0;
        for (NSInteger index = 0; index < input.length; index++)
        {
            char c = [input characterAtIndex:index];
            sum = sum + [self intValueForChar:c];
        }
        return sum;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

//MD5 digest is 32 char long, 128 bit digest.
//If for example d54c and d5c4 happen at the begining and remaing string is same then sum will be same
//Which can lead to same event sub code for different name
+(int)getStringMD5CustomIntSum:(NSString*)input usingCaseSenstive:(BOOL)isCaseSenstive
{
    @try {
        input = isCaseSenstive ? input : [input lowercaseString];
        NSString *md5String = [self md5HashOfString:input];
        int sum = 0;
        for (NSInteger index = 0; index < md5String.length; index++)
        {
            char c = [md5String characterAtIndex:index];
            sum = sum + [self intValueForChar:c];
        }
        return sum;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

//Corner case might cause error at certain point
//If this d54c and d45c happen at the begining and remaining string is same then summation is same even string is different
+(int)getStringMD5CustomIntSumWithCharIndexAdded:(NSString*)input usingCaseSenstive:(BOOL)isCaseSenstive
{
    @try {
        input = isCaseSenstive ? input : [input lowercaseString];
        NSString *md5String = [self md5HashOfString:input];
        int sum = 0;
        for (int index = 0; index < md5String.length; index++)
        {
            char c = [md5String characterAtIndex:index];
            if ([self isNumberChar:c]) {
                sum = sum + [self intValueForChar:c];
            }else{
                sum = sum + [self intValueForChar:c] + index;
            }
        }
        return sum;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(BOOL)isNumberChar:(char)sChar{
    BOOL isNum = NO;
    
    switch (sChar) {
        case '0':
            isNum = YES;
            break;
        case '1':
            isNum = YES;
            break;
        case '2':
            isNum = YES;
            break;
        case '3':
            isNum = YES;
            break;
        case '4':
            isNum = YES;
            break;
        case '5':
            isNum = YES;
            break;
        case '6':
            isNum = YES;
            break;
        case '7':
            isNum = YES;
            break;
        case '8':
            isNum = YES;
            break;
        case '9':
            isNum = YES;
            break;
    }
    return isNum;
}

+(int)intValueForChar:(char)sChar{
    
    switch (sChar) {
        case '0':
            return 0;
            break;
        case '1':
            return 1;
            break;
        case '2':
            return 2;
            break;
        case '3':
            return 3;
            break;
        case '4':
            return 4;
            break;
        case '5':
            return 5;
            break;
        case '6':
            return 6;
            break;
        case '7':
            return 7;
            break;
        case '8':
            return 8;
            break;
        case '9':
            return 9;
            break;
        case ' ':
            return 10;
            break;
        case 'a':
            return 11;
            break;
        case 'b':
            return 12;
            break;
        case 'c':
            return 13;
            break;
        case 'd':
            return 14;
            break;
        case 'e':
            return 15;
            break;
        case 'f':
            return 16;
            break;
        case 'g':
            return 17;
            break;
        case 'h':
            return 18;
            break;
        case 'i':
            return 19;
            break;
        case 'j':
            return 20;
            break;
        case 'k':
            return 21;
            break;
        case 'l':
            return 22;
            break;
        case 'm':
            return 23;
            break;
        case 'n':
            return 24;
            break;
        case 'o':
            return 25;
            break;
        case 'p':
            return 26;
            break;
        case 'q':
            return 27;
            break;
        case 'r':
            return 28;
            break;
        case 's':
            return 29;
            break;
        case 't':
            return 30;
            break;
        case 'u':
            return 31;
            break;
        case 'v':
            return 32;
            break;
        case 'w':
            return 33;
            break;
        case 'x':
            return 34;
            break;
        case 'y':
            return 35;
            break;
        case 'z':
            return 36;
            break;
        case 'A':
            return 37;
            break;
        case 'B':
            return 38;
            break;
        case 'C':
            return 39;
            break;
        case 'D':
            return 40;
            break;
        case 'E':
            return 41;
            break;
        case 'F':
            return 42;
            break;
        case 'G':
            return 43;
            break;
        case 'H':
            return 44;
            break;
        case 'I':
            return 45;
            break;
        case 'J':
            return 46;
            break;
        case 'K':
            return 47;
            break;
        case 'L':
            return 48;
            break;
        case 'M':
            return 49;
            break;
        case 'N':
            return 50;
            break;
        case 'O':
            return 51;
            break;
        case 'P':
            return 52;
            break;
        case 'Q':
            return 53;
            break;
        case 'R':
            return 54;
            break;
        case 'S':
            return 55;
            break;
        case 'T':
            return 56;
            break;
        case 'U':
            return 57;
            break;
        case 'V':
            return 58;
            break;
        case 'W':
            return 59;
            break;
        case 'X':
            return 60;
            break;
        case 'Y':
            return 61;
            break;
        case 'Z':
            return 62;
            break;
        default:
            return (int)sChar;
            break;
    }
    return 0;
}

+(NSString*)generateMessageIDForEvent:(NSString*)eventName evnetCode:(NSString*)eventCode happenedAt:(NSNumber*)eventTime{
    @try {
        return [NSString stringWithFormat:@"%@-%@-%@-%ld",eventCode, [self codeForCustomCodifiedEvent:eventName], eventTime, (long)[self get13DigitIntegerTimeStamp]];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)getMessageIDForEvent:(NSString*)eventName andIdentifier:(NSNumber*)eventID{
    @try {
        return [NSString stringWithFormat:@"%@-%@-%@-%ld", eventID , [self codeForCustomCodifiedEvent:eventName],eventName, (long)[self get13DigitIntegerTimeStamp]];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)getMessageIDForEvent:(NSString*)eventName{
    @try {
        return [NSString stringWithFormat:@"%d-%@-%@-%ld",[self getAsciiCustomIntSum:eventName usingCaseSenstive:YES], [self codeForCustomCodifiedEvent:eventName], [self md5HashOfString:eventName], (long)[self get13DigitIntegerTimeStamp]];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSNumber*)codeForCustomCodifiedEvent:(NSString*)eventName{
    @try {
        //int devCustomEventLowerLimit = 21000;
        //int devCustomEventUpperLimit = 22000;
        //Below will make sure any length blank string is never treated as string and valid name
        NSString *tempEventName = [eventName stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (eventName && ![tempEventName isEqualToString:@""]) {
            BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
            NSMutableDictionary *allCustomEvents = [[analyticsRootUD objectForKey:BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS] mutableCopy];
            if (!allCustomEvents) {
                allCustomEvents = [NSMutableDictionary dictionary];
            }
            BOOL isNameFound = [[allCustomEvents allKeys] containsObject:eventName];
            if (isNameFound) {
                return [allCustomEvents objectForKey:eventName];
            }else{
                
                int eventNameIntSum  = [self getHashIntSum:eventName];
                //                if ([eventName canBeConvertedToEncoding:NSASCIIStringEncoding]) {
                //                    eventNameIntSum = [BOAUtilities getAsciiCustomIntSum:eventName usingCaseSenstive:NO];
                //                }else{
                //                    eventNameIntSum = [BOAUtilities getStringMD5CustomIntSumWithCharIndexAdded:eventName usingCaseSenstive:NO];
                //                }
                
                int eventNameIntSumModulo = eventNameIntSum % 8899; //as range is from 21100 - 29999
                int eventSubCode = BO_DEV_EVENT_CUSTOM_KEY + eventNameIntSumModulo; //21100
                NSNumber *eventSubCodeObj = [NSNumber numberWithInt:eventSubCode];
                
                while ([[allCustomEvents allValues] containsObject:eventSubCodeObj]) {
                    eventNameIntSum = eventNameIntSum + 1;
                    eventNameIntSumModulo = eventNameIntSum % 8899;
                    eventSubCode = BO_DEV_EVENT_CUSTOM_KEY + eventNameIntSumModulo; //21100
                    eventSubCodeObj = [NSNumber numberWithInt:eventSubCode];
                }
                [allCustomEvents setObject:eventSubCodeObj forKey:eventName];
                [analyticsRootUD setObject:allCustomEvents forKey:BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS];
                return eventSubCodeObj;
            }
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(int)currentPlatformCode{
    switch ([UIDevice currentDevice].userInterfaceIdiom) {
        case UIUserInterfaceIdiomPhone:
            return 14;
            break;
        case UIUserInterfaceIdiomPad:
            return 15;
            break;
        case UIUserInterfaceIdiomTV:
            return 18;
            break;
        case UIUserInterfaceIdiomCarPlay:
            return 60; //19; //Apple Watch
            break;
        case UIUserInterfaceIdiomUnspecified:
            return 60; //Common for All iOS Based- In case platform is unknow
            break;
        default:
            break;
    }
    return 0;
}

+(NSString*)getDeviceId {
    //user id generation update =
    //Epoc 13 Digit Time at start +
    // Client SDK Token + UUID generate once +
    // 10 digit random number+ 10 digit random number +
    // Epoc 13 Digit time at the end = Input for SHA 512 or UUID function in case it takes
    
    NSString* deviceId =@"";
    @try {
        
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        
        NSString *deviceUUID = [analyticsRootUD objectForKey: BO_ANALYTICS_USER_UNIQUE_KEY];
        if (deviceUUID != NULL && [deviceUUID length] > 0)  {
            deviceId = deviceUUID;
        } else {
            NSMutableString *stringBuilder =  [NSMutableString string];
            [stringBuilder appendFormat:@"%ldl",(long)[BOAUtilities get13DigitIntegerTimeStamp]];
            
            //SDK Key
            //                 NSString *key = [BlotoutAnalytics sharedInstance].prodBlotoutKey != nil ? [BlotoutAnalytics sharedInstance].prodBlotoutKey : [BlotoutAnalytics sharedInstance].testBlotoutKey;
            //                 [stringBuilder appendString:key];
            [stringBuilder appendString:[BOAUtilities getUUIDString]];
            [stringBuilder appendString:[BOAUtilities generateRandomNumber:10]];
            [stringBuilder appendString:[BOAUtilities generateRandomNumber:10]];
            [stringBuilder appendFormat:@"%ldl",(long)[BOAUtilities get13DigitIntegerTimeStamp]];
            //deviceId = [BOAUtilities getUUIDStringFromString:stringBuilder];
            NSString *guidString = [BOAUtilities convertTo64CharUUID:[BOFUtilities getSHA256:stringBuilder]];
            deviceId = guidString != nil ? guidString : [BOAUtilities getUUIDStringFromString:stringBuilder];
            deviceId = deviceId != nil ? deviceId : [BOAUtilities getUUIDString];
            [analyticsRootUD setObject: deviceId forKey: BO_ANALYTICS_USER_UNIQUE_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
    }  @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    
    [BlotoutFoundation sharedInstance].encryptionKey = deviceId;
    
    return deviceId;
}

+(NSString*)convertTo64CharUUID:(NSString*)stringToConvert {
    @try {
        if(stringToConvert != nil && stringToConvert.length >0) {
            NSString *str = stringToConvert;
            NSArray *lengths = @[@(16), @(8), @(8), @(8), @(24)];
            NSMutableArray *parts = [NSMutableArray array];
            int startRange = 0;
            
            for (int i = 0; i < lengths.count; i++) {
                NSRange range = NSMakeRange(startRange, [[lengths objectAtIndex:i] intValue]);
                NSString *stringOfRange = [str substringWithRange:range];
                [parts addObject:stringOfRange];
                startRange += [[lengths objectAtIndex:i] intValue];
            };
            NSString *uuid64Char = [parts componentsJoinedByString:@"-"];
            return uuid64Char;
        }
    }  @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        return stringToConvert;
    }
}

+ (NSString *)generateRandomNumber:(int)len {
    static NSString *letters = @"0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

+ (NSString *)getUUIDString {
    @try {
        NSUUID *uuid = [NSUUID UUID];
        NSString *uuidStr = [uuid UUIDString];
        return uuidStr;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

+ (NSString *)getUUIDStringFromString:(NSString *) uuidStr{
    // Create a new CFUUID (Unique, random ID number) (Always different)
    @try {
        // Make the new UUID String
        CFUUIDRef uuidRef = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)uuidStr);
        NSString *tempUniqueID = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        
        // Check to make sure it created it
        if (tempUniqueID == nil || tempUniqueID.length <= 0) {
            // Error, Unable to create
            // Release the UUID Reference
            CFRelease(uuidRef);
            // Return nil
            return uuidStr;
        }
        
        // Release the UUID Reference
        CFRelease(uuidRef);
        
        return tempUniqueID;
        
    }@catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        return uuidStr;
    }
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController {
    @try {
        if (![rootViewController isKindOfClass:[UINavigationController class]] && ![rootViewController isKindOfClass:[UITabBarController class]] && rootViewController.presentedViewController == nil) {
            return rootViewController;
        }
        
        if ([rootViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)rootViewController;
            return [self topViewController:[navigationController.viewControllers lastObject]];
        }
        if ([rootViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabController = (UITabBarController *)rootViewController;
            return [self topViewController:tabController.selectedViewController];
        }
        if (rootViewController.presentedViewController) {
            return  [self topViewController:rootViewController.presentedViewController];
        }
        return rootViewController;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}
@end
