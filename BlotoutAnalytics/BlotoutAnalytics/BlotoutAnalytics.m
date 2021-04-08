//
//  BlotoutAnalytics.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BlotoutAnalytics main class, the developer/customer interacts with the SDK through this class.
 */

#import "BlotoutAnalytics_Internal.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import "NSError+BOAdditions.h"
#import "BOSharedManager.h"
#import "BOEventsOperationExecutor.h"
#import "BOANetworkConstants.h"
#import "BOASDKManifestController.h"
#import "BOAEventsManager.h"
#import "BOAFileStorage.h"
#import "BOAAESCrypto.h"
#import "BOAUserDefaultsStorage.h"
#import "BOASystemEvents.h"
#import <AppTrackingTransparency/ATTrackingManager.h>
#import <AdSupport/AdSupport.h>

static id sBOASharedInstance = nil;

@implementation BlotoutAnalytics

-(instancetype)init {
  self = [super init];
  if (self) {
    self.isEnabled = YES;
    [BlotoutFoundation sharedInstance].isEnabled = YES;
    loadAsUIViewControllerBOFoundationCat();
    [BOSharedManager sharedInstance];
  }
  
  return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaOnceToken = 0;
    dispatch_once(&boaOnceToken, ^{
        sBOASharedInstance = [[[self class] alloc] init];
    });
    return  sBOASharedInstance;
}

/**
 * method to enable SDK
 * @param isEnabled default is true, set false to disable the sdk
 */
