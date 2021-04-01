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
+(int)getCurrentTimezoneOffsetInMin;
+(int)getCurrentTimezoneOffsetInMin:(NSTimeZone*)timeZone;

+(NSNumber*)get13DigitNumberObjTimeStamp;
+(NSInteger)get13DigitIntegerTimeStamp;

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
+(NSString *)systemName;
+(NSString *)systemVersion;
+(NSString *)deviceModel;
+(NSNumber *)getUserBirthTimeStamp;
+(NSData *_Nullable)dataFromPlist:(nonnull id)plist;
+(id _Nullable)plistFromData:(NSData *_Nonnull)data;
+(NSString*)getIDFA;
+(BOOL)getAdTrackingEnabled;
+(id)traverseJSON:(id)object;
+(NSString *)iso8601FormattedString:(NSDate *)date;
@end

NS_ASSUME_NONNULL_END
