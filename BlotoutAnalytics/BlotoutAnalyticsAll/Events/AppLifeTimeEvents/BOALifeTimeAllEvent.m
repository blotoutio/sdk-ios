//
//  BOALifeTimeAllEvent.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOALifeTimeAllEvent.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFSystemServices.h>
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import "BOAAppLifetimeData.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
#import "BlotoutAnalytics.h"
#include "BOANotificationConstants.h"
#import "BOAppSessionData.h"
#import "BOSharedManager.h"

static id sBOALifeTimeEventsSharedInstance = nil;

@interface BOALifeTimeAllEvent (){
    BOOL isOnLaunchMethodCalled;
}
@end

@implementation BOALifeTimeAllEvent

-(instancetype)init{
    self = [super init];
    if (self) {
        isOnLaunchMethodCalled = NO;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaLifeTimeEventsOnceToken = 0;
    dispatch_once(&boaLifeTimeEventsOnceToken, ^{
        sBOALifeTimeEventsSharedInstance = [[[self class] alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordPayingUsersRetention) name:BO_ANALYTICS_IS_PAYING_USER object:nil];
    });
    return  sBOALifeTimeEventsSharedInstance;
}

+(NSDictionary*)appLifeTimeDefaultSingleDayDict{
    @try {
        NSNumber *launchTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
        NSDictionary *singleDayDict =  @{
            @"sentToServer":[NSNumber numberWithBool:NO],
            @"dateAndTime":[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"],
            @"timeStamp": launchTimeStamp,
            @"appInstallInfo":NSNull.null,
            @"appUpdatesInfo":NSNull.null,
            @"appLaunchInfo":NSNull.null,
            @"blotoutSDKsInfo":NSNull.null,
            @"appLanguagesSupported":NSNull.null,
            @"appSupportShakeToEdit":NSNull.null,
            @"appSupportRemoteNotifications":NSNull.null,
            @"appCategory":NSNull.null,
            @"deviceInfo":@{
                    @"sentToServer":NSNull.null,
                    @"timeStamp": NSNull.null,
                    @"multitaskingEnabled": NSNull.null,
                    @"proximitySensorEnabled":NSNull.null,
                    @"debuggerAttached":NSNull.null,
                    @"pluggedIn":NSNull.null,
                    @"jailBroken":NSNull.null,
                    @"numberOfActiveProcessors":NSNull.null,
                    @"processorsUsage":NSNull.null,
                    @"accessoriesAttached":NSNull.null,
                    @"headphoneAttached":NSNull.null,
                    @"numberOfAttachedAccessories":NSNull.null,
                    @"nameOfAttachedAccessories":NSNull.null,
                    @"batteryLevelPercentage":NSNull.null,
                    @"isCharging":NSNull.null,
                    @"fullyCharged":NSNull.null,
                    @"deviceOrientation":NSNull.null,
                    @"deviceModel":NSNull.null,
                    @"deviceName":NSNull.null,
                    @"systemName":NSNull.null,
                    @"systemVersion":NSNull.null,
                    @"systemDeviceTypeUnformatted":NSNull.null,
                    @"systemDeviceTypeFormatted":NSNull.null,
                    @"deviceScreenWidth":NSNull.null,
                    @"deviceScreenHeight":NSNull.null,
                    @"appUIWidth":NSNull.null,
                    @"appUIHeight":NSNull.null,
                    @"screenBrightness":NSNull.null,
                    @"stepCountingAvailable":NSNull.null,
                    @"distanceAvailbale":NSNull.null,
                    @"floorCountingAvailable":NSNull.null,
                    @"numberOfProcessors":NSNull.null,
                    @"country":NSNull.null,
                    @"Language":NSNull.null,
                    @"timeZone":NSNull.null,
                    @"currency":NSNull.null,
                    @"clipboardContent":NSNull.null,
                    @"cfUUID":NSNull.null,
                    @"vendorID":NSNull.null,
                    @"doNotTrackEnabled":NSNull.null,
                    @"advertisingID":NSNull.null,
                    @"otherIDs":NSNull.null
            },
            @"networkInfo":NSNull.null,
            @"storageInfo":NSNull.null,
            @"memoryInfo":NSNull.null,
            @"location":@{
                    @"sentToServer":[NSNumber numberWithBool:NO],
                    @"timeStamp":launchTimeStamp,
                    @"piiLocation":@{
                            @"latitude":NSNull.null,
                            @"longitude":NSNull.null
                    },
                    @"nonPIILocation":@{
                            @"city":NSNull.null,
                            @"state":NSNull.null,
                            @"zip":NSNull.null,
                            @"country":NSNull.null,
                            @"activity":NSNull.null,
                            @"source":NSNull.null
                    }
            },
            @"retentionEvent":[self appLifeTimeDefaultRetentionInfo]
        };
        
        return singleDayDict;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDictionary*)appLifeTimeDefaultRetentionInfo{
    return @{
        @"sentToServer":[NSNumber numberWithBool:NO],
        @"DAU":NSNull.null,
        @"WAU":NSNull.null,
        @"MAU":NSNull.null,
        @"DPU":NSNull.null,
        @"WPU":NSNull.null,
        @"MPU":NSNull.null,
        @"appInstalled":NSNull.null,
        @"newUser":NSNull.null,
        @"DAST":NSNull.null,
        @"WAST":NSNull.null,
        @"MAST":NSNull.null,
        @"customEvents":NSNull.null
    };
}

-(void)setAppLifeTimeSystemInfoOnAppLaunch{
    @try {
        if (BOAEvents.isAppLifeModelInitialised) {
            Class klass = NSClassFromString(@"ASIdentifierManager");
            NSString *adStr = nil;
            BOOL isAdTrackingEnabled = NO;
            if (klass) {
                if ([klass respondsToSelector:@selector(sharedManager)]) {
                    id adManager = [klass performSelector:@selector(sharedManager)];
                    BOOL isAdTrackingEnabled = NO;
                    if ([adManager respondsToSelector:@selector(isAdvertisingTrackingEnabled)]) {
                        isAdTrackingEnabled = [adManager performSelector:@selector(isAdvertisingTrackingEnabled)];
                    }
                    if (isAdTrackingEnabled) {
                        if ([adManager respondsToSelector:@selector(advertisingIdentifier)]) {
                            NSUUID *adID = [adManager performSelector:@selector(advertisingIdentifier)];
                            adStr = [NSString stringWithFormat:@"%@",[adID UUIDString]];
                        }
                    }
                }
            }
            
            BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
            
            BOOL appLifeTimeRequireNewDayModelEntry = YES;
            if (lifeSessionModel) {
                if (lifeSessionModel.appLifeTimeInfo.count > 0) {
                    BOOL isSameDay = [BOAUtilities isDayMonthAndYearSameOfDate:[BOAUtilities getCurrentDate] andDateStr:lifeSessionModel.appLifeTimeInfo.lastObject.dateAndTime inFomrat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
                    if (isSameDay) {
                        appLifeTimeRequireNewDayModelEntry = NO;
                    }
                }
            }
            
            if (lifeSessionModel && appLifeTimeRequireNewDayModelEntry) {
                BOAAppLifeTimeInfo *singleDayInfo = [BOAAppLifeTimeInfo fromJSONDictionary:[[self class] appLifeTimeDefaultSingleDayDict]];
                isOnLaunchMethodCalled = YES;
                singleDayInfo.deviceInfo.doNotTrackEnabled = [NSNumber numberWithBool:!isAdTrackingEnabled];
                singleDayInfo.deviceInfo.advertisingID = NSNullifyCheck(adStr);
                singleDayInfo.deviceInfo.cfUUID = NSNullifyCheck([BOFSystemServices sharedServices].cfuuid);
                singleDayInfo.deviceInfo.vendorID = NSNullifyCheck([[UIDevice currentDevice].identifierForVendor UUIDString]);
                
                NSMutableArray<BOAAppLifeTimeInfo*> *appLifeTimeInfoArr = [lifeSessionModel.appLifeTimeInfo mutableCopy];
                [appLifeTimeInfoArr addObject:singleDayInfo];
                [lifeSessionModel setAppLifeTimeInfo:appLifeTimeInfoArr];
            }
            
            NSString *sessionDate = [BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"];
            [lifeSessionModel setDate:sessionDate];
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            [lifeSessionModel setAppBundle:bundleIdentifier];
            
            [self setLifeTimeRetentionEventsOnAppLaunch];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)setLifeTimeRetentionEventsOnAppLaunch{
    @try {
        if (BOAEvents.isAppLifeModelInitialised) {
            isOnLaunchMethodCalled = YES;
            BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
            
            BOADau *lifeDAU = lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.dau;
            if (!lifeDAU) {
                //Not setting this as it is being handled in daily session model object
                lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.dau = nil;
            }
            
            BOOL isNewValidWau = YES;
            for (NSUInteger wauCount = lifeSessionModel.appLifeTimeInfo.count; wauCount > 0; wauCount --) {
                NSUInteger wauCountArrIndex = wauCount - 1;
                BOAAppLifeTimeInfo *lifeTimeWauDayModel = [lifeSessionModel.appLifeTimeInfo objectAtIndex:wauCountArrIndex];
                BOAWau *wauEvent = lifeTimeWauDayModel.retentionEvent.wau;
                if (wauEvent) {
                    NSInteger lastWauWeekNumber = [BOAUtilities weekOfYearForDateInterval:[wauEvent.timeStamp integerValue]];
                    NSInteger currentWeekNumber = [BOAUtilities weekOfYear];
                    if (lastWauWeekNumber == currentWeekNumber) {
                        isNewValidWau = NO;
                        break;
                    }
                }
            }
            if (isNewValidWau) {
                BOAWau *wau = [BOAWau fromJSONDictionary:@{
                    @"sentToServer": [NSNumber numberWithBool:NO],
                    @"mid": [BOAUtilities getMessageIDForEvent:@"WAU"],
                    @"timeStamp": [BOAUtilities get13DigitNumberObjTimeStamp],
                    @"wauInfo": NSNull.null,
                    @"session_id":[BOSharedManager sharedInstance].sessionId
                }];
                lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.wau = wau;
            }
            
            //Ideally this should be just once as monthly file is getting created and then same file for whole month much have it
            BOOL isNewValidMau = YES;
            for (NSUInteger mauCount = lifeSessionModel.appLifeTimeInfo.count; mauCount > 0; mauCount --) {
                NSUInteger mauCountArrIndex = mauCount - 1;
                BOAAppLifeTimeInfo *lifeTimeMauDayModel = [lifeSessionModel.appLifeTimeInfo objectAtIndex:mauCountArrIndex];
                BOAMau *mauEvent = lifeTimeMauDayModel.retentionEvent.mau;
                if (mauEvent) {
                    NSInteger lastMauMonthNumber = [BOAUtilities monthOfYearForDateInterval:[mauEvent.timeStamp integerValue]];
                    NSInteger currentMonthNumber = [BOAUtilities monthOfYearForDateInterval:[BOAUtilities get13DigitIntegerTimeStamp]];
                    if (lastMauMonthNumber == currentMonthNumber) {
                        isNewValidMau = NO;
                        break;
                    }
                }
            }
            if (isNewValidMau) {
                BOAMau *mau = [BOAMau fromJSONDictionary:@{
                    @"sentToServer": [NSNumber numberWithBool:NO],
                    @"mid": [BOAUtilities getMessageIDForEvent:@"MAU"],
                    @"timeStamp": [BOAUtilities get13DigitNumberObjTimeStamp],
                    @"mauInfo": NSNull.null,
                    @"session_id":[BOSharedManager sharedInstance].sessionId
                }];
                lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.mau = mau;
            }
            
            if ([BlotoutAnalytics sharedInstance].isPayingUser) {
                [self recordPayingUsersRetention];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordPayingUsersRetention{
    
    BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
    //Daily, Weekly and Monthly paying users logic pending
    //==================================== WPU & MPU Logic ===================================
    BOOL isPayingUserEnabled = [BlotoutAnalytics sharedInstance].isPayingUser; //Set it as per flag set in Main BOAnalytics Class
    if (isPayingUserEnabled) {
        BOOL isNewValidWpu = YES;
        for (NSUInteger wpuCount = lifeSessionModel.appLifeTimeInfo.count; wpuCount > 0; wpuCount --) {
            NSUInteger wpuCountArrIndex = wpuCount - 1;
            BOAAppLifeTimeInfo *lifeTimeWpuDayModel = [lifeSessionModel.appLifeTimeInfo objectAtIndex:wpuCountArrIndex];
            BOAWpu *wpuEvent = lifeTimeWpuDayModel.retentionEvent.wpu;
            if (wpuEvent) {
                NSInteger lastWpuWeekNumber = [BOAUtilities weekOfYearForDateInterval:[wpuEvent.timeStamp integerValue]];
                NSInteger currentWeekNumber = [BOAUtilities weekOfYear];
                if (lastWpuWeekNumber == currentWeekNumber) {
                    isNewValidWpu = NO;
                    break;
                }
            }
        }
        if (isNewValidWpu) {
            BOAWpu *wpu = [BOAWpu fromJSONDictionary:@{
                @"sentToServer": [NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent:@"WPU"],
                @"timeStamp": [BOAUtilities get13DigitNumberObjTimeStamp],
                @"wpuInfo": NSNull.null,
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }];
            lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.wpu = wpu;
        }
        
        //Ideally this should be just once as monthly file is getting created and then same file for whole month much have it
        BOOL isNewValidMpu = YES;
        for (NSUInteger mpuCount = lifeSessionModel.appLifeTimeInfo.count; mpuCount > 0; mpuCount --) {
            NSUInteger mpuCountArrIndex = mpuCount - 1;
            BOAAppLifeTimeInfo *lifeTimeMpuDayModel = [lifeSessionModel.appLifeTimeInfo objectAtIndex:mpuCountArrIndex];
            BOAMPU *mpuEvent = lifeTimeMpuDayModel.retentionEvent.mpu;
            if (mpuEvent) {
                NSInteger lastMpuMonthNumber = [BOAUtilities monthOfYearForDateInterval:[mpuEvent.timeStamp integerValue]];
                NSInteger currentMonthNumber = [BOAUtilities monthOfYearForDateInterval:[BOAUtilities get13DigitIntegerTimeStamp]];
                if (lastMpuMonthNumber == currentMonthNumber) {
                    isNewValidMpu = NO;
                    break;
                }
            }
        }
        if (isNewValidMpu) {
            BOAMPU *mpu = [BOAMPU fromJSONDictionary:@{
                @"sentToServer": [NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent:@"MPU"],
                @"timeStamp": [BOAUtilities get13DigitNumberObjTimeStamp],
                @"mpuInfo": NSNull.null,
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }];
            lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.mpu = mpu;
        }
    }
    
}

-(void)recordIfAppFirstLaunch{
    @try {
        BOOL isSDKFirstLaunch = [BOFFileSystemManager isFirstLaunchBOSDKFileSystemCheck];
        //If it is not first SDK launch then can't be App launch
        if (BOAEvents.isAppLifeModelInitialised && isSDKFirstLaunch && isOnLaunchMethodCalled) {
            BOOL isAppFirstLaunch = [BOFFileSystemManager isAppFirstLaunchFileSystemChecks];
            if (isAppFirstLaunch) {
                //Check for reinstall case
                NSString *documentsDir = [BOFFileSystemManager getDocumentDirectoryPath];
                NSDictionary* docDirfileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:documentsDir error:nil];
                NSDate *documentsDirCrDate = [docDirfileAttribs fileCreationDate];
                
                BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
                BOAAppInstalled *appInstalled = [BOAAppInstalled fromJSONDictionary:@{
                    @"sentToServer":[NSNumber numberWithBool:NO],
                    @"mid": [BOAUtilities getMessageIDForEvent:@"AppInstalled"],
                    @"isFirstLaunch":[NSNumber numberWithBool:isAppFirstLaunch],
                    @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStampFor:documentsDirCrDate],
                    @"appInstalledInfo":NSNull.null,
                    @"session_id":[BOSharedManager sharedInstance].sessionId
                }];
                lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.appInstalled = appInstalled;
            }
            
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordNewUser{
    @try {
        if (BOAEvents.isAppLifeModelInitialised && isOnLaunchMethodCalled) {
            //Implement share file app logic also for devices available
            BOOL isNewUserInstallCheck = [BOFFileSystemManager isFirstLaunchBOSDKFileSystemCheck];
            if (isNewUserInstallCheck) {
                BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
                
                BOANewUser *newUser = [BOANewUser fromJSONDictionary:@{
                    @"sentToServer":[NSNumber numberWithBool:NO],
                    @"mid": [BOAUtilities getMessageIDForEvent:@"NewUser"],
                    @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                    @"isNewUser":[NSNumber numberWithBool:isNewUserInstallCheck],
                    @"newUserInfo": NSNull.null,
                    @"session_id":[BOSharedManager sharedInstance].sessionId
                }
                                       ];
                lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.theNewUser = newUser;
            }else{
                //Think about case when after 12 months, we want to check onboarding date
                //As first launch file might have been archived, so need to store new user on boarding time somewhere safely
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordDAST:(nullable NSNumber*)averageTimeDAST withPayload:(nullable NSDictionary*)eventInfo{
    @try {
        //Not setting this as it is being handled in daily session model object
        /*
         if (BOAEvents.isAppLifeModelInitialised && isOnLaunchMethodCalled) {
         id averageSessionInfo = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : NSNull.null;
         NSNumber *averageSessionTime = averageTime ? averageTime : [NSNumber numberWithUnsignedLongLong:0];
         BOAAST *dast = [BOAAST fromJSONDictionary:@{
         @"sentToServer":[NSNumber numberWithBool:NO],
         @"mid": [BOAUtilities getMessageIDForEvent:@"DAST"],
         @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
         @"averageSessionTime":averageSessionTime,
         @"dastInfo":averageSessionInfo,
         @"mastInfo":NSNull.null,
         @"wastInfo":NSNull.null
         }
         ];
         BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
         lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.dast = nil;
         }
         */
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(NSArray*)getAllSessionFilesForTheWeek:(NSInteger)weekOfYear{
    
    @try {
        NSArray *allSyncedSessionFile = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:[self getSyncedDirectoryPath]];
        NSArray *allNonSyncedSessionFile = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:[self getNotSyncedDirectoryPath]];
        
        NSMutableArray *syncedfilePathToConsider = [NSMutableArray array];
        NSMutableArray *nonSyncedfilePathToConsider = [NSMutableArray array];
        
        NSMutableArray *allfilePathToConsider = [NSMutableArray array];
        
        for (NSString *singleSyncedfilePath in allSyncedSessionFile) {
            NSString *fileName = [singleSyncedfilePath lastPathComponent];
            NSString *fileDate = [fileName stringByDeletingPathExtension];
            NSInteger fileWeekOfYear = [BOAUtilities weekOfYearForDate:[BOAUtilities dateStr:fileDate inFormat:@"yyyy-MM-dd"]];
            if (fileWeekOfYear == weekOfYear) {
                [syncedfilePathToConsider addObject:singleSyncedfilePath];
                [allfilePathToConsider addObject:singleSyncedfilePath];
            }
            BOFLogDebug(@"fileName-%@ && fileDate-%@",fileName,fileDate);
        }
        for (NSString *singleNonSyncedfilePath in allNonSyncedSessionFile) {
            NSString *fileName = [singleNonSyncedfilePath lastPathComponent];
            NSString *fileDate = [fileName stringByDeletingPathExtension];
            NSInteger fileWeekOfYear = [BOAUtilities weekOfYearForDate:[BOAUtilities dateStr:fileDate inFormat:@"yyyy-MM-dd"]];
            if (fileWeekOfYear == weekOfYear) {
                [nonSyncedfilePathToConsider addObject:singleNonSyncedfilePath];
                [allfilePathToConsider addObject:singleNonSyncedfilePath];
            }
            BOFLogDebug(@"fileName-%@ && fileDate-%@",fileName,fileDate);
        }
        return (allfilePathToConsider && (allfilePathToConsider.count > 0)) ? allfilePathToConsider : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSInteger)getWASTForTheWeek:(NSInteger)weekOfYear{
    
    @try {
        NSArray *allFilesPath = [self getAllSessionFilesForTheWeek:weekOfYear];
        if (!allFilesPath || (allFilesPath.count <= 0)) {
            return -1;
        }
        NSInteger totalWST = 0;
        NSInteger actualWAST = 0;
        for (NSString *singleFilePath in allFilesPath) {
            NSError *fileReadError = nil;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:singleFilePath withEncoding:NSUTF8StringEncoding andError:&fileReadError];
            if (jsonString && ![jsonString isEqualToString:@""]) {
                NSDictionary *singleSessionDic = [BOAUtilities jsonObjectFromString:jsonString];
                if (singleSessionDic) {
                    BOAppSessionData *appSessionData = [BOAppSessionData fromJSONDictionary:singleSessionDic];
                    //Daily avergae last object has proper average value so far
                    NSNumber *dailyAverage = appSessionData.singleDaySessions.appInfo.lastObject.averageSessionsDuration;
                    totalWST = totalWST + [dailyAverage integerValue];
                }
            }
        }
        //Devide by zero is not possible as check on top of function takes care of that
        actualWAST = totalWST / allFilesPath.count;
        return (actualWAST > 0) ? actualWAST : -1;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return -1;
}

+(NSArray*)getAllSessionFilesForTheMonth:(NSInteger)monthOfyear{
    @try {
        NSArray *allSyncedSessionFile = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:[self getSyncedDirectoryPath]];
        NSArray *allNonSyncedSessionFile = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:[self getNotSyncedDirectoryPath]];
        
        NSMutableArray *syncedfilePathToConsider = [NSMutableArray array];
        NSMutableArray *nonSyncedfilePathToConsider = [NSMutableArray array];
        
        NSMutableArray *allfilePathToConsider = [NSMutableArray array];
        
        for (NSString *singleSyncedfilePath in allSyncedSessionFile) {
            NSString *fileName = [singleSyncedfilePath lastPathComponent];
            NSString *fileDate = [fileName stringByDeletingPathExtension];
            NSInteger fileMonthOfYear = [BOAUtilities monthOfYearForDate:[BOAUtilities dateStr:fileDate inFormat:@"yyyy-MM-dd"]];
            if (fileMonthOfYear == monthOfyear) {
                [syncedfilePathToConsider addObject:singleSyncedfilePath];
                [allfilePathToConsider addObject:singleSyncedfilePath];
            }
            BOFLogDebug(@"fileName-%@ && fileDate-%@",fileName,fileDate);
        }
        for (NSString *singleNonSyncedfilePath in allNonSyncedSessionFile) {
            NSString *fileName = [singleNonSyncedfilePath lastPathComponent];
            NSString *fileDate = [fileName stringByDeletingPathExtension];
            NSInteger fileMonthOfYear = [BOAUtilities monthOfYearForDate:[BOAUtilities dateStr:fileDate inFormat:@"yyyy-MM-dd"]];
            if (fileMonthOfYear == monthOfyear) {
                [nonSyncedfilePathToConsider addObject:singleNonSyncedfilePath];
                [allfilePathToConsider addObject:singleNonSyncedfilePath];
            }
            BOFLogDebug(@"fileName-%@ && fileDate-%@",fileName,fileDate);
        }
        return (allfilePathToConsider && (allfilePathToConsider.count > 0)) ? allfilePathToConsider : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSInteger)getMASTForTheMonth:(NSInteger)monthOfyear{
    @try {
        NSArray *allFilesPath = [self getAllSessionFilesForTheMonth:monthOfyear];
        if (!allFilesPath || (allFilesPath.count <= 0)) {
            return -1;
        }
        NSInteger totalMST = 0;
        NSInteger actualMAST = 0;
        for (NSString *singleFilePath in allFilesPath) {
            NSError *fileReadError = nil;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:singleFilePath withEncoding:NSUTF8StringEncoding andError:&fileReadError];
            if (jsonString && ![jsonString isEqualToString:@""]) {
                NSDictionary *singleSessionDic = [BOAUtilities jsonObjectFromString:jsonString];
                if (singleSessionDic) {
                    BOAppSessionData *appSessionData = [BOAppSessionData fromJSONDictionary:singleSessionDic];
                    //Daily avergae last object has proper average value so far
                    NSNumber *dailyAverage = appSessionData.singleDaySessions.appInfo.lastObject.averageSessionsDuration;
                    totalMST = totalMST + [dailyAverage integerValue];
                }
            }
        }
        //Devide by zero is not possible as check on top of function takes care of that
        actualMAST = totalMST / allFilesPath.count;
        return (actualMAST > 0) ? actualMAST : -1;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return -1;
}

+(NSArray*)lastWeekAllFiles:(NSDate*)currentDate{
    @try {
        NSInteger weekOfYear = [BOAUtilities weekOfYearForDate:currentDate];
        NSInteger lastWeekOfYear = weekOfYear - 1;
        NSArray *allfilePathToConsider = (lastWeekOfYear >= 0) ? [self getAllSessionFilesForTheWeek:lastWeekOfYear] : nil;
        return allfilePathToConsider;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSInteger)lastWeekWAST:(NSDate*)currentDate{
    @try {
        NSInteger weekOfYear = [BOAUtilities weekOfYearForDate:currentDate];
        NSInteger lastWeekOfYear = weekOfYear - 1;
        NSInteger actualWAST = (lastWeekOfYear >= 0) ? [self getWASTForTheWeek:lastWeekOfYear] : -1;
        return actualWAST;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return -1;
}

+(NSArray*)lastMonthAllFiles:(NSDate*)currentDate{
    @try {
        NSInteger monthOfYear = [BOAUtilities monthOfYearForDate:currentDate];
        NSInteger lastMonthOfYear = monthOfYear - 1;
        NSArray *allfilePathToConsider = (lastMonthOfYear >= 0) ? [self getAllSessionFilesForTheMonth:lastMonthOfYear] : nil;
        return allfilePathToConsider;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSInteger)lastMonthMAST:(NSDate*)currentDate{
    @try {
        NSInteger monthOfYear = [BOAUtilities monthOfYearForDate:currentDate];
        NSInteger lastMonthOfYear = monthOfYear - 1;
        NSInteger actualMAST = (lastMonthOfYear >= 0) ? [self getMASTForTheMonth:lastMonthOfYear] : -1;
        return actualMAST;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return -1;
}

-(BOOL)isWASTAlreadySetForLastWeek{
    @try {
        BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
        BOOL isWASTAlreadySet = NO;
        //Reversing order loop will be better optimised in this case
        for (NSInteger wastIndex = (lifeSessionModel.appLifeTimeInfo.count - 2); wastIndex >=0; wastIndex --) {
            if ((wastIndex >= 0)) {
                BOAAppLifeTimeInfo *singleInfoLT =  [lifeSessionModel.appLifeTimeInfo objectAtIndex:wastIndex];
                BOOL isSameWeek = [BOAUtilities isWeekSameOfDate:[BOAUtilities dateStr:singleInfoLT.dateAndTime inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"] andDate2:[BOAUtilities getCurrentDate]];
                if (isSameWeek) {
                    if (singleInfoLT.retentionEvent.wast) {
                        isWASTAlreadySet = YES;
                        break;
                    }
                }else{
                    break;
                }
            }else{
                break;
            }
        }
        return isWASTAlreadySet;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return YES;
}


-(void)recordWAST:(nullable NSNumber*)averageTimeWAST withPayload:(nullable NSDictionary*)eventInfo{
    @try {
        if (BOAEvents.isAppLifeModelInitialised && isOnLaunchMethodCalled) {
            
            BOOL isWASTAlreadySet = [self isWASTAlreadySetForLastWeek];
            if (isWASTAlreadySet) {
                return;
            }
            
            NSInteger wastInt = [[self class] lastWeekWAST:[BOAUtilities getCurrentDate]];
            if (wastInt == -1) {
                return;
            }
            if ((eventInfo && (eventInfo.allKeys.count>0))) {
                NSMutableDictionary *newEventInfo = [eventInfo mutableCopy];
                [newEventInfo setObject:[BOAUtilities dateStringInFormat:nil] forKey:@"date"];
                eventInfo = newEventInfo;
            }
            id averageSessionInfo = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : NSNull.null;
            
            NSNumber *wastObject = [NSNumber numberWithInteger:wastInt];
            
            BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
            BOAAST *wast = [BOAAST fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent:@"WAST"],
                @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                @"averageSessionTime":wastObject,
                @"dastInfo":NSNull.null,
                @"mastInfo":NSNull.null,
                @"wastInfo":averageSessionInfo,
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }
                            ];
            
            lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.wast = wast;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/*
 -(void)recordWAST:(NSNumber*)averageTime withPayload:(nullable NSDictionary*)eventInfo{
 @try {
 if (BOAEvents.isAppLifeModelInitialised && isOnLaunchMethodCalled) {
 if ((eventInfo && (eventInfo.allKeys.count>0))) {
 NSMutableDictionary *newEventInfo = [eventInfo mutableCopy];
 [newEventInfo setObject:[BOAUtilities dateStringInFormat:nil] forKey:@"date"];
 eventInfo = newEventInfo;
 }
 id averageSessionInfo = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : NSNull.null;
 NSNumber *averageSessionTime = averageTime ? averageTime : [NSNumber numberWithUnsignedLongLong:0];
 
 unsigned long long wastTime = [averageSessionTime unsignedLongLongValue];
 //Second last Object wast + todays average will be this week wast if last Object belong to current week
 BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
 int secondLastIndex = (int)lifeSessionModel.appLifeTimeInfo.count - 2;
 if (secondLastIndex >= 0) {
 BOAAppLifeTimeInfo *secondLastLifeTimeInfo = [lifeSessionModel.appLifeTimeInfo objectAtIndex:secondLastIndex];
 NSDate *lastWeekDate = [BOAUtilities getDateWithTimeInterval:[secondLastLifeTimeInfo.retentionEvent.wast.timeStamp doubleValue]];
 BOOL isOfSameWeek = [BOAUtilities isWeekSameOfDate:lastWeekDate andDate2:[BOAUtilities getCurrentDate]];
 if (isOfSameWeek) {
 wastTime =  wastTime + [secondLastLifeTimeInfo.retentionEvent.wast.averageSessionTime unsignedLongLongValue];
 }
 }
 NSNumber *wastObject = [NSNumber numberWithUnsignedLongLong:wastTime];
 
 BOAAST *wast = [BOAAST fromJSONDictionary:@{
 @"sentToServer":[NSNumber numberWithBool:NO],
 @"mid": [BOAUtilities getMessageIDForEvent:@"WAST"],
 @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
 @"averageSessionTime":wastObject,
 @"dastInfo":NSNull.null,
 @"mastInfo":NSNull.null,
 @"wastInfo":averageSessionInfo
 }
 ];
 
 lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.wast = wast;
 }
 } @catch (NSException *exception) {
 BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
 }
 }
 */

-(BOOL)isMASTAlreadySetForLastMonth{
    @try {
        BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
        BOOL isMASTAlreadySet = NO;
        //Forward order loop will be better optimised in this case
        //As one mast for first launch in a month is set, it should never be set again
        //lifeSessionModel.appLifeTimeInfo.count - 2 : -2 because count -1 will be current day object
        for (NSInteger mastIndex = 0; mastIndex < lifeSessionModel.appLifeTimeInfo.count; mastIndex ++) {
            if ((mastIndex >= 0)) {
                BOAAppLifeTimeInfo *singleInfoLT =  [lifeSessionModel.appLifeTimeInfo objectAtIndex:mastIndex];
                //isSameMonth should be 100% true in all the cases as one file per month is maintained, still keeping it for safety until regression testing is done
                BOOL isSameMonth = [BOAUtilities isMonthSameOfDate:[BOAUtilities dateStr:singleInfoLT.dateAndTime inFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"] andDate2:[BOAUtilities getCurrentDate]];
                if (isSameMonth) {
                    if (singleInfoLT.retentionEvent.mast) {
                        isMASTAlreadySet = YES;
                        break;
                    }
                }else{
                    break;
                }
            }else{
                break;
            }
        }
        return isMASTAlreadySet;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return YES;
}

-(void)recordMAST:(nullable NSNumber*)averageTimeMAST withPayload:(nullable NSDictionary*)eventInfo{
    @try {
        if (BOAEvents.isAppLifeModelInitialised && isOnLaunchMethodCalled) {
            BOOL isMASTAlreadySet = [self isMASTAlreadySetForLastMonth];
            if (isMASTAlreadySet) {
                return;
            }
            NSInteger mastInt = [[self class] lastMonthMAST:[BOAUtilities getCurrentDate]];
            if (mastInt == -1) {
                return;
            }
            if ((eventInfo && (eventInfo.allKeys.count>0))) {
                NSMutableDictionary *newEventInfo = [eventInfo mutableCopy];
                [newEventInfo setObject:[BOAUtilities dateStringInFormat:nil] forKey:@"date"];
                eventInfo = newEventInfo;
            }
            id averageSessionInfo = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : NSNull.null;
            
            NSNumber *mastObject = [NSNumber numberWithInteger:mastInt];
            
            BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
            BOAAST *mast = [BOAAST fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent:@"MAST"],
                @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                @"averageSessionTime":mastObject,
                @"dastInfo":NSNull.null,
                @"mastInfo":averageSessionInfo,
                @"wastInfo":NSNull.null,
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }
                            ];
            
            lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.mast = mast;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/*
 -(void)recordMAST:(NSNumber*)averageTime withPayload:(nullable NSDictionary*)eventInfo{
 @try {
 if (BOAEvents.isAppLifeModelInitialised && isOnLaunchMethodCalled) {
 id averageSessionInfo = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : NSNull.null;
 NSNumber *averageSessionTime = averageTime ? averageTime : [NSNumber numberWithUnsignedLongLong:0];
 
 unsigned long long mastTime = [averageSessionTime unsignedLongLongValue];
 //Second last Object mast + todays average will be this week mast if last Object belong to current week
 BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
 int secondLastIndex = (int)lifeSessionModel.appLifeTimeInfo.count - 2;
 if (secondLastIndex >= 0) {
 BOAAppLifeTimeInfo *secondLastLifeTimeInfo = [lifeSessionModel.appLifeTimeInfo objectAtIndex:secondLastIndex];
 NSDate *lastWeekDate = [BOAUtilities getDateWithTimeInterval:[secondLastLifeTimeInfo.retentionEvent.mast.timeStamp doubleValue]];
 BOOL isOfSameMonth = [BOAUtilities isMonthSameOfDate:lastWeekDate andDate2:[BOAUtilities getCurrentDate]];
 if (isOfSameMonth) {
 mastTime =  mastTime + [secondLastLifeTimeInfo.retentionEvent.mast.averageSessionTime unsignedLongLongValue];
 }
 }
 NSNumber *mastObject = [NSNumber numberWithUnsignedLongLong:mastTime];
 
 BOAAST *mast = [BOAAST fromJSONDictionary:@{
 @"sentToServer":[NSNumber numberWithBool:NO],
 @"mid": [BOAUtilities getMessageIDForEvent:@"MAST"],
 @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
 @"averageSessionTime":mastObject,
 @"dastInfo":NSNull.null,
 @"mastInfo":averageSessionInfo,
 @"wastInfo":NSNull.null
 }
 ];
 
 lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.mast = mast;
 }
 } @catch (NSException *exception) {
 BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
 }
 }
 */

-(void)recordCustomEventsWithName:(NSString*)eventName andPaylod:(nullable NSDictionary*)eventInfo{
    @try {
        if (BOAEvents.isAppLifeModelInitialised && isOnLaunchMethodCalled) {
            id costumEventInfo = (eventInfo && (eventInfo.allKeys.count>0))  ? eventInfo : NSNull.null;
            
            BOACustomEvents *customEvents = [BOACustomEvents fromJSONDictionary:@{
                @"sentToServer":[NSNumber numberWithBool:NO],
                @"mid": [BOAUtilities getMessageIDForEvent:eventName],
                @"timeStamp":[BOAUtilities get13DigitNumberObjTimeStamp],
                @"eventInfo":costumEventInfo,
                @"eventName":eventName,
                @"visibleClassName" : [NSString stringWithFormat:@"%@",[[self topViewController] class]],
                @"session_id":[BOSharedManager sharedInstance].sessionId
            }
                                             ];
            
            BOAAppLifetimeData *lifeSessionModel = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:nil];
            lifeSessionModel.appLifeTimeInfo.lastObject.retentionEvent.customEvents = customEvents;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

@end
