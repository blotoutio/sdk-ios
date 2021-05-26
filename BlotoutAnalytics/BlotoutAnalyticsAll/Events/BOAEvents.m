//
//  BOAEvents.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAEvents.h"
#import "BOALocalDefaultJSONs.h"
#import "BOAppSessionData.h"
#import "BOAAppLifetimeData.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAConstants.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import "BOAPostEventsDataJob.h"
#import "BOSharedManager.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOALifeTimeAllEvent.h"
#import "BOAAppSessionEvents.h"

//For day change reset
#import "BOARetentionEvents.h"
#import "BOADeviceEvents.h"
#import "BOAPiiEvents.h"
#import "BOASDKManifestController.h"
#import "NSError+BOAdditions.h"
#import "BOACommunicatonController.h"
#import "BOAFunnelSyncController.h"
#import "BOASegmentsSyncController.h"
#import "BOAFunnelSyncController.h"
#import "BOEventsOperationExecutor.h"

static BOAppSessionData *_appSessionModel = nil;
static BOAAppLifetimeData *_appLifeTimeModel = nil;
static BOOL _isSessionModelInitialised = NO;
static BOOL _isAppLifeModelInitialised = NO;

static NSTimeInterval delayInterval() {
    return [[BOASDKManifestController sharedInstance] delayInterval];
}

@interface BOAEvents (){
    UIViewController *topViewControllerName;
}
@property (class, nonatomic, strong) BOAppSessionData *appSessionModel;
@property (class, nonatomic, strong) BOAAppLifetimeData *appLifeTimeModel;
@property (class, nonatomic, readwrite)  BOOL isSessionModelInitialised;
@property (class, nonatomic, readwrite)  BOOL isAppLifeModelInitialised;
@end
@implementation BOAEvents

