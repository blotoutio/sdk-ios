//
//  BOAUtilities.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface BOAUtilities : NSObject

+(NSData*)jsonDataFrom:(NSDictionary*)dictObject withPrettyPrint:(BOOL) prettyPrint;

+(int)getCurrentTimezoneOffsetInMin;

+(NSNumber*)get13DigitNumberObjTimeStamp;
+(NSInteger)get13DigitIntegerTimeStamp;

+(NSString*)getMessageIDForEvent:(NSString*)eventName;

+(int)currentPlatformCode;

+(NSString*)getDeviceId;
+(NSString *)getUUIDString;

+(UIViewController *)topViewController:(UIViewController *)rootViewController;

+(NSString*)convertTo64CharUUID:(NSString*)stringToConvert;
+(NSString *)generateRandomNumber:(int)len;
+(NSString *)getUUIDStringFromString:(NSString *)uuidStr;
+(NSString *)systemName;
+(NSString *)systemVersion;
+(NSString *)deviceModel;
+(NSNumber *)getUserBirthTimeStamp;
+(NSData *_Nullable)dataFromPlist:(nonnull id)plist;
+(id _Nullable)plistFromData:(NSData *_Nonnull)data;
+(NSString*)getIDFA;
+(id)traverseJSON:(id)object;
+(NSString *)iso8601FormattedString:(NSDate *)date;
@end

NS_ASSUME_NONNULL_END
