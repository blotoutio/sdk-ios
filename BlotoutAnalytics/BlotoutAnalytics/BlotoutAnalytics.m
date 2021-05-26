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
#import "BOASdkToServerFormat.h"
#import "BOSharedManager.h"
#import "BOEventsOperationExecutor.h"
#import "BOANetworkConstants.h"
#import "BONetworkEventService.h"

static id sBOASharedInstance = nil;

static NSString *sTestBlotoutKey = nil;
static NSString *sProdBlotoutKey = nil;

static BOOL isBOSDKInProductionMode = NO;

static BOOL staticIsDataCollectionEnabled = YES;
static BOOL staticIsNetworkSyncEnabled = YES;

@implementation BlotoutAnalytics

-(instancetype)init{
    self = [super init];
    if (self) {
        self.isEnabled = YES;
        self.isDataCollectionEnabled = YES;
        self.isNetworkSyncEnabled = YES;
        self.isDeveloperEventsEnabled = YES;
        self.isFunnelEventsEnabled = NO;
        self.isSegmentEventsEnabled = NO;
        self.isRetentionEventsEnabled = YES;
        
        //Set it to true only in debug mode, while testing very early alpha feature
        //Even any branch checking can't be done with this set to true
        //TODO: isDevModeEnabled must always be false when releasing production build
        //self.isDevModeEnabled = YES;
        
        self.isPayingUser = NO;
        self.isProductionMode = YES;
        
        self.sdkInitConfirmationSend = NO;
        self.sdkInitPendingEventLoader = [NSMutableArray array];
        
        [BlotoutFoundation sharedInstance].isEnabled = YES;
        [BlotoutFoundation sharedInstance].isDataCollectionEnabled = YES;
        [BlotoutFoundation sharedInstance].isNetworkSyncEnabled = YES;
        
        loadAsUIViewControllerBOFoundationCat();
        loadAsUIApplicationBOFoundationCat();
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
 * method to set dev mode state
 * @param isDevModeEnabled default is true, set false to disable the dev mode
 */
-(void)setIsDevModeEnabled:(BOOL)isDevModeEnabled{
    @try {
        //This is to prevent accidental enabling of feature
        //TODO: isDevModeEnabled must always be false when releasing production build
        //_isDevModeEnabled = isDevModeEnabled;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to set prod mode
 * @param isProductionMode default is true, set false to disable the production mode
 */
-(void)setIsProductionMode:(BOOL)isProductionMode{
    @try {
        if (!_isDevModeEnabled) {
            _isProductionMode = isProductionMode;
            isBOSDKInProductionMode = isProductionMode;
            [BlotoutFoundation sharedInstance].isProductionMode = isProductionMode;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @return bool status either SDK is running in prod mode or not
 */
+(BOOL)isSDKInProductionMode{
    @try {
        return isBOSDKInProductionMode;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return YES;
}

/**
 * @return Test env key string
 */
+(NSString*)blotoutSDKTestEnvKey{
    @try {
        return sTestBlotoutKey;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * @return Prod env key string
 */
+(NSString*)blotoutSDKProdEnvKey{
    @try {
        return sProdBlotoutKey;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
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

/**
 * @param payingUser default is false, set true to enable the payingUser analytics
 */
-(void)setPayingUser:(BOOL)payingUser{
    @try {
        _isPayingUser = payingUser;
        [BOASdkToServerFormat sharedInstance].isPayingUser = payingUser;
        if (payingUser) {
            [[BOACommunicatonController sharedInstance] postMessage:BO_ANALYTICS_IS_PAYING_USER withObject:[NSNumber numberWithBool:payingUser] andUserInfo:@{} asNotifications:YES];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)setSDKEndPointUrl:(NSString*)SDKEndPointUrl {
    @try {
        _SDKEndPointUrl = SDKEndPointUrl;
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

/**
 * @param isNetworkSyncEnabled default is true, set false to disable the Network call
 */
-(void)setIsNetworkSyncEnabled:(BOOL)isNetworkSyncEnabled{
    @try {
        staticIsNetworkSyncEnabled = isNetworkSyncEnabled;
        _isNetworkSyncEnabled = isNetworkSyncEnabled;
        
        [BOFNetworkPromiseExecutor sharedInstance].isNetworkSyncEnabled = isNetworkSyncEnabled;
        [BOFNetworkPromiseExecutor sharedInstanceForCampaign].isNetworkSyncEnabled = isNetworkSyncEnabled;
        [BlotoutFoundation sharedInstance].isNetworkSyncEnabled = isNetworkSyncEnabled;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param isDataCollectionEnabled default is true, set false to disable the Network call
 */
-(void)setIsDataCollectionEnabled:(BOOL)isDataCollectionEnabled{
    @try {
        staticIsDataCollectionEnabled = isDataCollectionEnabled;
        _isDataCollectionEnabled = isDataCollectionEnabled;
        
        [BOFFileSystemManager setIsDataWriteEnabled:isDataCollectionEnabled];
        [BlotoutFoundation sharedInstance].isDataCollectionEnabled = isDataCollectionEnabled;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param blotoutTestKey stage key as String
 * @param blotoutProductionKey production key as String
 */
-(void)updateAnalyticsEngineTest:(NSString*_Nonnull)blotoutTestKey andProduction:(NSString*_Nonnull)blotoutProductionKey{
    @try {
        if (blotoutTestKey) {
            self.testBlotoutKey = blotoutTestKey;
            sTestBlotoutKey = blotoutTestKey;
        }
        if (blotoutProductionKey) {
            self.prodBlotoutKey = blotoutProductionKey;
            sProdBlotoutKey = blotoutProductionKey;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)intiateGeoAPI {
    @try {
        //call geo location fetch api parallel
        [[BOAAppSessionEvents sharedInstance] getGeoIPAndPublishWith:^(NSDictionary * _Nonnull currentLocation, NSError * _Nullable error) {
        }];
    }@catch(NSException *exception){
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * this initializes the BlotoutAnalytics tracking configuration, it has to be called only once when the
 * application starts, for example in the Application Class.
 * @param blotoutTestKey stage key as String
 * @param blotoutProductionKey production key as String
 * @param isProdMode this param decides whether app work on production or stage mode
 */

-(void)initializeAnalyticsEngineUsingTest:(NSString*_Nonnull)blotoutTestKey andProduction:(NSString*_Nonnull)blotoutProductionKey inProductionMode:(BOOL)isProdMode withCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler{
    
    
    self.isProductionMode = isProdMode;
    __block BlotoutAnalytics *bSelf = self;
    
    //Confirm and perform 15 character length check if needed
    blotoutTestKey = [blotoutTestKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    blotoutProductionKey = [blotoutProductionKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!blotoutTestKey || [blotoutTestKey isEqualToString:@""] || !blotoutProductionKey || [blotoutProductionKey isEqualToString:@""] ) {
        NSError *initError = [NSError errorWithDomain:@"io.blotout.analytics" code:100002 userInfo:@{
            @"userInfo": @"Both test and production keys can't be empty"
            
        }];
        completionHandler(NO, initError);
        return;
    }
    
    self.testBlotoutKey = blotoutTestKey;
    sTestBlotoutKey = blotoutTestKey;
    self.prodBlotoutKey = blotoutProductionKey;
    sProdBlotoutKey = blotoutProductionKey;
    
    [self checkManifestAndInitAnalyticsWithCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        //This will buffer the event until is send & whole SDK is initialised
        [bSelf postPendingEvents];
        completionHandler(isSuccess, error);
    }];
}

-(void)initializeAnalyticsEngineUsingKey:(NSString*_Nonnull)blotoutSDKKey url:(NSString*_Nonnull)endPointUrl andCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler {
    self.isProductionMode = YES;
    __block BlotoutAnalytics *bSelf = self;
    //Confirm and perform 15 character length check if needed
    blotoutSDKKey = [blotoutSDKKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    endPointUrl = [endPointUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (!blotoutSDKKey || [blotoutSDKKey isEqualToString:@""] || !endPointUrl || [endPointUrl isEqualToString:@""] ) {
        NSError *initError = [NSError errorWithDomain:@"io.blotout.analytics" code:100002 userInfo:@{
            @"userInfo": @"Key and EndPoint Url can't be empty !"
            
        }];
        completionHandler(NO, initError);
        return;
    }
    
    self.prodBlotoutKey = blotoutSDKKey;
    sProdBlotoutKey = blotoutSDKKey;
    
    self.SDKEndPointUrl = endPointUrl;
    
    [self checkManifestAndInitAnalyticsWithCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        //This will buffer the event until is send & whole SDK is initialised
        [bSelf postPendingEvents];
        completionHandler(isSuccess, error);
    }];
    
}

/*This Method will process common funtionality for checking manifest with server and prepare sdk data**/
-(void)checkManifestAndInitAnalyticsWithCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler{
    
    @try {
        
        BOOL isSDKFirstLaunch = [BOFFileSystemManager isFirstLaunchBOSDKFileSystemCheck];
        BOASDKManifestController *sdkManifesCtrl = [BOASDKManifestController sharedInstance];
        if (isSDKFirstLaunch || ![sdkManifesCtrl isManifestAvailable]) {
            [self fetchManifest:^(BOOL isSuccess, NSError *error) {
                if(isSuccess) {
                    //use manifest controller and store manifest on sucess, else no purpose
                    [self prepareSDKForAnalyticsWithCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
                        completionHandler(isSuccess, error);
                        [self intiateGeoAPI];
                        [[BOAAppSessionEvents sharedInstance] postInitLaunchEventsRecording];
                        [BONetworkEventService sendSdkStartEvent];
                    }];
                    
                } else {
                    NSError *serverInitError = [NSError errorWithDomain:@"io.blotout.analytics" code:100003 userInfo:@{
                        @"userInfo": @"Server Sync failed, check your keys & network connection"}];
                    completionHandler(NO, serverInitError);
                }
            }];
        } else {
            [sdkManifesCtrl reloadManifestData];;
            [self prepareSDKForAnalyticsWithCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
                completionHandler(isSuccess, error);
                [self intiateGeoAPI];
                [[BOAAppSessionEvents sharedInstance] postInitLaunchEventsRecording];
                [[BOASDKManifestController sharedInstance] syncManifestWithServer];
                [BONetworkEventService sendSdkStartEvent];
            }];
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

-(void)prepareSDKForAnalyticsWithCompletionHandler:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler{
    @try {
        [BOAEvents initDefaultConfigurationWithHandler:^(BOOL isSuccess, NSError * _Nonnull error) {
            
            if (isSuccess) {
                [self setupManifestValues];
            }
            
            [[BOAAppSessionEvents sharedInstance] startRecordingEvnets];
            
            [[BOEventsOperationExecutor sharedInstance] dispatchGeoRetentionOperationInBackground:^{
                [[BOARetentionEvents sharedInstance] recordDAUwithPayload:nil];
                [[BOARetentionEvents sharedInstance] recordDPUwithPayload:nil];
                if ([BOFFileSystemManager isFirstLaunchBOSDKFileSystemCheck]) {
                    [[BOARetentionEvents sharedInstance] recordAppInstalled:YES withPayload:nil];
                    [[BOARetentionEvents sharedInstance] recordNewUser:YES withPayload:nil];
                    [BOFFileSystemManager setFirstLaunchBOSDKFileSystemCheckToFalse];
                }
            }];
            
            [[BOEventsOperationExecutor sharedInstance] dispatchDeviceOperationInBackground:^{
                [[BOADeviceEvents sharedInstance] recordDeviceEvents];
                [[BOADeviceEvents sharedInstance] recordMemoryEvents];
                [[BOADeviceEvents sharedInstance] recordNetworkEvents];
                [[BOADeviceEvents sharedInstance] recordStorageEvents];
                [[BOADeviceEvents sharedInstance] recordAdInformation];
            }];
            
            [[BOAPiiEvents sharedInstance]  startCollectingUserLocationEvent];
            
            [[BOEventsOperationExecutor sharedInstance] dispatchLifetimeOperationInBackground:^{
                BOALifeTimeAllEvent *sharedLifeTimeEvents = [BOALifeTimeAllEvent sharedInstance];
                [sharedLifeTimeEvents setAppLifeTimeSystemInfoOnAppLaunch];
            }];
            
            [[BOEventsOperationExecutor sharedInstance] dispatchFunnelEventsInBackground:^{
                [[BOAFunnelSyncController sharedInstanceFunnelController] prepareFunnnelSyncAndAnalyser];
            }];
            
            [[BOEventsOperationExecutor sharedInstance] dispatchSegmentEventsInBackground:^{
                [[BOASegmentsSyncController sharedInstanceSegmentSyncController] prepareSegmentsSyncAndAnalyser];
            }];
            
            [[BOEventsOperationExecutor sharedInstance] dispatchDeviceOperationInBackground:^{
                [BOFFileSystemManager deleteFilesRecursively:YES olderThanDays:[[BOASDKManifestController sharedInstance] getStoreInterval] underRootDirPath:[BOFFileSystemManager getBOSDKRootDirecoty] removalError:nil];
            }];
            
            completionHandler(isSuccess, error);
        }];
    } @catch (NSException *exception) {
        NSError *initError = [NSError errorWithDomain:@"io.blotout.analytics" code:100001 userInfo:exception.userInfo];
        BOFLogDebug(@"%@:%@", BOA_DEBUG, initError);
    }
}

-(void)setupManifestValues {
    if ([BOASDKManifestController sharedInstance].storageCutoffReached) {
        self.isEnabled = NO;
        [BOAAppSessionEvents sharedInstance].isEnabled = NO;
        [BOARetentionEvents sharedInstance].isEnabled = NO;
        [BOADeviceEvents sharedInstance].isEnabled = NO;
        [BOAPiiEvents sharedInstance].isEnabled = NO;
        [BOASegmentsSyncController sharedInstanceSegmentSyncController].isSegmentsEnabled = NO;
        [BOAFunnelSyncController sharedInstanceFunnelController].isFunnelEnabled = NO;
    }
    if (![BOASDKManifestController sharedInstance].storageCutoffReached) {
        //use developer interface to set developer preference on storageCutoffReached false state
        self.isEnabled = YES;
        [BOAAppSessionEvents sharedInstance].isEnabled = YES;
        [BOARetentionEvents sharedInstance].isEnabled = YES;
        [BOADeviceEvents sharedInstance].isEnabled = YES;
        [BOAPiiEvents sharedInstance].isEnabled = YES;
        [BOASegmentsSyncController sharedInstanceSegmentSyncController].isSegmentsEnabled = NO;
        [BOAFunnelSyncController sharedInstanceFunnelController].isFunnelEnabled = NO;
    }

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

#pragma mark - SDK Control Properties

-(void)setIsFunnelEventsEnabled:(BOOL)isFunnelEventsEnabled{
    @try {
        _isFunnelEventsEnabled = isFunnelEventsEnabled;
        [BOAFunnelSyncController sharedInstanceFunnelController].isFunnelEnabled = isFunnelEventsEnabled;
        [BlotoutFoundation sharedInstance].isFunnelEventsEnabled = isFunnelEventsEnabled;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param isSegmentEventsEnabled default is true, set false to disable segment execution
 */
-(void)setIsSegmentEventsEnabled:(BOOL)isSegmentEventsEnabled{
    @try {
        _isSegmentEventsEnabled = isSegmentEventsEnabled;
        [BOASegmentsSyncController sharedInstanceSegmentSyncController].isSegmentsEnabled = isSegmentEventsEnabled;
        if (isSegmentEventsEnabled) {
            [[BOASegmentsSyncController sharedInstanceSegmentSyncController] performSelectorInBackground:@selector(prepareSegmentsSyncAndAnalyser) withObject:nil];
        }else{
            [[BOASegmentsSyncController sharedInstanceSegmentSyncController] performSelectorInBackground:@selector(pauseSegmentsSyncAndAnalyser) withObject:nil];
        }
        
        [BlotoutFoundation sharedInstance].isSegmentEventsEnabled = isSegmentEventsEnabled;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param isRetentionEventsEnabled default is true, set false to disable retention events execution
 */
-(void)setIsRetentionEventsEnabled:(BOOL)isRetentionEventsEnabled{
    @try {
        _isRetentionEventsEnabled = isRetentionEventsEnabled;
        [BOARetentionEvents sharedInstance].isEnabled = isRetentionEventsEnabled;
        [BlotoutFoundation sharedInstance].isRetentionEventsEnabled = isRetentionEventsEnabled;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param isSystemEventsEnabled default is true, set false to disable device/system events execution
 */
-(void)setIsSystemEventsEnabled:(BOOL)isSystemEventsEnabled{
    @try {
        _isSystemEventsEnabled = isSystemEventsEnabled;
        [BOAAppSessionEvents sharedInstance].isEnabled = isSystemEventsEnabled;
        [BOADeviceEvents sharedInstance].isEnabled = isSystemEventsEnabled;
        [BOADeviceEvents sharedInstance].isEnabled = isSystemEventsEnabled;
        [BOAPiiEvents sharedInstance].isEnabled = isSystemEventsEnabled;
        
        [BlotoutFoundation sharedInstance].isSystemEventsEnabled = isSystemEventsEnabled;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param isDeveloperEventsEnabled default is true, set false to disable developer events execution
 */
-(void)setIsDeveloperEventsEnabled:(BOOL)isDeveloperEventsEnabled{
    @try {
        _isDeveloperEventsEnabled = isDeveloperEventsEnabled;
        [BOADeveloperEvents sharedInstance].isEnabled = isDeveloperEventsEnabled;
        [BlotoutFoundation sharedInstance].isDeveloperEventsEnabled = isDeveloperEventsEnabled;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}


#pragma mark - Log Event Methods
/*This method will post all pending that will capture before SDK initialization */
-(void)postPendingEvents{
    
    self.sdkInitConfirmationSend = YES;
    
    @try {
        if(self.sdkInitPendingEventLoader != nil && self.sdkInitPendingEventLoader.count>0) {
            for (BOPendingEvents *event in self.sdkInitPendingEventLoader) {
                switch (event.eventType) {
                    case BO_PENDING_EVENT_TYPE_SESSION:
                        [[BOADeveloperEvents sharedInstance] logEvent:event.eventName withInformation:event.eventInfo withEventCode:event.eventCode];
                        break;
                    case BO_PENDING_EVENT_TYPE_SESSION_WITH_TIME:
                        [self logEvent:event.eventName withInformation:event.eventInfo happendAt:event.eventTime];
                        break;
                    case BO_PENDING_EVENT_TYPE_PII:
                        [self logPIIEvent:event.eventName withInformation:event.eventInfo happendAt:event.eventTime];
                        break;
                    case BO_PENDING_EVENT_TYPE_PHI:
                        [self logPHIEvent:event.eventName withInformation:event.eventInfo happendAt:event.eventTime];
                        break;
                    case BO_PENDING_EVENT_TYPE_END_TIMED_EVENT:
                        [self endTimedEvent:event.eventName withInformation:event.eventInfo];
                        break;
                    case BO_PENDING_EVENT_TYPE_START_TIMED_EVENT:
                        [self startTimedEvent:event.eventName withInformation:event.eventInfo];
                        break;
                    case BO_PENDING_EVENT_TYPE_RETENTION_EVENT:
                        [self logUserRetentionEvent:event.eventName withInformation:event.eventInfo];
                        break;
                }
            }
            [self.sdkInitPendingEventLoader removeAllObjects];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param eventName name of the event
 * @param startEventInfo properties in key/value pair
 */
-(void)startTimedEvent:(NSString*)eventName withInformation:(NSDictionary*)startEventInfo{
    @try {
        if (self.isEnabled) {
            if (self.sdkInitConfirmationSend) {
                [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
                    if (startEventInfo) {
                        NSDictionary *userDataDict = [self replaceAllOccuranceOf:nil availableInDict:startEventInfo];
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents startTimedEvent:eventName withInformation:userDataDict];
                    }else{
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents startTimedEvent:eventName withInformation:startEventInfo];
                    }
                }];
            }else{
                [self addPendingEvents:eventName withEventType:BO_PENDING_EVENT_TYPE_START_TIMED_EVENT withInformation:startEventInfo withEventDate:NULL withEventCode:[NSNumber numberWithInt:0]];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param eventName name of the event
 * @param endEventInfo properties in key/value pair
 */
-(void)endTimedEvent:(NSString*)eventName withInformation:(NSDictionary*)endEventInfo{
    @try {
        if (self.isEnabled) {
            if (self.sdkInitConfirmationSend) {
                [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
                    if (endEventInfo) {
                        NSDictionary *userDataDict = [self replaceAllOccuranceOf:nil availableInDict:endEventInfo];
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents endTimedEvent:eventName withInformation:userDataDict];
                    }else{
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents endTimedEvent:eventName withInformation:endEventInfo];
                    }
                }];
            }else{
                [self addPendingEvents:eventName withEventType:BO_PENDING_EVENT_TYPE_END_TIMED_EVENT withInformation:endEventInfo withEventDate:NULL withEventCode:[NSNumber numberWithInt:0]];
            }
            
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param eventName name of the event
 * @param eventType type of event
 * @param eventInfo properties in key/value pair
 * @param eventTime time of event
 * @param eventCode code of event
 */
-(void)addPendingEvents:(NSString*)eventName withEventType:(int)eventType withInformation:(NSDictionary*)eventInfo withEventDate:(nullable NSDate *)eventTime withEventCode:(NSNumber*)eventCode {
    BOPendingEvents *pendingEvent = [[BOPendingEvents alloc] init];
    pendingEvent.eventInfo = eventInfo;
    pendingEvent.eventName = eventName;
    pendingEvent.eventType = eventType;
    pendingEvent.eventTime = eventTime;
    pendingEvent.eventCode = eventCode;
    [self.sdkInitPendingEventLoader addObject:pendingEvent];
}

/**
     *
     * @param userId any userid
     * @param provider e.g google, Mixpanel
     * @param eventInfo dictionary of events
     */
-(void)mapId:(nonnull NSString*)userId forProvider:(nonnull NSString*)provider withInformation:(nullable NSDictionary*)eventInfo{
    @try {
        //TODO: Discuss and Reivew whole below logic with Ankur
        NSMutableDictionary *mapIdInfo = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:userId, provider, eventInfo,nil] forKeys:[NSArray arrayWithObjects:BO_EVENT_MAP_ID, BO_EVENT_MAP_Provider,nil]];
        if(eventInfo) {
            [mapIdInfo addEntriesFromDictionary:eventInfo];
        }
        if (self.isEnabled) {
            if (self.sdkInitConfirmationSend) {
                [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
                    NSDictionary *userDataDict = [self replaceAllOccuranceOf:nil availableInDict:mapIdInfo];
                    BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                    [devEvents logEvent:BO_EVENT_MAP_ID withInformation:userDataDict withEventCode:[NSNumber numberWithInt:BO_DEV_EVENT_MAP_ID]];
                }];
            }else{
                [self addPendingEvents:BO_EVENT_MAP_ID withEventType:BO_EVENT_TYPE_SESSION withInformation:mapIdInfo withEventDate:NULL withEventCode:[NSNumber numberWithInt:BO_DEV_EVENT_MAP_ID]];
            }
            
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
-(void)logEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo{
    @try {
        if (self.isEnabled) {
            if (self.sdkInitConfirmationSend) {
                [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
                    if (eventInfo) {
                        NSDictionary *userDataDict = [self replaceAllOccuranceOf:nil availableInDict:eventInfo];
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents logEvent:eventName withInformation:userDataDict withEventCode:[NSNumber numberWithInt:0]];
                    }else{
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents logEvent:eventName withInformation:eventInfo withEventCode:[NSNumber numberWithInt:0]];
                    }
                }];
            }else{
                [self addPendingEvents:eventName withEventType:BO_PENDING_EVENT_TYPE_SESSION withInformation:eventInfo withEventDate:NULL withEventCode:[NSNumber numberWithInt:0]];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 *
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 * @param eventTime eventTime as Date
 *
 */
-(void)logPIIEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(NSDate*)eventTime{
    @try {
        if (self.isEnabled) {
            if (self.sdkInitConfirmationSend) {
                [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
                    if (eventInfo) {
                        NSDictionary *userDataDict = [self replaceAllOccuranceOf:nil availableInDict:eventInfo];
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents logPIIEvent:eventName withInformation:userDataDict happendAt:eventTime];
                    }else{
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents logPIIEvent:eventName withInformation:eventInfo happendAt:eventTime];
                    }
                }];
            }else{
                [self addPendingEvents:eventName withEventType:BO_PENDING_EVENT_TYPE_PII withInformation:eventInfo withEventDate:eventTime withEventCode:[NSNumber numberWithInt:0]];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 *
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 * @param eventTime eventTime as Date
 *
 */
-(void)logPHIEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(NSDate*)eventTime{
    @try {
        if (self.isEnabled) {
            if (self.sdkInitConfirmationSend) {
                [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
                    if (eventInfo) {
                        NSDictionary *userDataDict = [self replaceAllOccuranceOf:nil availableInDict:eventInfo];
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents logPHIEvent:eventName withInformation:userDataDict happendAt:eventTime];
                    }else{
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents logPHIEvent:eventName withInformation:eventInfo happendAt:eventTime];
                    }
                }];
            }else{
                [self addPendingEvents:eventName withEventType:BO_PENDING_EVENT_TYPE_PHI withInformation:eventInfo withEventDate:eventTime withEventCode:[NSNumber numberWithInt:0]];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * @param eventName name of the event as String
 * @param eventInfo properties in key/value pair
 * @param eventTime eventTime as Date
 */
-(void)logEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo happendAt:(NSDate*)eventTime {
    @try {
        if (self.isEnabled) {
            if (self.sdkInitConfirmationSend) {
                [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
                    if (eventInfo) {
                        NSDictionary *userDataDict = [self replaceAllOccuranceOf:nil availableInDict:eventInfo];
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents logEvent:eventName withInformation:userDataDict happendAt:eventTime];
                    }else{
                        BOADeveloperEvents *devEvents = [BOADeveloperEvents sharedInstance];
                        [devEvents logEvent:eventName withInformation:eventInfo happendAt:eventTime];
                    }
                }];
            }else{
                [self addPendingEvents:eventName withEventType:BO_PENDING_EVENT_TYPE_SESSION_WITH_TIME withInformation:eventInfo withEventDate:eventTime withEventCode:[NSNumber numberWithInt:0]];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}


-(void)logUserRetentionEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo{
    @try {
        if (self.isEnabled) {
            if (self.sdkInitConfirmationSend) {
                [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
                    if (eventInfo) {
                        NSDictionary *userDataDict = [self replaceAllOccuranceOf:nil availableInDict:eventInfo];
                        [[BOARetentionEvents sharedInstance] recordCustomEventsWithName:eventName andPaylod:userDataDict];
                        [[BOALifeTimeAllEvent sharedInstance] recordCustomEventsWithName:eventName andPaylod:userDataDict];
                        
                    }else{
                        [[BOARetentionEvents sharedInstance] recordCustomEventsWithName:eventName andPaylod:eventInfo];
                        [[BOALifeTimeAllEvent sharedInstance] recordCustomEventsWithName:eventName andPaylod:eventInfo];
                    }
                }];
            }else{
                [self addPendingEvents:eventName withEventType:BO_PENDING_EVENT_TYPE_RETENTION_EVENT withInformation:eventInfo withEventDate:NULL withEventCode:[NSNumber numberWithInt:0]];
            }
            
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

#pragma mark - Fraud Prevention services
-(BOOL)isDeviceCompromised{
    @try {
        return [BOADeviceAndAppFraudController isDeviceJailbroken];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(BOOL)isAppCompromised{
    @try {
        BOOL isDyLibInjected = [BOADeviceAndAppFraudController isDylibInjectedToProcessWithName:@"dylib_name"] && [BOADeviceAndAppFraudController isDylibInjectedToProcessWithName:@"libcycript"];
        return isDyLibInjected;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}
-(BOOL)isNetworkProxied{
    @try {
        BOOL isProxied = [BOADeviceAndAppFraudController isConnectionProxied];
        return isProxied;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(BOOL)isSimulator{
    @try {
#if TARGET_IPHONE_SIMULATOR
        BOFLogInfo(@"Current Model: %@", [[UIDevice currentDevice] model]);
        return YES;
#else
        BOFLogInfo(@"Current Model: %@", [[UIDevice currentDevice] model]);
        return NO;
#endif
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(BOOL)isRunningOnVM{
    return [self isSimulator];
}

-(BOOL)isEnvironmentSecure{
    @try {
        BOOL isDcom = [self isDeviceCompromised];
        BOOL isAcom = [self isAppCompromised];
        BOOL isProxied = [self isNetworkProxied];
        BOOL isSim = [self isSimulator];
        BOOL isVM = [self isRunningOnVM];
        
        return !(isDcom || isAcom || isProxied || isSim || isVM);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

@end
