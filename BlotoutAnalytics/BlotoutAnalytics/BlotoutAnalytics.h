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
 @method

 @abstract
 Enable the sending of analytics data. Enabled by default.

 @discussion
 Occasionally used in conjunction with disable user opt-out handling.
 */
- (void)enable;


/*!
 @method

 @abstract
 Completely disable the sending of any analytics data.

 @discussion
 If have a way for users to actively or passively (sometimes based on location) opt-out of
 analytics data collection, you can use this method to turn off all data collection.
 */
- (void)disable;

//Enable SDK Log Information
@property (nonatomic, readwrite) BOOL isSDKLogEnabled;


@end
