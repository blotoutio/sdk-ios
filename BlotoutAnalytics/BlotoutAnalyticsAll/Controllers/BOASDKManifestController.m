//
//  BOASDKManifestController.m
//  BlotoutAnalytics
//
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

-(instancetype)init {
  self = [super init];
  return self;
}

/**
 * method to get the singleton instance of the BOASDKManifestController object,
 * @return BOASDKManifestController instance
 */
+ (nullable instancetype)sharedInstance {
  static dispatch_once_t boaSDKManifestOnceToken = 0;
  dispatch_once(&boaSDKManifestOnceToken, ^{
    sBOAsdkManifestSharedInstance = [[[self class] alloc] init];
  });
  return sBOAsdkManifestSharedInstance;
}

/**
 * sync manifest and reload menifest data
 */
-(void)serverSyncManifestAndAppVerification:(void (^_Nullable) (BOOL isSuccess, NSError* error))callback {
  @try {
    [self fetchAndPrepareSDKModelWith:^(BOOL isSuccess, NSError *error) {
      if (isSuccess) {
        [self reloadManifestData];
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
-(NSString*)latestSDKManifestPath {
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
-(NSString*)latestSDKManifestJSONString {
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
-(NSString*)sdkManifestPathAfterWriting:(NSString*)sdkManifest {
  @try {
    if (!sdkManifest || [sdkManifest isEqualToString:@""] || [sdkManifest isEqualToString:@"{}"] || [sdkManifest isEqualToString:@"{ }"]) {
      return nil;
    }
    
    NSString *sdkManifestFilePath = [self latestSDKManifestPath];
    if ([BOFFileSystemManager isFileExistAtPath:sdkManifestFilePath]) {
      NSError *removeError = nil;
      [BOFFileSystemManager removeFileFromLocationPath:sdkManifestFilePath removalError:&removeError];
    }
    
    NSError *error;
    //else file write operation and prapare new object
    [BOFFileSystemManager pathAfterWritingString:sdkManifest toFilePath:sdkManifestFilePath writingError:&error];
    
    return sdkManifestFilePath;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

/**
 * method to fetch and prepare model for sdk manifest config
 */
-(void)fetchAndPrepareSDKModelWith:(void (^_Nullable) (BOOL isSuccess, NSError* error))callback {
  @try {
    BOManifestAPI *api = [[BOManifestAPI alloc] init];
    
    [api getManifestDataModel:^(id  _Nonnull responseObject, id  _Nonnull data) {
      if (!responseObject) {
        self.isSyncedNow = NO;
        callback(NO, nil);
        return;
      }
      
      BOASDKManifest *sdkManifestM = (BOASDKManifest*)responseObject;
      self.sdkManifestModel = sdkManifestM;
      NSString *manifestJSONStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      [self sdkManifestPathAfterWriting:manifestJSONStr];
      self.isSyncedNow = YES;
      callback(YES, nil);
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
 * @param ID as String
 * @return oneVar as BOASDKVariable
 */
-(BOASDKVariable*)getManifestVariable:(BOASDKManifest*)manifest forID:(int)ID {
  @try {
    BOASDKVariable *oneVar = nil;
    for (BOASDKVariable *oneVariableDict in manifest.variables) {
      if (oneVariableDict != nil && [oneVariableDict.variableID intValue] == ID) {
        oneVar = oneVariableDict;
        break;
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
    
    if (self.sdkManifestModel == nil) {
      return;
    }
    
    BOASDKVariable *systemEvents = [self getManifestVariable:self.sdkManifestModel forID:MANIFEST_SYSTEM_EVENTS];
    if (systemEvents != nil) {
      self.enabledSystemEvents = [systemEvents.value componentsSeparatedByString:@","];
    }
    
    BOASDKVariable *piiKey = [self getManifestVariable:self.sdkManifestModel forID:MANIFEST_PII_PUBLIC_KEY];
    if (piiKey != nil) {
      self.piiPublicKey = piiKey.value;
    }
    
    BOASDKVariable *phiKey = [self getManifestVariable:self.sdkManifestModel forID:MANIFEST_PHI_PUBLIC_KEY];
    if (phiKey != nil) {
      self.phiPublickey = phiKey.value;
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
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

-(BOOL)isSystemEventEnabled:(int)eventCode {
  if (self.enabledSystemEvents == nil) {
    return false;
  }
  
  return [self.enabledSystemEvents containsObject: [@(eventCode) stringValue]];
}

@end
