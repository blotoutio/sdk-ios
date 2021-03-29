//
//  BlotoutAnalytics.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
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
#import "BONetworkEventService.h"
#import "BOASDKManifestController.h"
#import "BOAEventsManager.h"
#import "BOAFileStorage.h"
#import "BOAAESCrypto.h"
#import "BOAUserDefaultsStorage.h"

static id sBOASharedInstance = nil;

@implementation BlotoutAnalytics

-(instancetype)init{
    self = [super init];
    if (self) {
        self.isEnabled = YES;
        [BlotoutFoundation sharedInstance].isEnabled = YES;
        loadAsUIViewControllerBOFoundationCat();
        [BOSharedManager sharedInstance];
    }
    return self;
}

/**
 * public method to get the singleton instance of the BlotoutAnalytics object,
 * @return BlotoutAnalytics instance
 */
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
-(void)setIsEnabled:(BOOL)isEnabled{
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

- (void)setToken:(NSString *)token {
    @try {
        _token = token;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

//SDK Developer must use BOFLogInfo to show all message to outside of sdk
- (void)setIsSDKLogEnabled:(BOOL)isSDKLogEnabled {
    @try {
        _isSDKLogEnabled = isSDKLogEnabled;
        [BOFLogs sharedInstance].isSDKLogEnabled = isSDKLogEnabled;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}


-(void)init:(BlotoutAnalyticsConfiguration*)configuration andCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler {
    
    if (![self validateData:configuration]) {
        NSError *initError = [NSError errorWithDomain:@"io.blotout.analytics" code:100002 userInfo:@{
            @"userInfo": @"Key and EndPoint Url can't be empty !"
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
    
    [[BOEventsOperationExecutor sharedInstance] dispatchInitializationInBackground:^{
        [self checkManifestAndInitAnalyticsWithCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
            completionHandler(isSuccess, error);
        }];
    }];
    
}

/*This Method will process common funtionality for checking manifest with server and prepare sdk data**/
-(void)checkManifestAndInitAnalyticsWithCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler{
    
    @try {
        
        BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
        if (![sdkManifesCtrl isManifestAvailable]) {
            [self fetchManifest:^(BOOL isSuccess, NSError *error) {
                if(isSuccess) {
                    completionHandler(isSuccess, error);
                } else {
                    NSError *serverInitError = [NSError errorWithDomain:@"io.blotout.analytics" code:100003 userInfo:@{
                        @"userInfo": @"Server Sync failed, check your keys & network connection"}];
                    completionHandler(NO, serverInitError);
                }
            }];
        } else {
            [sdkManifesCtrl reloadManifestData];
            [[BOASDKManifestController sharedInstance] syncManifestWithServer];
            completionHandler(YES, nil);
        }
    }
    @catch (NSException *exception) {
        BOFLogInfo(@"%@:%@", BOA_DEBUG, exception);
        completionHandler(NO, [NSError boErrorForDict:exception.userInfo]);
    }
}

/**
 * This Method is used to fetch manifest values from the server
 */
-(void)fetchManifest:(void (^_Nullable) (BOOL isSuccess, NSError* error))callback{
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
    if(config.crypto) {
        return config.crypto;
    } else {
        BOAAESCrypto *crypto = [[BOAAESCrypto alloc] initWithPassword:[BOAUtilities getDeviceId] iv:BO_CRYPTO_IVX];
        return crypto;
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

-(void)registerApplicationStates {
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
}

- (void)handleAppStateNotification:(NSNotification *)note
{
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
- (void)_applicationWillTerminate
{
    [self.eventManager applicationWillTerminate];
}

- (void)_applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
}
- (void)_applicationWillEnterForeground
{
    [self capture:@"Application Opened" withInformation:@{
        @"from_background" : @YES,
    }];
}

- (void)_applicationDidEnterBackground
{
    [self capture: @"Application Backgrounded" withInformation:NULL];
    [self.eventManager applicationDidEnterBackground];
}

/**
 * @return sdk version
 */
-(NSString*)sdkVersion{
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
-(void)mapID:(nonnull NSString*)userId forProvider:(nonnull NSString*)provider withInformation:(nullable NSDictionary*)eventInfo{
    @try {
        if(self.isEnabled) {
            NSMutableDictionary *mapIdInfo = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:userId, provider,nil] forKeys:[NSArray arrayWithObjects:BO_EVENT_MAP_ID, BO_EVENT_MAP_Provider,nil]];
            if(eventInfo) {
                [mapIdInfo addEntriesFromDictionary:eventInfo];
            }
            
            BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_EVENT_MAP_ID properties:eventInfo eventCode:[NSNumber numberWithInt:BO_DEV_EVENT_MAP_ID]];
            [self.eventManager capture:model];
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(NSDictionary*)replaceAllOccuranceOf:(NSDate*)date availableInDict:(NSDictionary*)jsonDict{
    @try {
        NSMutableDictionary *jsonDictMutable = [jsonDict mutableCopy];
        NSArray *allKeys = [jsonDictMutable allKeys];
        for (NSString *key in allKeys) {
            id value = [jsonDictMutable objectForKey:key];
            if ([value isKindOfClass:[NSDate class]]) {
                NSString *dateStr = [BOAUtilities convertDate:value inFormat:nil];
                [jsonDictMutable removeObjectForKey:key];
                [jsonDictMutable setObject:dateStr forKey:key];
            }else if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]]){
                NSDictionary *newDict = [self replaceAllOccuranceOf:nil availableInDict:jsonDictMutable];
                [jsonDictMutable removeObjectForKey:key];
                [jsonDictMutable setObject:newDict forKey:key];
            }else if([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]){
                NSMutableArray *newArr = [NSMutableArray array];
                for (id arraySingleObj in value) {
                    if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                        NSDictionary *newDict1 = [self replaceAllOccuranceOf:nil availableInDict:jsonDictMutable];
                        [newArr addObject:newDict1];
                    }else if ([arraySingleObj isKindOfClass:[NSArray class]] || [arraySingleObj isKindOfClass:[NSMutableArray class]]) {
                        //this case of recurrsive arrays in not handled as it will require check for infite arrays in side arrays
                        //Just log this for informaton
                        BOFLogDebug(@"Debug:- ReplaceAllOccuranceOf_Handle it with more care");
                    }else if ([arraySingleObj isKindOfClass:[NSDate class]]) {
                        NSString *dateStrInner = [BOAUtilities convertDate:arraySingleObj inFormat:nil];
                        [newArr addObject:dateStrInner];
                    }
                }
                [jsonDictMutable removeObjectForKey:key];
                [jsonDictMutable setObject:newArr forKey:key];
            }
        }
        return jsonDictMutable;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * @param eventName name of the event
 * @param eventInfo properties in key/value pair
 */
-(void)capture:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo {
    @try {
        if (self.isEnabled) {
            BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:eventName properties:eventInfo eventCode:@(0)];
            [self.eventManager capture:model];
        }
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

-(void)capturePersonal:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo isPHI:(BOOL)phiEvent{
    @try {
        if (self.isEnabled) {
            BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:eventName properties:eventInfo eventCode:@(0)];
            [self.eventManager capturePersonal:model isPHI:phiEvent];
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(nullable NSString*)getUserId {
    return [BOAUtilities getDeviceId];
}

- (void)enable
{
    self.isEnabled = YES;
}

- (void)disable
{
    self.isEnabled = NO;
}

@end
