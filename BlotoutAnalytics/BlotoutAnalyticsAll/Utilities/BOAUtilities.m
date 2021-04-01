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
#import <BlotoutFoundation/BOFUserDefaults.h>
#import <BlotoutFoundation/BOFLogs.h>
#import <UIKit/UIKit.h>
#import "BOASDKManifestController.h"
#import "BlotoutAnalytics_Internal.h"
#import <BlotoutFoundation/BOFUtilities.h>
#import <AdSupport/ASIdentifierManager.h>

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
    @try {
        static NSString *letters = @"0123456789";
        NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
        for (int i=0; i<len; i++) {
            [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
        }
        return randomString;
    }  @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        return @"";
    }
}

+ (NSString *)getUUIDString {
    @try {
        NSUUID *uuid = [NSUUID UUID];
        NSString *uuidStr = [uuid UUIDString];
        return uuidStr;
    }
    @catch (NSException *exception) {
        // Error
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
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

// System Name
+ (NSString *)systemName {
    @try {
        // Get the current system name
        if ([[UIDevice currentDevice] respondsToSelector:@selector(systemName)]) {
            // Make a string for the system name
            NSString *systemName = [[UIDevice currentDevice] systemName];
            // Set the output to the system name
            return systemName;
        } else {
            // System name not found
            return @"Unknown";
        }
    }@catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        return @"Unknown";
    }
}

// System Version
+ (NSString *)systemVersion {
    @try {
        // Get the current system version
        if ([[UIDevice currentDevice] respondsToSelector:@selector(systemVersion)]) {
            // Make a string for the system version
            NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
            // Set the output to the system version
            return systemVersion;
        } else if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersionString)]){
            //[[NSProcessInfo processInfo] operatingSystemVersion]; //use this to get Major, Minor and Patch
            NSString *systemVersion = [[NSProcessInfo processInfo] operatingSystemVersionString];
            return systemVersion;
        }else{
            // System version not found
            return @"Unknown";
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        return @"Unknown";
    }
}

// Model of Device
+ (NSString *)deviceModel {
    @try {
        // Get the device model
        if ([[UIDevice currentDevice] respondsToSelector:@selector(model)]) {
            // Make a string for the device model
            NSString *deviceModel = [[UIDevice currentDevice] model];
            // Set the output to the device model
            return deviceModel;
        } else {
            // Device model not found
            return @"Unknown";
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        return @"Unknown";
    }
}

+(NSNumber *)getUserBirthTimeStamp{
    NSNumber *timeStamp = [NSNumber numberWithInt:0];
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        timeStamp = [analyticsRootUD objectForKey:BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY];
        if([timeStamp intValue] == 0) {
            timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            [self setUserBirthTimeStamp:timeStamp];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return timeStamp;
}

+(void)setUserBirthTimeStamp:(NSNumber*)timeStamp{
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        [analyticsRootUD setObject:timeStamp forKey:BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+ (NSData *_Nullable)dataFromPlist:(nonnull id)plist
{
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0
                                                               error:&error];
    if (error) {
        BOFLogDebug(@"Unable to serialize data from plist object", error, plist);
    }
    return data;
}

+ (id _Nullable)plistFromData:(NSData *_Nonnull)data
{
    NSError *error = nil;
    id plist = [NSPropertyListSerialization propertyListWithData:data
                                                         options:0
                                                          format:nil
                                                           error:&error];
    if (error) {
        BOFLogDebug(@"Unable to parse plist from data %@", error);
    }
    return plist;
}

+(NSString*)getIDFA {
    NSString *idForAdvertiser = nil;
    @try {
        Class identifierManager = NSClassFromString(@"ASIdentifierManager");
        if (identifierManager) {
            SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
            id sharedManager =
            ((id (*)(id, SEL))
             [identifierManager methodForSelector:sharedManagerSelector])(
                                                                          identifierManager, sharedManagerSelector);
            SEL advertisingIdentifierSelector =
            NSSelectorFromString(@"advertisingIdentifier");
            NSUUID *uuid =
            ((NSUUID * (*)(id, SEL))
             [sharedManager methodForSelector:advertisingIdentifierSelector])(
                                                                              sharedManager, advertisingIdentifierSelector);
            idForAdvertiser = [uuid UUIDString];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return idForAdvertiser;
}

+(BOOL)getAdTrackingEnabled {
    @try{
        return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        return NO;
    }
}

+(NSDictionary *)traverseJSONDict:(NSDictionary *)dict
{
    // make sure that a new dictionary exists even if the input is null
    dict = dict ?: @{};
    // coerce urls, and dates to the proper format
    return [self traverseJSON:dict];
}


+(id)traverseJSON:(id)obj
{
    // Hotfix: Storage format should support NSNull instead
    if ([obj isKindOfClass:[NSNull class]]) {
        return @"<null>";
    }
    // if the object is a NSString, NSNumber
    // then we're good
    if ([obj isKindOfClass:[NSString class]] ||
        [obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }

    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id i in obj) {
            // Hotfix: Storage format should support NSNull instead
            if ([i isKindOfClass:[NSNull class]]) {
                continue;
            }
            [array addObject:[self traverseJSON:i]];
        }
        return array;
    }

    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSString *key in obj) {
            // Hotfix for issue where SEGFileStorage uses plist which does NOT support NSNull
            // So when `[NSNull null]` gets passed in as track property values the queue serialization fails
            if ([obj[key] isKindOfClass:[NSNull class]]) {
                continue;
            }
            if (![key isKindOfClass:[NSString class]])
                BOFLogDebug(@"warning: dictionary keys should be strings. got: %@. coercing "
                       @"to: %@",
                       [key class], [key description]);
            dict[key.description] = [self traverseJSON:obj[key]];
        }
        return dict;
    }

    if ([obj isKindOfClass:[NSDate class]])
        return [self iso8601FormattedString:obj];

    if ([obj isKindOfClass:[NSURL class]])
        return [obj absoluteString];

    // default to sending the object's description
    BOFLogDebug(@"warning: dictionary values should be valid json types. got: %@. "
           @"coercing to: %@",
           [obj class], [obj description]);
    return [obj description];
}

// Date Utils
+(NSString *)iso8601FormattedString:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'";
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return [dateFormatter stringFromDate:date];
}

@end
