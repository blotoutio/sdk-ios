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

@interface BlotoutAnalytics : NSObject
/**
 *Default Value is YES, only set to NO when you want to disable SDK
 *Once you disable SDK, SDK won't collect any further information but already collected informtion,
 *will be sent to server as per Blotout Contract
 */
@property (nonatomic, readwrite) BOOL isEnabled;
//for disable data write on disk
@property (nonatomic, readwrite) BOOL isDataCollectionEnabled;
//for disable network
@property (nonatomic, readwrite) BOOL isNetworkSyncEnabled;

//Individual Module enable or disable control
//System Events, which SDK detect automatically
@property (nonatomic, readwrite) BOOL isSystemEventsEnabled;
//Rentention Events, which SDK detect for retention tracking like DAU, MAU
@property (nonatomic, readwrite) BOOL isRetentionEventsEnabled;
//Funnel Events, which SDK process for funnel analysis
@property (nonatomic, readwrite) BOOL isFunnelEventsEnabled;
//Segments Events, which SDK process for segment analysis
@property (nonatomic, readwrite) BOOL isSegmentEventsEnabled;
//Developer Codified Events, which SDK collects when developer send some events
@property (nonatomic, readwrite) BOOL isDeveloperEventsEnabled;
//if user is a payingUser
@property (nonatomic, readwrite) BOOL isPayingUser;

//Enable SDK Log Information
@property (nonatomic, readwrite) BOOL isSDKLogEnabled;

/**
 * public method to get the singleton instance of the BlotoutAnalytics object,
 * @return BlotoutAnalytics instance
 */
+ (nullable instancetype)sharedInstance;
- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));

// return sdk version
-(nonnull NSString*)sdkVersion;

//Fraud Services
-(BOOL)isDeviceCompromised;
-(BOOL)isAppCompromised;
-(BOOL)isNetworkProxied;
-(BOOL)isSimulator;
-(BOOL)isRunningOnVM;
-(BOOL)isEnvironmentSecure;

-(void)setPayingUser:(BOOL)payingUser;

/**
 * this initializes the BlotoutAnalytics tracking configuration, it has to be called only once when the
 * application starts, for example in the Application Class.
 * @param blotoutSDKKey   key as String
 * @param endPointUrl server Endpoint Url e.g. https://blotout.io, http://blotout.io
 */

-(void)initializeAnalyticsEngineUsingKey:(NSString*_Nonnull)blotoutSDKKey url:(NSString*_Nonnull)endPointUrl andCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler;

/**
 * @param eventName name of the event
 * @param startEventInfo properties in key/value pair
 */
-(void)startTimedEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)startEventInfo;

/**
 * @param eventName name of the event
 * @param endEventInfo properties in key/value pair
 */
-(void)endTimedEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)endEventInfo;

/**
 * @param eventName name of the event
 * @param eventInfo properties in key/value pair
 */
-(void)logEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo;

/**
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 * @param eventTime eventTime as Date
 */
-(void)logEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime;

/**
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 * @param eventTime eventTime as Date
 */
-(void)logPIIEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime;

/**
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 * @param eventTime eventTime as Date
 */
-(void)logPHIEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo happendAt:(nullable NSDate*)eventTime;
/**
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 */
-(void)logUserRetentionEvent:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo;

/**
     *
     * @param userId any userid
     * @param provider e.g google, Mixpanel
     * @param eventInfo dictionary of events
     */
-(void)mapId:(nonnull NSString*)userId forProvider:(nonnull NSString*)provider withInformation:(nullable NSDictionary*)eventInfo;

@end
