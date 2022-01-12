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
#import "BOFLogs.h"
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
#import "NSData+Base64.h"
#import "NSData+CommonCrypto.h"
#import "NSString+Base64.h"
#import "BOFNetworkPromiseExecutor.h"
#import "BOFFileSystemManager.h"

static id sBOASharedInstance = nil;

@implementation BlotoutAnalytics

-(instancetype)init {
  self = [super init];
  if (self) {
    self.isEnabled = YES;
    loadAsUIViewControllerBOFoundationCat();
    loadAsNSDataBase64FoundationCat();
    loadAsNSDataCommonDigestFoundationCat();
    loadAsNSStringBase64FoundationCat();
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
    if (configuration.launchOptions) {
      NSDictionary *remoteNotification = configuration.launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
      if (remoteNotification) {
        [self trackPushNotification:remoteNotification fromLaunch:YES];
      }
    }
    
    self.storeKitController = [BOAStoreKitController trackTransactionsForConfiguration:configuration];
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
  
  if (!token || [token isEqualToString:@""] || !endPointUrl || [endPointUrl isEqualToString:@""]) {
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
 * @param mapIDData map data with externalID and provider
 * @param eventInfo dictionary of events
 */
-(void)mapID:(nonnull BOAMapIDDataModel*)mapIDData withInformation:(nullable NSDictionary*)eventInfo {
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      NSMutableDictionary *mapIdInfo = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:mapIDData.externalID, mapIDData.provider,nil] forKeys:[NSArray arrayWithObjects:BO_EVENT_MAP_ID, BO_EVENT_MAP_PROVIDER,nil]];
      if (eventInfo) {
        [mapIdInfo addEntriesFromDictionary:eventInfo];
      }
      
      BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_EVENT_MAP_ID properties:mapIdInfo  screenName:nil withType:BO_CODIFIED];
      [self.eventManager capture:model];
    }];
    
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
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      [self capture:eventName withInformation:eventInfo withType:BO_CODIFIED withEventCode:@(0)];
    }];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

-(void)capture:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo withType:(NSString*)type withEventCode:(NSNumber*)eventCode{
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:eventName properties:eventInfo  screenName:nil withType:type];
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

-(void)capturePersonal:(nonnull NSString*)eventName withInformation:(nonnull NSDictionary*)eventInfo isPHI:(BOOL)phiEvent {
  @try {
    if (!self.isEnabled) {
      return;
    }
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      NSString *type = phiEvent ? BO_PHI : BO_PII;
      BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:eventName properties:eventInfo  screenName:nil withType:type];
      [self.eventManager capturePersonal:model isPHI:phiEvent];
    }];
    
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
    
    BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
    
    if (launch && [sdkManifesCtrl isSystemEventEnabled:BO_PUSH_NOTIFICATION_TAPPED]) {
      [self capture:@"Push Notification Tapped" withInformation:properties withType:BO_SYSTEM withEventCode:@(BO_PUSH_NOTIFICATION_TAPPED)];
    } else if ([sdkManifesCtrl isSystemEventEnabled:BO_PUSH_NOTIFICATION_RECEIVED]) {
      [self capture:@"Push Notification Received" withInformation:properties withType:BO_SYSTEM withEventCode:@(BO_PUSH_NOTIFICATION_RECEIVED)];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)receivedRemoteNotification:(NSDictionary *)userInfo {
  @try {
    if (!self.isEnabled) {
      return;
    }
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      [self trackPushNotification:userInfo fromLaunch:NO];
    }];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)failedToRegisterForRemoteNotificationsWithError:(NSError *)error {
  @try {
    if (!self.isEnabled) {
      return;
    }
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
      if ([sdkManifesCtrl isSystemEventEnabled:BO_REGISTER_FOR_REMOTE_NOTIFICATION]) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        [properties setValue:@(0) forKey:@"deviceRegistered"];
        [self capture:@"Register For Remote Notification" withInformation:properties withType:BO_SYSTEM withEventCode:@(BO_REGISTER_FOR_REMOTE_NOTIFICATION)];
      }
    }];
    
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)registeredForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  @try {
    if (!self.isEnabled) {
      return;
    }

    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
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
      
      BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
      if ([sdkManifesCtrl isSystemEventEnabled:BO_REGISTER_FOR_REMOTE_NOTIFICATION]) {
        [self capture:@"Remote Notification Register" withInformation:properties withType:BO_SYSTEM withEventCode:@(BO_REGISTER_FOR_REMOTE_NOTIFICATION)];
      }}];
    } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)continueUserActivity:(NSUserActivity *)activity {
  @try {
    BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
    if (!self.isEnabled || ![activity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || ![sdkManifesCtrl isSystemEventEnabled:BO_DEEP_LINK_OPENED]) {
      return;
    }
    
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:activity.userInfo.count + 2];
      [properties addEntriesFromDictionary:activity.userInfo];
      properties[@"url"] = activity.webpageURL.absoluteString;
      properties[@"title"] = activity.title ?: @"";
      properties = [BOAUtilities traverseJSON:properties];
      [self refreshSessionAndReferrer:activity.webpageURL.absoluteString];
      [self capture:@"Deep Link Opened" withInformation:[properties copy] withType:BO_SYSTEM withEventCode:@(BO_DEEP_LINK_OPENED)];
    }];
    
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)openURL:(NSURL *)url options:(NSDictionary *)options {
  @try {
    BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
    if (!self.isEnabled || ![sdkManifesCtrl isSystemEventEnabled:BO_DEEP_LINK_OPENED]) {
      return;
    }
    
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:options.count + 2];
      [properties addEntriesFromDictionary:options];
      properties[@"url"] = url.absoluteString;
      properties = [BOAUtilities traverseJSON:properties];
      [self refreshSessionAndReferrer:url.absoluteString];
      [self capture:@"Deep Link Opened" withInformation:[properties copy] withType:BO_SYSTEM withEventCode:@(BO_DEEP_LINK_OPENED)];
    }];
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
  [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
    if ([note.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
      [self _applicationDidFinishLaunchingWithOptions:note.userInfo];
    } else if ([note.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
      [self _applicationWillEnterForeground];
    } else if ([note.name isEqualToString: UIApplicationDidEnterBackgroundNotification]) {
      [self _applicationDidEnterBackground];
    } else if ([note.name isEqualToString: UIApplicationWillTerminateNotification]) {
      [self _applicationWillTerminate];
    }
  }];
}
- (void)_applicationWillTerminate {
  [self.eventManager applicationWillTerminate];
}

