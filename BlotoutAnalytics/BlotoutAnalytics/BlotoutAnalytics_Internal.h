//
//  BlotoutAnalytics_Internal.h
//  BlotoutAnalytics
//
//  Copyright © 2020 Blotout. All rights reserved.
//

#ifndef BlotoutAnalytics_Internal_h
#define BlotoutAnalytics_Internal_h

#import "BlotoutAnalytics.h"
#import "BOADeveloperEvents.h"

#import "UIViewController+Extensions.h"
#import "BOAUtilities.h"
#import "BOAEventsManager.h"
#import "BOAStoreKitController.h"

@interface BlotoutAnalytics ()

@property(nonatomic,strong,nonnull) BlotoutAnalyticsConfiguration *config;
@property(nonatomic,strong,nonnull) BOAEventsManager *eventManager;
@property (nonatomic, strong, nonnull) BOAStoreKitController *storeKitController;
@property (nonatomic, strong, nullable) NSString *endPointUrl;
@property (nonatomic, strong, nullable) NSString *token;

/**
 *Default Value is YES, only set to NO when you want to disable SDK
 *Once you disable SDK, SDK won't collect any further information but already collected informtion,
 *will be sent to server as per Blotout Contract
 */
@property (nonatomic, readwrite) BOOL isEnabled;

// return sdk version
-(nonnull NSString*)sdkVersion;

-(void)capture:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo withType:(NSString* _Nonnull)type withEventCode:(NSNumber* _Nonnull)eventCode;

@end

#endif /* BlotoutAnalytics_Internal_h */
