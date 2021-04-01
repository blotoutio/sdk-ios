//
//  BlotoutAnalytics_Internal.h
//  BlotoutAnalytics
//
//  Created by Blotout on 16/02/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#ifndef BlotoutAnalytics_Internal_h
#define BlotoutAnalytics_Internal_h

#import "BlotoutAnalytics.h"
#import "BOADeveloperEvents.h"
#import <BlotoutFoundation/BlotoutFoundation.h>
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import "UIViewController+Extensions.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import <BlotoutFoundation/BOFNetworkPromiseExecutor.h>
#import "BOAEventsManager.h"
#import "BOAStoreKitController.h"

@interface BlotoutAnalytics ()

@property(nonatomic,strong,nonnull) BlotoutAnalyticsConfiguration *config;
@property(nonatomic,strong,nonnull) BOAEventsManager *eventManager;
@property (nonatomic, strong, nonnull) BOAStoreKitController *storeKitController;

//Server Endpoint Url e.g. https://blotout.io/sdk, http://blotout.io/sdk, It has to be a domain based, IP's are considered invalid.
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

-(void)capture:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo withType:(NSString* _Nonnull)type;

@end

#endif /* BlotoutAnalytics_Internal_h */