-(void)dealloc{
    @try {
        [[self class] cancelPreviousPerformRequestsWithTarget:[self class]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSCalendarDayChangedNotification object:nil];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+ (void)storePreviousDayAppInfoViaNotification:(nullable NSDictionary*)appSessionObject {
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSDictionary *singleDaySessions = [appSessionObject objectForKey:@"singleDaySessions"];
        NSArray <NSDictionary *> *appInfoArr = [singleDaySessions objectForKey:@"appInfo"];
        NSDictionary *appInfoDict = [appInfoArr lastObject];
        if (appInfoDict.allValues.count > 0) {
            NSString *appInfoDictStr = [BOAUtilities jsonStringFrom:appInfoDict withPrettyPrint:NO];
            [analyticsRootUD setObject:appInfoDictStr forKey:BO_ANALYTICS_ROOT_USER_DEFAULTS_PREVIOUS_DAY_APP_INFO];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(void)syncWithServerForFile:(NSString*)filePath{
    @try {
        NSDate *previousDate = [BOAUtilities getPreviousDayDateFrom:[BOAUtilities getCurrentDate]];
        NSString *fileName = [filePath lastPathComponent];
        NSString *fileNameWithoutExtention = [fileName stringByDeletingPathExtension];
        NSDate *fileDate = [BOAUtilities dateStr:fileNameWithoutExtention inFormat:@"yyyy-MM-dd"];
        
        BOOL isPreviousDate = [BOAUtilities isDate:fileDate lessThanEqualTo:previousDate];
        if (isPreviousDate) {
            BOAPostEventsDataJob *eventsJob = [[BOAPostEventsDataJob alloc] init];
            eventsJob.filePath = filePath;
            [[BOSharedManager sharedInstance].jobManager addOperation:eventsJob];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(void)syncWithServerAllFilesWithExtention:(NSString*)extention InDirectory:(NSString*)directoryPath{
    @try {
        NSString *syncedFiles = [self getSyncedDirectoryPath];
        if ([syncedFiles isEqualToString:directoryPath]) {
            return;
        }
        NSString *fileExtention = extention ? extention : @"txt";
        NSArray *allFile = [BOFFileSystemManager getAllFilesWithExtention:fileExtention fromDir:directoryPath];
        for (NSString *filePath in allFile) {
            [self syncWithServerForFile:filePath];
        }
        BOFLogDebug(@"%@", @"all files data sync to server complete");
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(void)syncRecursiveWithServerForSession:(BOAppSessionData*)sessionObject{
    @try {
        BOAPostEventsDataJob *eventsJob = [[BOAPostEventsDataJob alloc] init];
        eventsJob.sessionObject = self.appSessionModel;
        [[BOSharedManager sharedInstance].jobManager addOperation:eventsJob];
        [self syncWithServerAfterDelay:delayInterval() forSession:self.appSessionModel];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(void)syncWithServerAfterDelay:(NSTimeInterval)milliSeconds forSession:(BOAppSessionData*)sessionObject{
    @try {
    
        [[BOEventsOperationExecutor sharedInstance] dispatchSessionOperationInBackground:^{
            [self syncRecursiveWithServerForSession:sessionObject];
        } afterDelay:milliSeconds];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(NSString*)getSessionDirectoryPath{
    @try {
        NSString *rootDirectory = [BOFFileSystemManager getBOSDKRootDirecoty];
        NSString *sessionDataDir = [BOFFileSystemManager getChildDirectory:@"SessionData" byCreatingInParent:rootDirectory];
        return sessionDataDir;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)getSyncedDirectoryPath{
    @try {
        NSString *sessionDataDir = [self getSessionDirectoryPath];
        NSString *syncedFiles = [BOFFileSystemManager getChildDirectory:@"syncedFiles" byCreatingInParent:sessionDataDir];
        return syncedFiles;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)getNotSyncedDirectoryPath{
    @try {
        NSString *sessionDataDir = [self getSessionDirectoryPath];
        NSString *notSyncedFiles = [BOFFileSystemManager getChildDirectory:@"notSyncedFiles" byCreatingInParent:sessionDataDir];
        return notSyncedFiles;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(void)syncRecursiveWithServerForLifeTimeSession:(BOAAppLifetimeData*)lifeTimeSessionObject{
    @try {
        BOAPostEventsDataJob *eventsJob = [[BOAPostEventsDataJob alloc] init];
        eventsJob.lifetimeDataObject = self.appLifeTimeModel;
        [[BOSharedManager sharedInstance].jobManager addOperation:eventsJob];
        [self syncWithServerForLifeTimeSessionAfterDelay:delayInterval() forSession:self.appLifeTimeModel];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(void)syncWithServerForLifeTimeSessionAfterDelay:(NSTimeInterval)milliSeconds forSession:(BOAAppLifetimeData*)lifeTimeSessionObject{
    @try {
        [[BOEventsOperationExecutor sharedInstance] dispatchLifetimeOperationInBackground:^{
            [self syncRecursiveWithServerForLifeTimeSession:lifeTimeSessionObject];
        } afterDelay:milliSeconds];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(NSString*)getLifeTimeDirectoryPath{
    @try {
        NSString *rootDirectory = [BOFFileSystemManager getBOSDKRootDirecoty];
        NSString *sessionDataDir = [BOFFileSystemManager getChildDirectory:@"LifetimeData" byCreatingInParent:rootDirectory];
        return sessionDataDir;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)getLifeTimeDataSyncedDirectoryPath{
    @try {
        NSString *sessionDataDir = [self getLifeTimeDirectoryPath];
        NSString *syncedFiles = [BOFFileSystemManager getChildDirectory:@"syncedFiles" byCreatingInParent:sessionDataDir];
        return syncedFiles;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)getLifeTimeDataNotSyncedDirectoryPath{
    @try {
        NSString *sessionDataDir = [self getLifeTimeDirectoryPath];
        NSString *notSyncedFiles = [BOFFileSystemManager getChildDirectory:@"notSyncedFiles" byCreatingInParent:sessionDataDir];
        return notSyncedFiles;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)getStoreDASTUpdatedSessionStr{
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    NSString *appSessionModelStr = [analyticsRootUD objectForKey:BO_ANALYTICS_SESSION_MODEL_DEFAULTS_KEY];
    return appSessionModelStr;
}

+(void)initSuccessForAppDailySession:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler{
    
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        //Reason for BOAUtility isDayMonthAndYearSameOfDate exception
        //make addition check there
        NSString *appSessionModelStr = [analyticsRootUD objectForKey:BO_ANALYTICS_SESSION_MODEL_DEFAULTS_KEY];
        
        if (appSessionModelStr) {
            NSMutableDictionary *appSessionModelUD = [[BOALocalDefaultJSONs appSessionJSONDictFromJSONString:appSessionModelStr] mutableCopy];
            //verify date here
            NSString *dateString = [appSessionModelUD valueForKey:@"date"];
            //Add date check notification or observer as current implementation will work considering app closes and restart on every day
            //which is not practical, so close object write to file and recreate after 24 hours day cycle.
            
            //po dateString  0x00007fff50ba6f28
            //Below is fixing case when due to crash, proper date could not be set, this crash is specific on launch
            if (!dateString || [dateString isEqual:NSNull.null] || [dateString isEqualToString:@""] || [dateString containsString:@"0x00"] || (dateString.length != 10)) {
                dateString = [BOAUtilities dateStringInFormat:@"yyyy-MM-dd"];
                [appSessionModelUD setObject:dateString forKey:@"date"];
            }
            BOOL isSameDay = [BOAUtilities isDayMonthAndYearSameOfDate:[BOAUtilities getCurrentDate] andDateStr:dateString inFomrat:@"yyyy-MM-dd"];
            if(isSameDay) { //Compare day, month and year using AND condition. else if user launch App after one month then day is same and condition will be true. Same is applicable for year old user. I know year old user is not good business case but technically should be
                self.appSessionModel = [BOAppSessionData sharedInstanceFromJSONDictionary:appSessionModelUD];
                //If date is same then take directory path and check all previous date files which are not yet synced and move to synced folder after sync
                [self syncWithServerAllFilesWithExtention:@"txt" InDirectory:[self getNotSyncedDirectoryPath]];
                
                //Store Here and Retrive everywhere, as two places need this
                //this is for testing purpose as get's called in same day
                //[self storePreviousDayAppInfoViaNotification:appSessionModelUD];
            } else {
                
                //Store Here and Retrive everywhere, as two places need this
                //Currently this not used in any DAST calculation but if needed then move after 289 line number, require delay in sync testing as pmeta calculation might be delayed by few mili seconds
                [self storePreviousDayAppInfoViaNotification:appSessionModelUD];
                
                NSDictionary *singleDaySessions = [appSessionModelUD objectForKey:@"singleDaySessions"];
                NSArray <NSDictionary *> *appInfoArr = [singleDaySessions objectForKey:@"appInfo"];
                NSDictionary *appInfoDict = [appInfoArr lastObject];
                BOAppInfo *appInfoPrevious = nil;
                if (appInfoDict.allValues.count > 0) {
                    appInfoPrevious =  [BOAppInfo fromJSONDictionary:appInfoDict];
                }
                
                NSMutableArray *sessionDurations = [NSMutableArray array];
                for (NSDictionary *infoDict in appInfoArr) {
                    [sessionDurations addObject:[infoDict objectForKey:@"sessionsDuration"]];
                }
                [[BOARetentionEvents sharedInstance] recordDAST:[appInfoDict objectForKey:@"averageSessionsDuration"] forSession:appSessionModelUD withPayload:@{
                    @"sessionsCount": [NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:appInfoArr.count]],
                    @"sessionsDuration": [NSString stringWithFormat:@"%@",sessionDurations],
                }];
                
                [[BOACommunicatonController sharedInstance] postMessage:BO_ANALYTICS_ON_DAY_CHANGED withObject:appSessionModelUD andUserInfo:@{} asNotifications:YES];
                
                appSessionModelStr = [self getStoreDASTUpdatedSessionStr];
                appSessionModelUD = [[BOALocalDefaultJSONs appSessionJSONDictFromJSONString:appSessionModelStr] mutableCopy];
                //There should be check for data before writing, for the first run
                NSString *dateString = [appSessionModelUD valueForKey:@"date"];
                if(dateString && ![dateString isEqualToString:@""]) {
                    
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt",[self getNotSyncedDirectoryPath],dateString];
                    NSError *error;
                    //else file write operation and prapare new object
                    [BOFFileSystemManager pathAfterWritingString:appSessionModelStr toFilePath:filePath writingError:&error];
                    if(error == nil) {
                        //prepare operation manager and send data to server & convert data into server format
                        BOAPostEventsDataJob *eventsJob = [[BOAPostEventsDataJob alloc] init];
                        eventsJob.filePath = filePath;
                        [[BOSharedManager sharedInstance].jobManager addOperation:eventsJob];
                        //On success move file from notSyncedFiles to syncedFiles
                    } else {
                        //save in user defaults with date as key
                    }
                }
                //prepare new default sessionModel
                self.appSessionModel = [BOAppSessionData sharedInstanceFromJSONDictionary:[BOALocalDefaultJSONs appSessionJSONDict]];
            }
        }else{
            self.appSessionModel = [BOAppSessionData sharedInstanceFromJSONDictionary:[BOALocalDefaultJSONs appSessionJSONDict]];
            BOFLogDebug(@"BOEvents: 48: %@",self.appSessionModel);
        }
        
        self.isSessionModelInitialised = self.appSessionModel ? YES : NO;
        
        if (_isSessionModelInitialised) {
            NSTimeInterval delayIntervalMillies = delayInterval()*1000;
            NSInteger lastSyncTime = [self.appSessionModel.singleDaySessions.lastServerSyncTimeStamp integerValue];
            if(lastSyncTime == 0) {
                [self syncWithServerAfterDelay:BO_ANALYTICS_POST_INIT_NETWORK_DELAY forSession:self.appSessionModel];
            } else if ((lastSyncTime > 0) && (([BOAUtilities get13DigitIntegerTimeStamp] - lastSyncTime) >= delayIntervalMillies)) {
                [self syncWithServerAfterDelay:BO_ANALYTICS_POST_INIT_NETWORK_DELAY forSession:self.appSessionModel];
            }else{
                //Work on this for launch test and call for remaining time and go with full delay time
                long remainingDelay = delayIntervalMillies - ([BOAUtilities get13DigitIntegerTimeStamp] - lastSyncTime);
                remainingDelay = remainingDelay / 1000; //converted in seconds
                [self syncWithServerAfterDelay:remainingDelay forSession:self.appSessionModel];
            }
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dayChangeNotification:) name:NSCalendarDayChangedNotification object:nil];
            completionHandler(YES, nil);
        }else{
            [self syncWithServerAfterDelay:BO_ANALYTICS_POST_INIT_NETWORK_DELAY forSession:self.appSessionModel];
            completionHandler(NO, [NSError errorWithDomain:@"Init AppSession Model Domain" code:404 userInfo:nil]);
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        completionHandler(NO, [NSError boErrorForDict:exception.userInfo]);
    }
}

+(void)initSuccessForAppLifeSession:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler{
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSString *appLifeTimeModelStr = [analyticsRootUD objectForKey:BO_ANALYTICS_LIFETIME_MODEL_DEFAULTS_KEY];
        
        if (appLifeTimeModelStr) {
            NSMutableDictionary *appLifeTimeModelUD = [[BOALocalDefaultJSONs appSessionJSONDictFromJSONString:appLifeTimeModelStr] mutableCopy];
            
            NSString *date = [appLifeTimeModelUD valueForKey:@"date"];
            
            //po dateString  0x00007fff50ba6f28
            //Below is fixing case when due to crash, proper date could not be set, this crash is specific on launch
            if (!date || [date isEqual:NSNull.null] || [date isEqualToString:@""] || [date containsString:@"0x00"] || (date.length != 10)) {
                date = [BOAUtilities dateStringInFormat:@"yyyy-MM-dd"];
                [appLifeTimeModelUD setObject:date forKey:@"date"];
            }
            BOOL isSameMonth = [BOAUtilities isMonthAndYearSameOfDate:[BOAUtilities getCurrentDate] andDateStr:date inFormat:@"yyyy-MM-dd"]; //@"yyyy-MM-dd'T'HH:mm:ss.SSS"
            
            if (isSameMonth) {
                self.appLifeTimeModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:appLifeTimeModelUD];
                
                //Sync retention and monthly events now
                [self syncWithServerAllFilesWithExtention:@"txt" InDirectory:[self getLifeTimeDataNotSyncedDirectoryPath]];
                
            }else {
                //There should be check for data before writing, for the first run
                [[BOACommunicatonController sharedInstance] postMessage:BO_ANALYTICS_ON_MONTH_CHANGED withObject:appLifeTimeModelUD andUserInfo:@{} asNotifications:YES];
                
                NSString *dateL = [appLifeTimeModelUD valueForKey:@"date"];
                if(dateL && ![dateL isEqualToString:@""]) {
                    
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt",[self getLifeTimeDataNotSyncedDirectoryPath],dateL];
                    NSError *error;
                    //else file write operation and prapare new object
                    [BOFFileSystemManager pathAfterWritingString:appLifeTimeModelStr toFilePath:filePath writingError:&error];
                    if(error == nil) {
                        //prepare operation manager and send data to server & convert data into server format
                        //TODO: after initial testing uncomment for testing
                        BOAPostEventsDataJob *eventsJob = [[BOAPostEventsDataJob alloc] init];
                        eventsJob.filePathLifetimeData = filePath;
                        [[BOSharedManager sharedInstance].jobManager addOperation:eventsJob];
                        //On success move file from notSyncedFiles to syncedFiles
                    } else {
                        //save in user defaults with date as key
                    }
                }
                //prepare new default sessionModel
                self.appLifeTimeModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:[BOALocalDefaultJSONs appLifeTimeDataJSONDict]];
            }
        }else{
            self.appLifeTimeModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:[BOALocalDefaultJSONs appLifeTimeDataJSONDict]];
        }
        self.isAppLifeModelInitialised = self.appLifeTimeModel ? YES : NO;
        
        if (_isAppLifeModelInitialised) {
            
            NSTimeInterval delayIntervalMillies = delayInterval();
            NSInteger lastSyncTime = [self.appLifeTimeModel.lastServerSyncTimeStamp integerValue];
            if(lastSyncTime == 0) {
                [self syncWithServerForLifeTimeSessionAfterDelay:BO_ANALYTICS_POST_INIT_NETWORK_DELAY forSession:self.appLifeTimeModel];
            } else if ((lastSyncTime > 0) && (([BOAUtilities get13DigitIntegerTimeStamp] - lastSyncTime) >= delayIntervalMillies)) {
                [self syncWithServerForLifeTimeSessionAfterDelay:BO_ANALYTICS_POST_INIT_NETWORK_DELAY forSession:self.appLifeTimeModel];
            }else{
                // NSTimeInterval delayRemaing = (([BOAUtilities get13DigitIntegerTimeStamp] - lastSyncTime)/1000);
                //Work on this for launch test and call for remaining time and go with full delay time
                long remainingDelay = delayIntervalMillies - ([BOAUtilities get13DigitIntegerTimeStamp] - lastSyncTime);
                remainingDelay = remainingDelay / 1000; //converted in seconds
                [self syncWithServerForLifeTimeSessionAfterDelay:remainingDelay forSession:self.appLifeTimeModel];
            }
            completionHandler(YES, nil);
        }else{
            completionHandler(NO, [NSError errorWithDomain:@"Init AppLife Model Domain" code:404 userInfo:nil]);
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        completionHandler(NO, [NSError boErrorForDict:exception.userInfo]);
    }
}

+(void)dayChangeNotification:(NSNotification*)notification {
    @try {
        //send remaining data
        //TODO: fix the logic to work properly, logic fixed but test properly
        
        //    BOAPostEventsDataJob *eventsJob = [[BOAPostEventsDataJob alloc] init];
        //    eventsJob.sessionObject = self.appSessionModel;
        //    [[BOSharedManager sharedInstance].jobManager addOperation:eventsJob];
        //
        //    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        //
        //    NSString *appSessionModelStr = [analyticsRootUD objectForKey:BO_ANALYTICS_SESSION_MODEL_DEFAULTS_KEY];
        //
        //    if (appSessionModelStr) {
        //        NSMutableDictionary *appSessionModelUD = [[BOALocalDefaultJSONs appSessionJSONDictFromJSONString:appSessionModelStr] mutableCopy];
        //        //verify date here
        //        NSString *dateString = [appSessionModelUD valueForKey:@"date"];
        //
        //       NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt",[self getSyncedDirectoryPath],dateString];
        //        NSError *fileWriteError = nil;
        //        //else file write operation and prapare new object
        //        [BOFFileSystemManager pathAfterWritingString:appSessionModelStr toFilePath:filePath writingError:&fileWriteError];
        //    }
        
        // TODO: above todo completed, logic fixed as reset singleton was needed and other remaining functionality
        //TODO: testing after change pending
        
        [[BOAAppSessionEvents sharedInstance] appTerminationFunctionalityOnDayChange];
        
        self.appLifeTimeModel = nil;
        self.isAppLifeModelInitialised = NO;
        self.appSessionModel = nil;
        self.isSessionModelInitialised = NO;
        //Reset shared instance token, otherwise new object will not be created
        [BOAppSessionData resetDailySessionSharedInstanceToken];
        [BOAAppLifetimeData resetLifeTimeSharedInstanceToken];
        
        //Making change here, as logic seems doing wrong, if object for key is removed then in init function old session string won't be there & will not be saved
        //below initSuccessForAppDailySession function will do the job and on init call, old value will be saved into file and new will get created
        
        //Reset it like no object in user defaults as well.
        //BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        //[analyticsRootUD removeObjectForKey:BO_ANALYTICS_SESSION_MODEL_DEFAULTS_KEY];
        //[analyticsRootUD removeObjectForKey:BO_ANALYTICS_LIFETIME_MODEL_DEFAULTS_KEY];
        
        //prepare new default sessionModel
        //self.appSessionModel = [BOAppSessionData sharedInstanceFromJSONDictionary:[BOALocalDefaultJSONs appSessionJSONDict]];
        
        //One use case to test is, while reseting the object if new event comes in then what will happen:
        //1: if not yet creatd then get's associated with old one
        //2: if object is nil but new is not created then missed.
        //3: If new object created then fine.
        //- as in the reset function we are just reseting once token not setting object to nil.
        //- so until new object is created, old should remain alive and event miss case (2) seems invalid.
        [self initSuccessForAppDailySession:^(BOOL isSuccess, NSError * _Nullable error) {
            if (isSuccess) {
                [self initSuccessForAppLifeSession:^(BOOL isSuccess, NSError * _Nullable error) {
                    [self performSDKInitFunctionalityAsOnRelaunch];
                }];
            }else{
                
            }
        }];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(void)fetchManifestAndSetup:(BOOL)shouldFetch{
    BOASDKManifestController *sdkManifest = [BOASDKManifestController sharedInstance];
    if(shouldFetch) {
        [sdkManifest serverSyncManifestAndAppVerification:^(BOOL isSuccess, NSError * _Nonnull error) {
            //check for server sync and last day when happened
            if (isSuccess) {
                if (sdkManifest.storageCutoffReached) {
                    [BOAAppSessionEvents sharedInstance].isEnabled = NO;
                    [BOARetentionEvents sharedInstance].isEnabled = NO;
                    [BOADeviceEvents sharedInstance].isEnabled = NO;
                    [BOAPiiEvents sharedInstance].isEnabled = NO;
                    [BOASegmentsSyncController sharedInstanceSegmentSyncController].isSegmentsEnabled = NO;
                    [BOAFunnelSyncController sharedInstanceFunnelController].isFunnelEnabled = NO;
                }
                if (!sdkManifest.storageCutoffReached) {
                    [BOAAppSessionEvents sharedInstance].isEnabled = YES;
                    [BOARetentionEvents sharedInstance].isEnabled = YES;
                    [BOADeviceEvents sharedInstance].isEnabled = YES;
                    [BOAPiiEvents sharedInstance].isEnabled = YES;
                    [BOASegmentsSyncController sharedInstanceSegmentSyncController].isSegmentsEnabled = YES;
                    [BOAFunnelSyncController sharedInstanceFunnelController].isFunnelEnabled = YES;
                }
            }
        }];
    }else{
        if (sdkManifest.storageCutoffReached) {
            [BOAAppSessionEvents sharedInstance].isEnabled = NO;
            [BOARetentionEvents sharedInstance].isEnabled = NO;
            [BOADeviceEvents sharedInstance].isEnabled = NO;
            [BOAPiiEvents sharedInstance].isEnabled = NO;
            [BOASegmentsSyncController sharedInstanceSegmentSyncController].isSegmentsEnabled = NO;
            [BOAFunnelSyncController sharedInstanceFunnelController].isFunnelEnabled = NO;
        }
        if (!sdkManifest.storageCutoffReached) {
            [BOAAppSessionEvents sharedInstance].isEnabled = YES;
            [BOARetentionEvents sharedInstance].isEnabled = YES;
            [BOADeviceEvents sharedInstance].isEnabled = YES;
            [BOAPiiEvents sharedInstance].isEnabled = YES;
            [BOASegmentsSyncController sharedInstanceSegmentSyncController].isSegmentsEnabled = YES;
            [BOAFunnelSyncController sharedInstanceFunnelController].isFunnelEnabled = YES;
        }
    }
}


+(void)performSDKInitFunctionalityAsOnRelaunch{
    @try {
        
        BOASDKManifestController *sdkManifest = [BOASDKManifestController sharedInstance];
        if (sdkManifest.isManifestAvailable) {
            [self fetchManifestAndSetup:NO];
        }else{
            [self fetchManifestAndSetup:YES];
        }
        [[BOAAppSessionEvents sharedInstance] startRecordingEvnets];
        
        [[BOEventsOperationExecutor sharedInstance] dispatchGeoRetentionOperationInBackground:^{
            [[BOARetentionEvents sharedInstance] recordDAUwithPayload:nil];
            //@"DPU" right now just sending, later need logic for enable for some user vs another
            [[BOARetentionEvents sharedInstance] recordDPUwithPayload:nil];
            if ([BOFFileSystemManager isFirstLaunchBOSDKFileSystemCheck]) {
                [[BOARetentionEvents sharedInstance] recordAppInstalled:YES withPayload:nil];
                [[BOARetentionEvents sharedInstance] recordNewUser:YES withPayload:nil];
                [BOFFileSystemManager setFirstLaunchBOSDKFileSystemCheckToFalse];
            }
        }];
        
        [[BOEventsOperationExecutor  sharedInstance] dispatchDeviceOperationInBackground:^{
            [[BOADeviceEvents sharedInstance] recordDeviceEvents];
            [[BOADeviceEvents sharedInstance] recordMemoryEvents];
            [[BOADeviceEvents sharedInstance] recordNetworkEvents];
            [[BOADeviceEvents sharedInstance] recordStorageEvents];
        }];
        
        [[BOAPiiEvents sharedInstance]  startCollectingUserLocationEvent];
        
        [[BOEventsOperationExecutor sharedInstance] dispatchLifetimeOperationInBackground:^{
            BOALifeTimeAllEvent *sharedLifeTimeEvents = [BOALifeTimeAllEvent sharedInstance];
            [sharedLifeTimeEvents setAppLifeTimeSystemInfoOnAppLaunch];
        }];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(void)initDefaultConfigurationWithHandler:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler{
    @try {
        //    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        [self initSuccessForAppDailySession:^(BOOL isSuccess, NSError * _Nullable error) {
            if (isSuccess) {
                NSSetUncaughtExceptionHandler(&recordUncaughtExceptionHandler);
                [self initSuccessForAppLifeSession:^(BOOL isSuccess, NSError * _Nullable error) {
                    completionHandler(isSuccess, error);
                }];
            }else{
                completionHandler(isSuccess, error);
            }
        }];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        completionHandler(NO, [NSError boErrorForDict:exception.userInfo]);
    }
}

+(void)setAppLifeTimeModel:(BOAAppLifetimeData *)newAppLifeTimeModel{
    @try {
        if (newAppLifeTimeModel != _appLifeTimeModel) {
            _appLifeTimeModel = newAppLifeTimeModel;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(BOAAppLifetimeData*)appLifeTimeModel{
    @try {
        if (!_appLifeTimeModel) {
            BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
            NSMutableDictionary *appLifeTimeModelUD = [[analyticsRootUD objectForKey:BO_ANALYTICS_LIFETIME_MODEL_DEFAULTS_KEY] mutableCopy];
            if (appLifeTimeModelUD) {
                _appLifeTimeModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:appLifeTimeModelUD];
            }else{
                _appLifeTimeModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:[BOALocalDefaultJSONs appLifeTimeDataJSONDict]];
            }
        }
        return _appLifeTimeModel;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(void)setAppSessionModel:(BOAppSessionData *)newAppSessionModel{
    @try {
        if (newAppSessionModel != _appSessionModel) {
            _appSessionModel = newAppSessionModel;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}
+(BOAppSessionData*)appSessionModel{
    @try {
        if (!_appSessionModel) {
            BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
            NSMutableDictionary *appSessionModelUD = [[analyticsRootUD objectForKey:BO_ANALYTICS_SESSION_MODEL_DEFAULTS_KEY] mutableCopy];
            if (appSessionModelUD) {
                _appSessionModel = [BOAppSessionData sharedInstanceFromJSONDictionary:appSessionModelUD];
            }else{
                _appSessionModel = [BOAppSessionData sharedInstanceFromJSONDictionary:[BOALocalDefaultJSONs appSessionJSONDict]];
            }
        }
        return _appSessionModel;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}


+(void)setIsSessionModelInitialised:(BOOL)isSessionModelInitialised{
    @try {
        if (_isSessionModelInitialised != isSessionModelInitialised) {
            _isSessionModelInitialised = isSessionModelInitialised;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}
+(BOOL)isSessionModelInitialised{
    @try {
        return _isSessionModelInitialised;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(void)setIsAppLifeModelInitialised:(BOOL)isAppLifeModelInitialised{
    @try {
        if (_isAppLifeModelInitialised != isAppLifeModelInitialised) {
            _isAppLifeModelInitialised = isAppLifeModelInitialised;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(BOOL)isAppLifeModelInitialised{
    @try {
        return _isAppLifeModelInitialised;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        topViewControllerName = nil;
    }
    return self;
}

//TODO: check for main thread test and any impact
- (UIViewController *)topViewController{
    @try {
        if ([NSThread isMainThread]) {
            topViewControllerName = [BOAUtilities topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        }else{
            [self performSelectorOnMainThread:@selector(topViewController) withObject:nil waitUntilDone:YES];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return topViewControllerName;
}

void recordUncaughtExceptionHandler(NSException *exception) {
    @try {
        if (BOAEvents.isSessionModelInitialised) {
            BOCrashDetail *crashDetails = [BOCrashDetail fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent:@"AppCrashed"],
                @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                @"name":NSNullifyCheck(exception.name),
                @"reason":NSNullifyCheck(exception.reason),
                @"info":NSNullifyDictCheck(exception.userInfo),
                @"callStackSymbols":NSNullifyCheck([exception callStackSymbols]),
                @"callStackReturnAddress":NSNullifyCheck([exception callStackReturnAddresses]),
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }
                                           ];
            NSMutableArray *existingData = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.crashDetails mutableCopy];
            [existingData addObject:crashDetails];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setCrashDetails:existingData];
            
            BOAAppSessionEvents *appSessionEventL = [BOAAppSessionEvents sharedInstance];
            [appSessionEventL appTerminationFunctionalityOnDayChange];
            [[BOAFunnelSyncController sharedInstanceFunnelController] appWillTerminatWithInfo:nil];
            [[BOACommunicatonController sharedInstance] postMessage:BO_ANALYTICS_APP_TERMINATE_KEY withObject:@{} andUserInfo:@{} asNotifications:YES];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}


@end
