//
//  BlotoutAnalytics.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BlotoutAnalytics main class, the developer/customer interacts with the SDK through this class.
 */

#import <Foundation/Foundation.h>
#import "BlotoutAnalyticsConfiguration.h"

@interface BlotoutAnalytics : NSObject

/**
 * public method to get the singleton instance of the BlotoutAnalytics object,
 * @return BlotoutAnalytics instance
 */
+ (nullable instancetype)sharedInstance;
- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));

/**
 * this initializes the BlotoutAnalytics tracking configuration, it has to be called only once when the
 * application starts, for example in the Application Class.
 * @param configuration The configuration used to setup the client.
 */

-(void)init:(BlotoutAnalyticsConfiguration*_Nullable)configuration andCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler;


/**
 * @param eventName name of the event
 * @param eventInfo properties in key/value pair
 */
-(void)capture:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo;

/**
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 * @param phiEvent boolean value
 */
-(void)capturePersonal:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo isPHI:(BOOL)phiEvent;


/**
 *
 * @param userId any userid
 * @param provider e.g google, Mixpanel
 * @param eventInfo dictionary of events
 */
-(void)mapID:(nonnull NSString*)userId forProvider:(nonnull NSString*)provider withInformation:(nullable NSDictionary*)eventInfo;

/**
 The getUserId method allows you to go get Blotout user id that is linked to all data that is sent to the server.
 */
-(nullable NSString*)getUserId;

/*!
 Enable the sending of analytics data. Enabled by default. Set NO to stop sending data
 */
@property (nonatomic, readwrite) BOOL enable;

//Enable SDK Log Information
@property (nonatomic, readwrite) BOOL enableSDKLog;

//Application leval methods handling

// called when user will received any notification
- (void)receivedRemoteNotification:(NSDictionary *_Nullable)userInfo;

// called when device failed to register for remote notification
- (void)failedToRegisterForRemoteNotificationsWithError:(NSError *_Nullable)error;

// called when device register for remote notification
- (void)registeredForRemoteNotificationsWithDeviceToken:(NSData *_Nullable)deviceToken;

// called when device has detect user activity
- (void)continueUserActivity:(NSUserActivity *_Nonnull)activity;

// called when device has detect openUrl in case of deep link
- (void)openURL:(NSURL *_Nullable)url options:(NSDictionary *_Nonnull)options;

@end
