//
//  BOASDKManifestController.m
//  BlotoutAnalytics
//
//  Created by Blotout on 16/11/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOASDKManifestController is Controller to fetch SDK config from server
 */

#import "BOASDKManifestController.h"
#import <BlotoutFoundation/BOFNetworkPromise.h>
#import <BlotoutFoundation/BOFNetworkPromiseExecutor.h>
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BlotoutAnalytics_Internal.h"
#import "BOANetworkConstants.h"
#import "BOManifestAPI.h"
#import "NSError+BOAdditions.h"
#import "BOEventsOperationExecutor.h"

static id sBOAsdkManifestSharedInstance = nil;

@interface BOASDKManifestController ()

@end

@implementation BOASDKManifestController

-(instancetype)init{
    self = [super init];
    if (self) {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        
        NSNumber *lastManifestSyncTimeStampInit = [analyticsRootUD objectForKey:BO_ANALYTICS_SDK_MANIFEST_LAST_TIMESTAMP_SYNC_DEFAULTS_KEY];
        if (!([lastManifestSyncTimeStampInit intValue] > 0)) {
            [analyticsRootUD setObject:@0 forKey:BO_ANALYTICS_SDK_MANIFEST_LAST_TIMESTAMP_SYNC_DEFAULTS_KEY];
        }
    }
    return self;
}

/**
 * method to get the singleton instance of the BOASDKManifestController object,
 * @return BOASDKManifestController instance
 */
+ (nullable instancetype)sharedInstance{
    static dispatch_once_t boaSDKManifestOnceToken = 0;
    dispatch_once(&boaSDKManifestOnceToken, ^{
        sBOAsdkManifestSharedInstance = [[[self class] alloc] init];
    });
    return  sBOAsdkManifestSharedInstance;
}

