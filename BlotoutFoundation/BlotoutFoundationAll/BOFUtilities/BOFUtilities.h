//
//  BOFUtilities.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOFUtilities : NSObject

+(NSString *)generateQueryStringFromOption:(NSDictionary *)option;
+(NSString *)urlEncodeForString:(NSString *)str usingEncoding:(CFStringEncoding)encoding;

+(BOOL)isDate:(NSDate*)date1 greaterThan:(NSDate*)date2;
+(BOOL)isDate:(NSDate*)date1 greaterThanEqualTo:(NSDate*)date2;
+(BOOL)isDate:(NSDate*)date1 lessThan:(NSDate*)date2;
+(BOOL)isDate:(NSDate*)date1 lessThanEqualTo:(NSDate*)date2;
+(BOOL)isDate:(NSDate*)date1 equalTo:(NSDate*)date2;
//Comparision includes graterThanEqualTo date1 and lessThanEqualTo date2
+(BOOL)isDate:(NSDate*)testDate between:(NSDate*)date1 andDate2:(NSDate*)date2;
+(NSString*)getPasspharseKey;
+(NSString*)getSHA256:(NSString*)string;
+(NSString*)getSHA1:(NSString*)string;
@end

NS_ASSUME_NONNULL_END