- (void)_applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  @try {
    if (!self.isEnabled) {
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
    
    BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
    if ([sdkManifesCtrl isSystemEventEnabled:BO_APPLICATION_OPENED]) {
      [self capture:@"Application Opened" withInformation:@{
        @"from_background" : @YES,
      } withType:BO_SYSTEM withEventCode:@(BO_APPLICATION_OPENED)];
    }
    
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_VISIBILITY_VISIBLE properties:nil  screenName:nil withType:BO_SYSTEM];
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
    
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_VISIBILITY_HIDDEN properties:nil screenName:nil withType:BO_SYSTEM];
    [self.eventManager capture:model];
    
    BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
    if ([sdkManifesCtrl isSystemEventEnabled:BO_APPLICATION_BACKGROUNDED]) {
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
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{

      BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
      if (![sdkManifesCtrl isSystemEventEnabled:BO_APP_TRACKING]) {
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
      
      BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:@"App Tracking" properties:@{@"status":statusString,@"idfa":idfaString}  screenName:nil withType:BO_SYSTEM];
      [self.eventManager capture:model];
    }];
  } @catch(NSException *exception) {
    BOFLogDebug(@"%@", exception);
  }
}

-(void)captureTransaction:(nonnull TransactionData*)transactionData withInformation:(nullable NSDictionary*)eventInfo {
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      NSMutableDictionary *transactionInfo = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:transactionData.transaction_id, transactionData.transaction_currency,transactionData.transaction_total,transactionData.transaction_discount,transactionData.transaction_shipping,transactionData.transaction_tax,nil] forKeys:[NSArray arrayWithObjects:@"transaction_id", @"transaction_currency",@"transaction_total",@"transaction_discount",@"transaction_shipping",@"transaction_tax",nil]];
      if (eventInfo) {
        [transactionInfo addEntriesFromDictionary:eventInfo];
      }
      
      BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_EVENT_TRANSACTION_NAME properties:transactionInfo  screenName:nil withType:BO_CODIFIED];
      [self.eventManager capture:model];
    }];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

-(void)captureItem:(nonnull Item*)itemData withInformation:(nullable NSDictionary*)eventInfo {
    @try {
        if (!self.isEnabled) {
            return;
        }
        [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
            NSMutableDictionary *itemInfo = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:itemData.item_id, itemData.item_name,itemData.item_sku,itemData.item_category,itemData.item_price,itemData.item_currency,itemData.item_quantity, nil] forKeys:[NSArray arrayWithObjects:@"item_id", @"item_name",@"item_sku",@"item_category",@"item_price",@"item_currency",@"item_quantity",nil]];
            if (eventInfo) {
                [itemInfo addEntriesFromDictionary:eventInfo];
            }
            
            BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_EVENT_ITEM_NAME properties:itemInfo  screenName:nil withType:BO_CODIFIED];
            [self.eventManager capture:model];
        }];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)capturePersona:(nonnull Persona*)personaData withInformation:(nullable NSDictionary*)eventInfo {
  @try {
    if (!self.isEnabled) {
      return;
    }
    
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      NSMutableDictionary *personaInfo = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:personaData.persona_id, personaData.persona_firstname,personaData.persona_middlename,personaData.persona_lastname,personaData.persona_username,personaData.persona_dob,personaData.persona_email,personaData.persona_number,personaData.persona_address,personaData.persona_city,personaData.persona_state,personaData.persona_zip,personaData.persona_country,personaData.persona_gender,personaData.persona_age,nil] forKeys:[NSArray arrayWithObjects:@"persona_id", @"persona_firstname",@"persona_middlename",@"persona_lastname",@"persona_username",@"persona_dob",@"persona_email",@"persona_number",@"persona_address",@"persona_city",@"persona_state",@"persona_zip",@"persona_country",@"persona_gender",@"persona_age",nil]];
      if (eventInfo) {
        [personaInfo addEntriesFromDictionary:eventInfo];
      }
      
      BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_EVENT_PERSONA_NAME properties:personaInfo  screenName:nil withType:BO_CODIFIED];
      [self.eventManager capture:model];
    }];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

@end
