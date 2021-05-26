//
//  BOFUtilities.m
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFUtilities.h"
#import "BOFLogs.h"
#include "BOFConstants.h"
#include "BlotoutFoundation.h"
#import "NSData+CommonCrypto.h"

@implementation BOFUtilities

+(NSString *)generateQueryStringFromOption:(NSDictionary *)option
{
    @try {
        //haven't handled the escape sequences ;)
        NSMutableArray* pairs = [NSMutableArray array];
        [option enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [BOFUtilities urlEncodeForString:obj usingEncoding:kCFStringEncodingUTF8]]];
        }];
        NSString* query = [pairs componentsJoinedByString:@"&"];
        return query;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

+(NSString *)urlEncodeForString:(NSString *)str usingEncoding:(CFStringEncoding)encoding{
    @try {
        if( [str respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)] ){
            return [str stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "] invertedSet]];
        }
        return str;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
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
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
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
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
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
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
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
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
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
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isDate:(NSDate*)testDate between:(NSDate*)date1 andDate2:(NSDate*)date2{
    @try {
        BOOL result1 = [self isDate:testDate greaterThanEqualTo:date1];
        BOOL result2 = [self isDate:testDate lessThanEqualTo:date2];
        return (result1 && result2);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

+(NSString*)getPasspharseKey{
    
    @try {
        NSString *encryptionKey =  [[BlotoutFoundation sharedInstance] encryptionKey];
   
        if(encryptionKey == nil) {
            encryptionKey = kEncryptionKey;
        }
        NSMutableString *newEncryptionKey = [NSMutableString string];
        
        for (NSInteger charIdx=0; charIdx<encryptionKey.length; charIdx++) {
            // Do something with character at index charIdx, for example:
           unichar charnew = [encryptionKey characterAtIndex:charIdx];
            charnew = charnew + 3;
            [newEncryptionKey appendFormat:@"%C",charnew];
        }
        
        return newEncryptionKey;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

+(NSString*)getSHA256:(NSString*)string {
    return [[string dataUsingEncoding:NSUTF8StringEncoding] SHA256HashString];
}

+(NSString*)getSHA1:(NSString*)string {
    return [[string dataUsingEncoding:NSUTF8StringEncoding] SHA1HashString];
}

@end
