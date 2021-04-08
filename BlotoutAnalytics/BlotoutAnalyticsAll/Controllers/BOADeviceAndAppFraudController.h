//
//  BOADeviceAndAppFraudController.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOADeviceAndAppFraudController : NSObject

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

+(NSMutableDictionary*)getCurrentBinaryInfo;
+(BOOL)isDylibInjectedToProcessWithName:(NSString*)dylib_name;
+(BOOL)isConnectionProxied;
+(NSString *)proxy_host;
+(NSString*)proxy_port;
+(BOOL)ttyWayIsDebuggerConnected;
+(BOOL)isDebuggerConnected;
+(BOOL)isDeviceJailbroken;

@end

NS_ASSUME_NONNULL_END