//set Default value when manifest success to load
-(void)setupManifestExtraParamOnSuccess {
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSNumber *currentTime = [BOAUtilities get13DigitNumberObjTimeStamp];
        [analyticsRootUD setObject:currentTime forKey:BO_ANALYTICS_SDK_MANIFEST_LAST_TIMESTAMP_SYNC_DEFAULTS_KEY];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * sync manifest and reload menifest data
 */
-(void)serverSyncManifestAndAppVerification:(void (^_Nullable) (BOOL isSuccess, NSError* error))callback{
    @try {
        [self fetchAndPrepareSDKModelWith:^(BOOL isSuccess, NSError *error) {
            
            if (isSuccess) {
                [self reloadManifestData];
                [self setupManifestExtraParamOnSuccess];
            }
            
            if (!self.sdkManifestModel) {
                NSError *manifestReadError = nil;
                BOASDKManifest *sdkManifestM = [BOASDKManifest fromJSON:[self latestSDKManifestJSONString] encoding:NSUTF8StringEncoding error:&manifestReadError];
                self.sdkManifestModel = sdkManifestM;
            }
            callback(isSuccess, error);
        }];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        callback(NO, [NSError boErrorForDict:exception.userInfo]);
    }
}

/**
 * method to get sdk manifest path
 * @return sdkManifestFilePath as string
 */
-(NSString*)latestSDKManifestPath{
    @try {
        NSString *fileName = @"sdkManifest";
        NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
        NSString *sdkManifestFilePath = [NSString stringWithFormat:@"%@/%@.txt",sdkManifestDir, fileName];
        return sdkManifestFilePath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get manifest json string
 * @return sdkManifestStr as string
 */
-(NSString*)latestSDKManifestJSONString{
    @try {
        NSString *sdkManifestFilePath = [self latestSDKManifestPath];
        NSError *fileReadError;
        NSString *sdkManifestStr = [BOFFileSystemManager contentOfFileAtPath:sdkManifestFilePath withEncoding:NSUTF8StringEncoding andError:&fileReadError];
        return sdkManifestStr;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get manifest path after writing
 * @param sdkManifest as String
 * @return sdkManifestFilePath as string
 */
-(NSString*)sdkManifestPathAfterWriting:(NSString*)sdkManifest{
    @try {
        if (sdkManifest && ![sdkManifest isEqualToString:@""] && ![sdkManifest isEqualToString:@"{}"] && ![sdkManifest isEqualToString:@"{ }"])     {
            NSString *sdkManifestFilePath = [self latestSDKManifestPath];
            if ([BOFFileSystemManager isFileExistAtPath:sdkManifestFilePath]) {
                NSError *removeError = nil;
                [BOFFileSystemManager removeFileFromLocationPath:sdkManifestFilePath removalError:&removeError];
            }
            
            NSError *error;
            //else file write operation and prapare new object
            [BOFFileSystemManager pathAfterWritingString:sdkManifest toFilePath:sdkManifestFilePath writingError:&error];
            
            return sdkManifestFilePath;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to fetch and prepare model for sdk manifest config
 */
-(void)fetchAndPrepareSDKModelWith:(void (^_Nullable) (BOOL isSuccess, NSError* error))callback{
    @try {
        
        BOManifestAPI *api = [[BOManifestAPI alloc] init];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        NSDictionary *manifestBody = @{
            @"lastUpdatedTime": @0 , //lastManifestSyncTimeStamp,
            // @0 will send as never synced and get whole manifest everytime, will implement partial fetch logic later
            @"bundleId": bundleIdentifier
        };
        NSData *manifestBodyData = [BOAUtilities jsonDataFrom:manifestBody withPrettyPrint:NO];
        
        [api getManifestDataModel:manifestBodyData success:^(id  _Nonnull responseObject, id  _Nonnull data) {
            
            if (responseObject) {
                BOASDKManifest *sdkManifestM = (BOASDKManifest*)responseObject;
                self.sdkManifestModel = sdkManifestM;
                NSString *manifestJSONStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [self sdkManifestPathAfterWriting:manifestJSONStr];
                self.isSyncedNow = YES;
                callback(YES, nil);
            }else{
                self.isSyncedNow = NO;
                callback(NO, nil);
            }
        } failure:^(NSError * _Nonnull error) {
            self.isSyncedNow = NO;
            callback(NO, error);
        }];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        callback(NO, [NSError boErrorForDict:exception.userInfo]);
    }
}

/**
 * method to get manifest variable
 * @param value as String
 * @return oneVar as BOASDKVariable
 */
-(BOASDKVariable*)getManifestVariable:(BOASDKManifest*)manifest forValue:(NSString*)value{
    @try {
        BOASDKVariable *oneVar = nil;
        for (BOASDKVariable *oneVariableDict in manifest.variables) {
            if (oneVariableDict != nil) {
                if ([oneVariableDict.variableName isEqualToString: value]) {
                    oneVar = oneVariableDict;
                    break;
                }
            }
        }
        return oneVar;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to manifest data
 */
-(void)reloadManifestData {
    @try {
        NSString *manifestStr = [self latestSDKManifestJSONString];
        if (!manifestStr) {
            return;
        }
        if (self.sdkManifestModel == nil && manifestStr != nil && ![manifestStr isEqualToString: @""]) {
            NSError *manifestReadError = nil;
            BOASDKManifest *sdkManifestM = [BOASDKManifest fromJSON: manifestStr encoding:NSUTF8StringEncoding error:&manifestReadError];
            self.sdkManifestModel = sdkManifestM;
        }
        if (self.sdkManifestModel != nil) {
           
            BOASDKVariable *deviceGrain = [self getManifestVariable:self.sdkManifestModel forValue: Event_DeviceInfoGrain];
            self.eventDeviceInfoGrain = [self getNumberFrom: deviceGrain.value];
            
            BOASDKVariable *serverBaseURL = [self getManifestVariable:self.sdkManifestModel forValue: Api_Endpoint];
            self.serverBaseURL = serverBaseURL.value;
            
            
            BOASDKVariable *eventPaths = [self getManifestVariable:self.sdkManifestModel forValue: EVENT_PATH];
            self.eventPath = eventPaths.value;
            
            BOASDKVariable *sdkPushSystemEvent = [self getManifestVariable:self.sdkManifestModel forValue: Event_Push_System_Events];
            if (sdkPushSystemEvent != nil) {
                self.sdkPushSystemEvents = [sdkPushSystemEvent.value boolValue];
            }
            
            BOASDKVariable *piiKey = [self getManifestVariable:self.sdkManifestModel forValue: Event_PII_Public_Key];
            if (piiKey != nil) {
                self.piiPublicKey = piiKey.value;
            }
            
            BOASDKVariable *phiKey = [self getManifestVariable:self.sdkManifestModel forValue: Event_PHI_Public_Key];
            if (phiKey != nil) {
                self.phiPublickey = phiKey.value;
            }
        
            
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(NSNumber *)getNumberFrom:(NSString *)string {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    return [f numberFromString: string];
}

/**
 * method to check weather manifest is available or not
 * @return status as BOOL
 */
-(BOOL)isManifestAvailable {
    @try {
        NSString *manifestStr = [self latestSDKManifestJSONString];
        if (manifestStr && ![manifestStr isEqualToString:@""]) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

@end
