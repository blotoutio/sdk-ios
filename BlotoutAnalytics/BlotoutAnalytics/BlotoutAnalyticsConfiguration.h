//
//  BlotoutAnalyticsConfiguration.h
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 12/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BOACrypto.h"

NS_ASSUME_NONNULL_BEGIN


@protocol BOAApplicationProtocol <NSObject>
@property (nullable, nonatomic, assign) id<UIApplicationDelegate> delegate;
- (UIBackgroundTaskIdentifier)boa_beginBackgroundTaskWithName:(nullable NSString *)taskName expirationHandler:(void (^__nullable)(void))handler;
- (void)boa_endBackgroundTask:(UIBackgroundTaskIdentifier)identifier;
@end

@interface UIApplication (BOAApplicationProtocol) <BOAApplicationProtocol>
@end

@interface BlotoutAnalyticsConfiguration : NSObject

/**
 * Creates and returns a configuration with default settings and the given write key.
 *
 * @param token Your project's  key from Dashboard
 * @param endPointUrl Url where you will be sending data
 */
+ (_Nonnull instancetype)configurationWithToken:(NSString *_Nonnull)token withUrl:(NSString *_Nonnull)endPointUrl;

/**
 * Application token that you can get in your dashboard
 */
@property (nonatomic, copy, readonly, nonnull) NSString *token;

/**
 * Url where you will be sending data
 */
@property (nonatomic, copy, readonly, nonnull) NSString *endPointUrl;

/**
 * The number of queued events that the analytics client should flush at. Setting this to `1` will not queue any events and will use more battery. `10` by default.
 */
@property (nonatomic, assign) NSUInteger flushAt;

/**
 * The amount of time to wait before each tick of the flush timer.
 * Smaller values will make events delivered in a more real-time manner and also use more battery.
 * A value smaller than 10 seconds will seriously degrade overall performance.
 * 30 seconds by default.
 */
@property (nonatomic, assign) NSTimeInterval flushInterval;

/**
 * Set a your own implementation for encrption/decryption local data.
 */
@property (nonatomic, strong, nullable) id<BOACrypto> crypto;

/**
 * Dictionary indicating the options the app was launched with.
 */
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;


/**
 * Leave this nil for iOS extensions, otherwise set to UIApplication.sharedApplication.
 */
@property (nonatomic, strong, nullable) id<BOAApplicationProtocol> application;

/**
 * Whether the blotout analytics client should automatically track push notifications.
 */
@property (nonatomic, assign) BOOL trackPushNotifications;

/**
 * Whether the blotout analytics client should  track deep links.
 */
@property (nonatomic, assign) BOOL trackDeepLinks;

/**
 * Whether the analytics client should automatically track in-app purchases from the App Store.
 */
@property (nonatomic, assign) BOOL trackInAppPurchases;

/**
 * Whether the analytics client should automatically track in-app purchases from the App Store.
 */
@property (nonatomic, assign) BOOL trackSystemEvent;

@end

NS_ASSUME_NONNULL_END