-(void)setIsEnabled:(BOOL)isEnabled {
  @try {
    _isEnabled = isEnabled;
    
    [BOFNetworkPromiseExecutor sharedInstance].isSDKEnabled = isEnabled;
    [BOFNetworkPromiseExecutor sharedInstanceForCampaign].isSDKEnabled = isEnabled;
    [BOFFileSystemManager setIsSDKEnabled:isEnabled];
    [BlotoutFoundation sharedInstance].isEnabled = isEnabled;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

-(void)setEnable:(BOOL)enable {
  self.isEnabled = enable;
}

-(void)setEnableSDKLog:(BOOL)enableSDKLog {
  @try {
    _enableSDKLog = enableSDKLog;
    [BOFLogs sharedInstance].isSDKLogEnabled = enableSDKLog;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

-(void)init:(BlotoutAnalyticsConfiguration*)configuration andCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler {
  @try {
    if (![self validateData:configuration]) {
      NSError *initError = [NSError errorWithDomain:@"io.blotout.analytics" code:100002 userInfo:@{
          @"userInfo": @"Token and EndPoint Url can't be empty !"
      }];
      completionHandler(NO, initError);
      return;
    }
    
#if TARGET_OS_TV
    BOAUserDefaultsStorage *storage = [[BOAUserDefaultsStorage alloc] initWithDefaults:[NSUserDefaults standardUserDefaults] namespacePrefix:nil crypto:[self getCrypto:configuration]];
#else
    BOAFileStorage *storage = [[BOAFileStorage alloc] initWithFolder:[NSURL fileURLWithPath:[BOFFileSystemManager getBOSDKRootDirectory]] crypto:[self getCrypto:configuration]];
#endif
    
    self.eventManager = [[BOAEventsManager alloc] initWithConfiguration:configuration storage:storage];
    self.token = configuration.token;
    self.endPointUrl = configuration.endPointUrl;
    [self registerApplicationStates];
    
#if !TARGET_OS_TV
    if (configuration.trackPushNotifications && configuration.launchOptions) {
      NSDictionary *remoteNotification = configuration.launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
      if (remoteNotification) {
        [self trackPushNotification:remoteNotification fromLaunch:YES];
      }
    }
    
    if (configuration.trackInAppPurchases) {
      self.storeKitController = [BOAStoreKitController trackTransactionsForConfiguration:configuration];
    }
#endif
    
    [[BOEventsOperationExecutor sharedInstance] dispatchInitializationInBackground:^{
      [self checkManifestAndInitAnalyticsWithCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        completionHandler(isSuccess, error);
      }];
    }];
    
    //check for app tracking and fetch IDFA
    [self checkAppTrackingStatus];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    completionHandler(NO, [NSError boErrorForDict:exception.userInfo]);
  }
}

/**
 This Method will process common funtionality for checking manifest with server and prepare sdk data
 */
-(void)checkManifestAndInitAnalyticsWithCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler {
  @try {
    BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
    if ([sdkManifesCtrl isManifestAvailable]) {
      [sdkManifesCtrl reloadManifestData];
    }
    
    [self fetchManifest:^(BOOL isSuccess, NSError *error) {
      if (!isSuccess) {
        NSError *serverInitError = [NSError errorWithDomain:@"io.blotout.analytics" code:100003 userInfo:@{
            @"userInfo": @"Server Sync failed, check your keys & network connection"}];
        completionHandler(NO, serverInitError);
        return;
      }
      
      completionHandler(isSuccess, error);
    }];
  } @catch (NSException *exception) {
    BOFLogInfo(@"%@:%@", BOA_DEBUG, exception);
    completionHandler(NO, [NSError boErrorForDict:exception.userInfo]);
  }
}

/**
 * This Method is used to fetch manifest values from the server
 */
-(void)fetchManifest:(void (^_Nullable) (BOOL isSuccess, NSError* error))callback {
  @try {
    BOASDKManifestController *sdkManifest = [BOASDKManifestController sharedInstance];
    [sdkManifest serverSyncManifestAndAppVerification:^(BOOL isSuccess, NSError * _Nonnull error) {
      callback(isSuccess, error);
    }];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    callback(NO, [NSError boErrorForDict:exception.userInfo]);
  }
}

-(id<BOACrypto>)getCrypto:(BlotoutAnalyticsConfiguration*)config {
  @try {
    if (config.crypto) {
      return config.crypto;
    }
    
    BOAAESCrypto *crypto = [[BOAAESCrypto alloc] initWithPassword:[BOAUtilities getDeviceId] iv:BO_CRYPTO_IVX];
    return crypto;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

-(BOOL)validateData:(BlotoutAnalyticsConfiguration*)configuration {
  //Confirm and perform 15 character length check if needed
  NSString* token = [configuration.token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSString* endPointUrl = [configuration.endPointUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  
  if (!token || [token isEqualToString:@""] || !endPointUrl || [endPointUrl isEqualToString:@""] ) {
    return NO;
  }
  
  return YES;
}

-(NSString*)sdkVersion {
  @try {
    return [NSString stringWithFormat:@"%d.%d.%d",BOSDK_MAJOR_VERSION,BOSDK_MINOR_VERSION,BOSDK_PATCH_VERSION];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  
  return nil;
}

/**
 *
 * @param userId any userid
 * @param provider e.g google, Mixpanel
 * @param eventInfo dictionary of events
 */
-(void)mapID:(nonnull NSString*)userId forProvider:(nonnull NSString*)provider withInformation:(nullable NSDictionary*)eventInfo {
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    NSMutableDictionary *mapIdInfo = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:userId, provider,nil] forKeys:[NSArray arrayWithObjects:BO_EVENT_MAP_ID, BO_EVENT_MAP_PROVIDER,nil]];
    if (eventInfo) {
      [mapIdInfo addEntriesFromDictionary:eventInfo];
    }
    
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_EVENT_MAP_ID properties:eventInfo eventCode:[NSNumber numberWithInt:BO_DEV_EVENT_MAP_ID] screenName:nil withType:BO_CODIFIED];
    [self.eventManager capture:model];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

/**
 * @param eventName name of the event
 * @param eventInfo properties in key/value pair
 */
-(void)capture:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo {
  @try {
    [self capture:eventName withInformation:eventInfo withType:BO_CODIFIED withEventCode:@(0)];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

-(void)capture:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo withType:(NSString*)type withEventCode:(NSNumber*)eventCode{
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:eventName properties:eventInfo eventCode:eventCode screenName:nil withType:type];
    [self.eventManager capture:model];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

/**
 *
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 * @param phiEvent boolean value
 */

-(void)capturePersonal:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo isPHI:(BOOL)phiEvent {
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    NSString *type = phiEvent ? BO_PHI : BO_PII;
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:eventName properties:eventInfo eventCode:@(0) screenName:nil withType:type];
    [self.eventManager capturePersonal:model isPHI:phiEvent];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

-(nullable NSString*)getUserId {
  return [BOAUtilities getDeviceId];
}

#pragma MARK- Application Delegates
- (void)trackPushNotification:(NSDictionary *)properties fromLaunch:(BOOL)launch {
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    if (launch) {
      [self capture:@"Push Notification Tapped" withInformation:properties withType:BO_SYSTEM withEventCode:@(BO_PUSH_NOTIFICATION_TAPPED)];
    } else {
      [self capture:@"Push Notification Received" withInformation:properties withType:BO_SYSTEM withEventCode:@(BO_PUSH_NOTIFICATION_RECEIVED)];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)receivedRemoteNotification:(NSDictionary *)userInfo {
    @try {
      if (!self.isEnabled || !self.config.trackPushNotifications) {
        return;
      }
    
      [self trackPushNotification:userInfo fromLaunch:NO];
    } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)failedToRegisterForRemoteNotificationsWithError:(NSError *)error {
  @try {
    if (!self.isEnabled || !self.config.trackPushNotifications) {
      return;
    }
  
      NSMutableDictionary *properties = [NSMutableDictionary dictionary];
      [properties setValue:@(0) forKey:@"deviceRegistered"];
      [self capture:@"Register For Remote Notification" withInformation:properties withType:BO_SYSTEM withEventCode:@(BO_REGISTER_FOR_REMOTE_NOTIFICATION)];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)registeredForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    @try {
      if (!self.isEnabled || !self.config.trackPushNotifications) {
        return;
      }
    
      NSMutableDictionary *properties = [NSMutableDictionary dictionary];
      const unsigned char *buffer = (const unsigned char *)[deviceToken bytes];
      if (!buffer) {
        return;
      }
      
      NSMutableString *token = [NSMutableString stringWithCapacity:(deviceToken.length * 2)];
      for (NSUInteger i = 0; i < deviceToken.length; i++) {
        [token appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)buffer[i]]];
      }
      
      [properties setValue:token forKey:@"token"];
      [properties setValue:@(1) forKey:@"deviceRegistered"];
      [self capture:@"Remote Notification Register" withInformation:properties withType:BO_SYSTEM withEventCode:@(BO_REGISTER_FOR_REMOTE_NOTIFICATION)];
    } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)continueUserActivity:(NSUserActivity *)activity {
  @try {
    if (!self.isEnabled || !self.config.trackDeepLinks || ![activity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
      return;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:activity.userInfo.count + 2];
    [properties addEntriesFromDictionary:activity.userInfo];
    properties[@"url"] = activity.webpageURL.absoluteString;
    properties[@"title"] = activity.title ?: @"";
    properties = [BOAUtilities traverseJSON:properties];
    [self refreshSessionAndReferrer:activity.webpageURL.absoluteString];
    [self capture:@"Deep Link Opened" withInformation:[properties copy] withType:BO_SYSTEM withEventCode:@(BO_DEEP_LINK_OPENED)];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)openURL:(NSURL *)url options:(NSDictionary *)options {
  @try {
    if (!self.isEnabled || !self.config.trackDeepLinks) {
      return;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:options.count + 2];
    [properties addEntriesFromDictionary:options];
    properties[@"url"] = url.absoluteString;
    properties = [BOAUtilities traverseJSON:properties];
    [self refreshSessionAndReferrer:url.absoluteString];
    [self capture:@"Deep Link Opened" withInformation:[properties copy] withType:BO_SYSTEM withEventCode:@(BO_DEEP_LINK_OPENED)];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

-(void)refreshSessionAndReferrer:(NSString*)referrerUrl {
  if ([BOSharedManager sharedInstance].referrer.length > 0 && ![[BOSharedManager sharedInstance].referrer isEqual:referrerUrl]) {
    [BOSharedManager refreshSession];
  }
  
  [BOSharedManager sharedInstance].referrer = referrerUrl;
}

-(void)registerApplicationStates {
  @try {
    // Attach to application state change hooks
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    for (NSString *name in @[ UIApplicationDidEnterBackgroundNotification,
                              UIApplicationDidFinishLaunchingNotification,
                              UIApplicationWillEnterForegroundNotification,
                              UIApplicationWillTerminateNotification,
                              UIApplicationWillResignActiveNotification,
                              UIApplicationDidBecomeActiveNotification ]) {
      [nc addObserver:self selector:@selector(handleAppStateNotification:) name:name object:nil];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)handleAppStateNotification:(NSNotification *)note {
  if ([note.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
    [self _applicationDidFinishLaunchingWithOptions:note.userInfo];
  } else if ([note.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
    [self _applicationWillEnterForeground];
  } else if ([note.name isEqualToString: UIApplicationDidEnterBackgroundNotification]) {
    [self _applicationDidEnterBackground];
  } else if ([note.name isEqualToString: UIApplicationWillTerminateNotification]) {
    [self _applicationWillTerminate];
  }
}
- (void)_applicationWillTerminate {
  [self.eventManager applicationWillTerminate];
}

- (void)_applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  @try {
    if (!self.isEnabled || !self.config.trackSystemEvent) {
      return;
    }
    
    [BOASystemEvents captureAppLaunchingInfoWithConfiguration:launchOptions];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)_applicationWillEnterForeground {
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    if (self.config.trackSystemEvent) {
      [self capture:@"Application Opened" withInformation:@{
          @"from_background" : @YES,
      } withType:BO_SYSTEM withEventCode:@(BO_APPLICATION_OPENED)];
    }
    
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_VISIBILITY_VISIBLE properties:nil eventCode:@(BO_EVENT_VISIBILITY_VISIBLE) screenName:nil withType:BO_SYSTEM];
    [self.eventManager capture:model];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)_applicationDidEnterBackground {
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_VISIBILITY_HIDDEN properties:nil eventCode:@(BO_EVENT_VISIBILITY_HIDDEN) screenName:nil withType:BO_SYSTEM];
    [self.eventManager capture:model];
    
    if (self.config.trackSystemEvent) {
      [self capture: @"Application Backgrounded" withInformation:nil withType:BO_SYSTEM withEventCode:@(BO_APPLICATION_BACKGROUNDED)];
    }
    [self.eventManager applicationDidEnterBackground];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

-(void)checkAppTrackingStatus {
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    NSString *statusString = @"";
    NSString *idfaString = @"";
    if (@available(iOS 14, *)) {
      ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
      switch (status) {
        case ATTrackingManagerAuthorizationStatusAuthorized:
          statusString = @"Authorized";
          idfaString =  [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
          break;
        case ATTrackingManagerAuthorizationStatusDenied:
          statusString = @"Denied";
          break;
        case ATTrackingManagerAuthorizationStatusRestricted:
          statusString = @"Restricted";
          break;
        case ATTrackingManagerAuthorizationStatusNotDetermined:
          statusString = @"Not Determined";
          break;
        default:
          statusString = @"Unknown";
          break;
      }
    } else {
      // Fallback on earlier version
      if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
        statusString = @"Authorized";
        idfaString = [BOAUtilities getIDFA];
      } else {
        statusString = @"Denied";
      }
    }
    
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:@"App Tracking" properties:@{@"status":statusString,@"idfa":idfaString} eventCode:@(BO_APP_TRACKING) screenName:nil withType:BO_SYSTEM];
    [self.eventManager capture:model];
  } @catch(NSException *exception) {
    BOFLogDebug(@"%@", exception);
  }
}

@end
