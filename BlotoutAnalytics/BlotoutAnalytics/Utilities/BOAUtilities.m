//
//  BOAUtilities.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAUtilities.h"
#import <CommonCrypto/CommonDigest.h>
#import "BOANetworkConstants.h"
#import "BOFLogs.h"
#import "BOASDKManifestController.h"
#import "BlotoutAnalytics_Internal.h"
#import <AdSupport/ASIdentifierManager.h>
#import "BOFUtilities.h"
#import "BOFUserDefaults.h"

@implementation BOAUtilities

+(NSData*)jsonDataFrom:(NSDictionary*)dictObject withPrettyPrint:(BOOL) prettyPrint {
  @try {
    if (!dictObject || (dictObject.allKeys.count == 0)) {
      return nil;
    }
    
    NSError *error;
    NSData *jsonData = dictObject ? [NSJSONSerialization dataWithJSONObject:dictObject
                                                                    options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                                      error:&error] : nil;
    
    if (!jsonData) {
      BOFLogDebug(@"%s: error: %@", __func__, error.localizedDescription);
      return nil;
    }
    
    return jsonData;
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

+(NSNumber*)get13DigitNumberObjTimeStamp {
  @try {
    NSInteger timeStamp = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
    NSNumber *timeStampObj = [NSNumber numberWithInteger:timeStamp];
    return timeStampObj;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

+(NSInteger)get13DigitIntegerTimeStamp {
  @try {
    NSInteger timeStamp = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
    return timeStamp;
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
      sum += [encoded characterAtIndex:index];
    }
    return sum;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return 0;
}

+(NSString*)getMessageIDForEvent:(NSString*)eventName {
  @try {
    NSData *eventNameData = [eventName dataUsingEncoding:NSUTF8StringEncoding];

    return [NSString stringWithFormat:@"%@-%@-%ld", [eventNameData base64EncodedStringWithOptions:0], [self getUUIDString], (long)[self get13DigitIntegerTimeStamp]];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

+(NSNumber*)codeForCustomCodifiedEvent:(NSString*)eventName {
  @try {
    //int devCustomEventLowerLimit = 21000;
    //int devCustomEventUpperLimit = 22000;
    //Below will make sure any length blank string is never treated as string and valid name
    NSString *tempEventName = [eventName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!eventName || [tempEventName isEqualToString:@""]) {
      return nil;
    }
    
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    NSMutableDictionary *allCustomEvents = [[analyticsRootUD objectForKey:BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS] mutableCopy];
    if (!allCustomEvents) {
      allCustomEvents = [NSMutableDictionary dictionary];
    }
    
    BOOL isNameFound = [[allCustomEvents allKeys] containsObject:eventName];
    if (isNameFound) {
      return [allCustomEvents objectForKey:eventName];
    }
        
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
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

+(int)currentPlatformCode {
  switch ([UIDevice currentDevice].userInterfaceIdiom) {
    case UIUserInterfaceIdiomPhone:
      return 14;
    case UIUserInterfaceIdiomPad:
      return 15;
    case UIUserInterfaceIdiomTV:
      return 18;
    case UIUserInterfaceIdiomCarPlay:
    case UIUserInterfaceIdiomUnspecified:
      return 60;
    default:
      return 0;
  }
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
      
      [stringBuilder appendString:[BOAUtilities getUUIDString]];
      [stringBuilder appendString:[BOAUtilities generateRandomNumber:10]];
      [stringBuilder appendString:[BOAUtilities generateRandomNumber:10]];
      [stringBuilder appendFormat:@"%ldl",(long)[BOAUtilities get13DigitIntegerTimeStamp]];
      NSString *guidString = [BOAUtilities convertTo64CharUUID:[BOFUtilities getSHA256:stringBuilder]];
      deviceId = guidString != nil ? guidString : [BOAUtilities getUUIDStringFromString:stringBuilder];
      deviceId = deviceId != nil ? deviceId : [BOAUtilities getUUIDString];
      [analyticsRootUD setObject: deviceId forKey: BO_ANALYTICS_USER_UNIQUE_KEY];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  
  return deviceId;
}

+(NSString*)convertTo64CharUUID:(NSString*)stringToConvert {
  @try {
    if (stringToConvert == nil || stringToConvert.length == 0) {
      return stringToConvert;
    }
    
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
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return stringToConvert;
}

+ (NSString *)generateRandomNumber:(int)length {
  @try {
    static NSString *letters = @"0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i = 0; i < length; i++) {
      [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return @"";
}

+ (NSString *)getUUIDString {
  @try {
    NSUUID *uuid = [NSUUID UUID];
    NSString *uuidStr = [uuid UUIDString];
    return uuidStr;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

+ (NSString *)getUUIDStringFromString:(NSString *) uuidStr {
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
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return uuidStr;
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
  } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return rootViewController;
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
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return @"Unknown";
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
    }
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersionString)]) {
      //[[NSProcessInfo processInfo] operatingSystemVersion]; //use this to get Major, Minor and Patch
      NSString *systemVersion = [[NSProcessInfo processInfo] operatingSystemVersionString];
      return systemVersion;
    }
  } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return @"Unknown";
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
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return @"Unknown";
}

+(NSNumber *)getUserBirthTimeStamp {
  NSNumber *timeStamp = [NSNumber numberWithInt:0];
  @try {
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    timeStamp = [analyticsRootUD objectForKey:BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY];
    if ([timeStamp intValue] == 0) {
      timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
      [self setUserBirthTimeStamp:timeStamp];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return timeStamp;
}

+(void)setUserBirthTimeStamp:(NSNumber*)timeStamp {
  @try {
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    [analyticsRootUD setObject:timeStamp forKey:BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

+ (NSData *_Nullable)dataFromPlist:(nonnull id)plist {
    @try{
        NSError *error = nil;
        NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist
                                                                  format:NSPropertyListXMLFormat_v1_0
                                                                 options:0
                                                                   error:&error];
        if (error) {
            BOFLogDebug(@"Unable to serialize data from plist object", error, plist);
        }
        return data;
    }@catch(NSException *exception) {
        return nil;
    }
}

+ (id _Nullable)plistFromData:(NSData *_Nonnull)data {
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
    if (!identifierManager) {
      return idForAdvertiser;
    }
    
    SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
    id sharedManager =
    ((id (*)(id, SEL))
     [identifierManager methodForSelector:sharedManagerSelector])(identifierManager, sharedManagerSelector);
    SEL advertisingIdentifierSelector =
    NSSelectorFromString(@"advertisingIdentifier");
    NSUUID *uuid =
    ((NSUUID * (*)(id, SEL))
     [sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
    idForAdvertiser = [uuid UUIDString];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return idForAdvertiser;
}

+(NSDictionary *)traverseJSONDict:(NSDictionary *)dict {
  // make sure that a new dictionary exists even if the input is null
  dict = dict ?: @{};
  // coerce urls, and dates to the proper format
  return [self traverseJSON:dict];
}

+(id)traverseJSON:(id)obj {
  @try {
    // Hotfix: Storage format should support NSNull instead
    if ([obj isKindOfClass:[NSNull class]]) {
      return @"<null>";
    }
    
    // if the object is a NSString, NSNumber
    // then we're good
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
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
        
        if (![key isKindOfClass:[NSString class]]) {
          BOFLogDebug(@"warning: dictionary keys should be strings. got: %@. coercing "
                      @"to: %@",
                      [key class], [key description]);
        }
            
        dict[key.description] = [self traverseJSON:obj[key]];
      }
      return dict;
    }
    
    if ([obj isKindOfClass:[NSDate class]]) {
      return [self iso8601FormattedString:obj];
    }
    
    if ([obj isKindOfClass:[NSURL class]]) {
      return [obj absoluteString];
    }
    
    // default to sending the object's description
    BOFLogDebug(@"warning: dictionary values should be valid json types. got: %@. "
                @"coercing to: %@",
                [obj class], [obj description]);
    return [obj description];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return @"";
}

// Date Utils
+(NSString *)iso8601FormattedString:(NSDate *)date {
  @try {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'";
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return [dateFormatter stringFromDate:date];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return @"";
}

@end
