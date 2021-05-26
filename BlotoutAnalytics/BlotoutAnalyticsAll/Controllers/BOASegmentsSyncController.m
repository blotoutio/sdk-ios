//
//  BOASegmentsSyncController.m
//  BlotoutAnalytics
//
//  Created by Blotout on 27/12/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOASegmentsSyncController is class to fetch and sync segment to server
 */


#import "BOASegmentsSyncController.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import <BlotoutFoundation/BOFSystemServices.h>
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAppSessionData.h"
#import "BOAConstants.h"
#import "BOANotificationConstants.h"
#import "BOASegmentsResSegmentsPayload.h"
#import "BOASegmentEvents.h"
#import "BOASegmentsGetRequest.h"
#import "BOASegmentsExecutorHelper.h"
#import "BOADeviceAndAppFraudController.h"
#import "BOAAppSessionEvents.h"
#import "BOAppSessionData.h"
#import "BlotoutAnalytics_Internal.h"
#import "BOServerDataConverter.h"
#import "NSError+BOAdditions.h"
#import "BOANetworkConstants.h"
#import "BOSegmentAPI.h"
#import "NSError+BOAdditions.h"
#import "BOCommonEvents.h"

static id sBOASegmentsSharedInstance = nil;
#define STRING_SEPERATOR_FOR_FILE_NAME @"-"

#define EPAPostAPI @"POST"

@interface BOASegmentsSyncController (){
    BOOL isPrepareSegmentsSyncCalled;
    BOOL requestInProgress;
}
@property (nonatomic, strong) NSMutableArray <NSString*>*qualifiedSegments;
@property (nonatomic, strong) NSMutableArray <NSString*>*qualifiedSyncCompleteSegments;
@property (nonatomic, strong) NSDictionary *eventData;

@end

@implementation BOASegmentsSyncController

-(instancetype)init{
    self = [super init];
    if (self) {
        requestInProgress = NO;
        isPrepareSegmentsSyncCalled = NO;
        // [self prepareFunnnelSyncAndAnalyser];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareGeoData:) name:BO_ANALYTICS_APP_IP_LOCATION_RECEIVED_KEY object:self];
    }
    return self;
}

/**
 * method to get the singleton instance of the BOASegmentsSyncController object,
 * @return BOASegmentsSyncController instance
 */
+ (nullable instancetype)sharedInstanceSegmentSyncController{
    static dispatch_once_t boaSegmentsOnceToken = 0;
    dispatch_once(&boaSegmentsOnceToken, ^{
        sBOASegmentsSharedInstance = [[[self class] alloc] init];
    });
    return  sBOASegmentsSharedInstance;
}

/**
 * method to get substring from a string using separator
 * @param completeString as String
 * @param separator as String
 * @return array having sub string as NSArray
 */
-(NSArray*)subStringsFromString:(NSString*)completeString usingSeparator:(NSString*)separator{
    @try {
        return [completeString componentsSeparatedByString:separator];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get substring from a string using before separator
 * @param completeString as String
 * @param separator as String
 * @return substring as NSString
 */
-(NSString*)subStringFromString:(NSString*)completeString beforeSeparator:(NSString*)separator{
    @try {
        return [[completeString componentsSeparatedByString:separator] firstObject];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get substring from a string after separator
 * @param completeString as String
 * @param separator as String
 * @return substring as NSString
 */
-(NSString*)subStringFromString:(NSString*)completeString afterSeparator:(NSString*)separator{
    @try {
        return [[completeString componentsSeparatedByString:separator] lastObject];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get segment list that already qualified
 * @return segmentIDs as NSArray
 */
-(NSArray<NSString*>*)getListOfSegmentAlreadyQulified{
    @try {
        //Not considering offline case, in that date wise folder has to be created.
        //In current scenario, will create one folder, files name as segment id and daily sync will sync these and move to synced files
        NSString *segmentsSyncPendingDirPath = [BOFFileSystemManager getSessionBasedSegmentsEventsSyncPendingDirectoryPath];
        NSString *fileExtention = @"txt";
        NSArray *allFiles = [BOFFileSystemManager getAllFilesWithExtention:fileExtention fromDir:segmentsSyncPendingDirPath];
        NSMutableArray <NSString*>*segmentIDs = (allFiles.count > 0) ? [NSMutableArray array] : nil;
        for (NSString *filePath in allFiles) {
            NSString *completeFileName = [[filePath stringByDeletingPathExtension] lastPathComponent];
            NSString *segmentID = [self subStringFromString:completeFileName beforeSeparator:STRING_SEPERATOR_FOR_FILE_NAME];
            [segmentIDs addObject:segmentID];
        }
        self.qualifiedSegments = segmentIDs;
        return segmentIDs;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get segment list that already qualified and synced with server
 * @return segmentIDRootArrs as NSArray
 */
-(NSArray<NSString*>*)getListOfSegmentAlreadyQulifiedAndSyncedWithServer{
    @try {
        //Not considering offline case, in that date wise folder has to be created.
        //In current scenario, will create one folder, files name as segment id and daily sync will sync these and move to synced files
        NSString *segmentsSyncCompleteDirPath = [BOFFileSystemManager getSessionBasedSegmentsEventsSyncCompleteDirectoryPath];
        NSMutableArray <NSString*>*segmentIDRootArrs = [NSMutableArray array];
        NSArray *allDateFolders = [BOFFileSystemManager getAllDirsInside:segmentsSyncCompleteDirPath];
        
        NSArray *allSyncedSegmentFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:segmentsSyncCompleteDirPath];
        
        for (NSString *singleDateDir in allDateFolders) {
            NSString *fileExtention = @"txt";
            NSArray *allFiles = [BOFFileSystemManager getAllFilesWithExtention:fileExtention fromDir:singleDateDir];
            for (NSString *filePath in allFiles) {
                NSString *completeFileName = [[filePath stringByDeletingPathExtension] lastPathComponent];
                NSString *segmentID = [self subStringFromString:completeFileName beforeSeparator:STRING_SEPERATOR_FOR_FILE_NAME];
                [segmentIDRootArrs addObject:segmentID];
            }
        }
        self.qualifiedSyncCompleteSegments = segmentIDRootArrs;
        
        for (NSString *oneFilePath in allSyncedSegmentFiles) {
            NSString *completeFileName = [[oneFilePath stringByDeletingPathExtension] lastPathComponent];
            NSString *segmentID = [self subStringFromString:completeFileName beforeSeparator:STRING_SEPERATOR_FOR_FILE_NAME];
            [segmentIDRootArrs addObject:segmentID];
            [self.qualifiedSyncCompleteSegments addObject:segmentID];
        }
        
        return (segmentIDRootArrs.count > 0) ? segmentIDRootArrs : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to prepare segments sync and alalyser
 */
-(void)prepareSegmentsSyncAndAnalyser{
    @try {
        
        if (!self.isSegmentsEnabled) {
            return;
        }
        
        //strating point
        BOFLogInfo(@"prepareSegmentsSyncAndAnalyser - Segment sync launched");
        
        BOASegmentEvents *segmentEvents = nil;
        if (!isPrepareSegmentsSyncCalled) {
            segmentEvents = [self loadAllActiveSegments];
            if(segmentEvents){
                isPrepareSegmentsSyncCalled = YES;
            }
        }
        //TODO: Check logic and verify, only concern atm is, network is aync and this won't wait for new segments rather move to load existing one.
        //Fine for now
        [self performSelector:@selector(loadSegmentsNetworkScheduler) withObject:nil afterDelay:BO_ANALYTICS_POST_INIT_NETWORK_DELAY];
        [self serverSyncQualifiedSegment];
        [self startQualifyingAvailableSegment: segmentEvents];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to start qualifying all available segments
 * @param segmentEvents as BOASegmentEvents
 */
-(void)startQualifyingAvailableSegment:(BOASegmentEvents*)segmentEvents {
    for (int indx= 0; indx<segmentEvents.segments.count; indx++) {
        BOASegment *oneSegment = [segmentEvents.segments objectAtIndex:indx];
        
        //Don't check for prequalified segments
        NSArray *alreadyQualifiedSegs = [self getListOfSegmentAlreadyQulified];
        if ([alreadyQualifiedSegs containsObject:[NSString stringWithFormat:@"%@",oneSegment.identifier]]) {
            continue;
        }
        //Just funnel duplicate, may not be useful but decide after proper implementation. It just removes duplicate segment or better to say prevents duplicate segments to load
        BOOL isNewSegmentToLoad = YES;
        for (BOASegment *segTestIDEvent in segmentEvents.segments) {
            if ([segTestIDEvent.identifier isKindOfClass:[NSString class]]) {
                if ([[NSString stringWithFormat:@"%@",segTestIDEvent.identifier] isEqualToString:[NSString stringWithFormat:@"%@",oneSegment.identifier]]) {
                    isNewSegmentToLoad = NO;
                    break;
                }
            }else{
                if ([segTestIDEvent.identifier isEqualToNumber:oneSegment.identifier]) {
                    isNewSegmentToLoad = NO;
                    break;
                }
            }
        }
        
        //Load segment qualifier and test against qualification, check for already qualified segments and do not repeat
        BOOL doesQualify = [self doesUserQualifiesForSegment:oneSegment withSyncHappenedHandler:^(BOASegment *segmentQualified, NSError *error) {
            if (segmentQualified && !error) {
                [self userQualifiedForTheSegment:segmentQualified];
            }
        }];
        
        if (doesQualify) {
            [self userQualifiedForTheSegment:oneSegment];
        }
        //TODO:
        //Generate server response and save against segment ID... once qualified will not be tested on old data
        //If not qualified then next weekly data will be considered from the date of last test not qualified
    }
}

/**
 * method to update qualified segment for the user
 * @param segmentInfo as BOASegment
 */
-(void)userQualifiedForTheSegment:(BOASegment*)segmentInfo{
    @try {
        if (![self.qualifiedSegments containsObject:[NSString stringWithFormat:@"%@",segmentInfo.identifier]] ) {
            NSString *segmentsSyncPendingDirPath = [BOFFileSystemManager getSessionBasedSegmentsEventsSyncPendingDirectoryPath];
            NSString *fileExtention = @"txt";
            NSNumber *timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            
            NSString *segmentIDSyncPendingFilePath = [NSString stringWithFormat:@"%@/%@%@%@.%@",segmentsSyncPendingDirPath,segmentInfo.identifier, STRING_SEPERATOR_FOR_FILE_NAME,timeStamp,fileExtention];
            
            NSString *segName = [segmentInfo.name stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSDictionary *serverResponse = @{@"id":segmentInfo.identifier,
                                             @"event_time": [BOAUtilities get13DigitNumberObjTimeStamp],
                                             @"message_id": [BOAUtilities getMessageIDForEvent:[NSString stringWithFormat:@"Seg%@%@",segName,segmentInfo.createdTime] andIdentifier:segmentInfo.identifier]
            };
            
            BOASegmentsResSegmentsPayload *resPayload = [[BOASegmentsResSegmentsPayload alloc] init];
            resPayload.meta = [self prepareMetaData:nil];
            resPayload.geo = [self prepareGeoData:nil];
            BOASegmentsResSegment *segmentRes = [BOASegmentsResSegment fromJSONDictionary:serverResponse];
            resPayload.segments = @[segmentRes];
            
            NSError *jsonStrError = nil;
            NSString *serverResStr =  [resPayload toJSON:NSUTF8StringEncoding error:&jsonStrError];
            
            NSError *writeError;
            //else file write operation and prapare new object
            [BOFFileSystemManager pathAfterWritingString:serverResStr toFilePath:segmentIDSyncPendingFilePath writingError:&writeError];
            
            [self.qualifiedSegments addObject:[NSString stringWithFormat:@"%@",segmentInfo.identifier]];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)serverSyncQualifiedSegment{
    @try {
        NSString *segmentsSyncPendingDirPath = [BOFFileSystemManager getSessionBasedSegmentsEventsSyncPendingDirectoryPath];
        NSString *fileExtention = @"txt";
        NSArray *allFiles = [BOFFileSystemManager getAllFilesWithExtention:fileExtention fromDir:segmentsSyncPendingDirPath];
        
        for (NSString *oneFile in allFiles) {
            NSData *fileData = oneFile ? [NSData dataWithContentsOfFile:oneFile] : nil;
            if (fileData) {
                BOSegmentAPI *segmentAPI = [[BOSegmentAPI alloc] init];
                [segmentAPI postSegmentDataModel:fileData success:^(id  _Nonnull responseObject) {
                    
                    [[BOCommonEvents sharedInstance] recordSegmentTriggered];
                    
                    NSString *completeFileName = [[oneFile stringByDeletingPathExtension] lastPathComponent];
                    NSString *dateStampString = [self subStringFromString:completeFileName afterSeparator:STRING_SEPERATOR_FOR_FILE_NAME];
                    NSString *fileCreationDateStr = dateStampString ? [BOAUtilities convertDateStr:dateStampString inFormat:@"epoc"] : @"default";
                    if ([fileCreationDateStr isEqualToString:@"default"]) {
                        NSDate *fileCreationDate = [BOFFileSystemManager getCreationDateOfItemAtPath:oneFile];
                        fileCreationDateStr = fileCreationDate ? [BOAUtilities convertDate:fileCreationDate inFormat:nil] : @"default";
                    }
                    NSString *syncedPathDir = [BOFFileSystemManager getSessionBasedSegmentsEventsSyncCompleteDirectoryPath];
                    NSString *syncedPathDateDir = fileCreationDateStr ? [BOFFileSystemManager getChildDirectory:fileCreationDateStr byCreatingInParent:syncedPathDir] : nil;
                    if (syncedPathDateDir) {
                        NSError *relocationError = nil;
                        [BOFFileSystemManager moveFileFromLocationPath:oneFile toLocationPath:syncedPathDateDir relocationError:&relocationError];
                    }else if(syncedPathDir){
                        NSError *relocationError = nil;
                        [BOFFileSystemManager moveFileFromLocationPath:oneFile toLocationPath:syncedPathDir relocationError:&relocationError];
                    }
                } failure:^(NSError * _Nonnull error) {
                    
                }];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)pauseSegmentsSyncAndAnalyser{
    //strating point
    BOFLogDebug(@"prepareSegmentsSyncAndAnalyser - Segment sync launched");
}

-(NSDictionary*)prepareMetaDataDict:(BOAppSessionData*)sessionData {
    @try {
    
        NSDictionary *metaInfo = [BOServerDataConverter prepareMetaData];
        if((metaInfo != nil) && (metaInfo != NULL)) {
            return metaInfo;
        } else {
            return nil;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSDictionary*)prepareGeoDataDict:(BOAppSessionData*)sessionData {
    NSDictionary *geoDatas = [BOServerDataConverter prepareGeoData];
    if((geoDatas != nil) && (geoDatas != (id)[NSNull null])) {
        return geoDatas;
    } else {
        return nil;
    }
    return nil;
}

/**
 * method to prepare meta data
 * @param sessionData as BOAppSessionData
 * @return funnelMetaInfo as BOASegmentsResMeta
 */
-(BOASegmentsResMeta*)prepareMetaData:(BOAppSessionData*)sessionData {
    @try {
        BOASegmentsResMeta *funnelMetaInfo = [[BOASegmentsResMeta alloc] init];
        NSDictionary *metaInfo = [self prepareMetaDataDict:sessionData];
        funnelMetaInfo.plf = [metaInfo objectForKey:@"plf"];
        funnelMetaInfo.appn = [metaInfo objectForKey:@"appn"];
        funnelMetaInfo.dcomp = [metaInfo objectForKey:@"dcomp"];
        funnelMetaInfo.acomp = [metaInfo objectForKey:@"acomp"];
        funnelMetaInfo.osv = [metaInfo objectForKey:@"osv"];
        funnelMetaInfo.dmft = [metaInfo objectForKey:@"dmft"];
        funnelMetaInfo.dm = [metaInfo objectForKey:@"dm"];
        return funnelMetaInfo;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to prepare geo data
 * @param lastIPLocation as NSDictionary
 * @return geo as BOASegmentsResGeo
 */
-(BOASegmentsResGeo*)prepareGeoData:(NSDictionary*)lastIPLocation {
    @try {
        NSDictionary *geoInfo = [self prepareGeoDataDict:nil];
        return [BOASegmentsResGeo fromJSONDictionary:geoInfo];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(void)appLaunchedWithInfo:(NSDictionary*)launchInfo{
}

-(void)appInBackgroundWithInfo:(NSDictionary*)backgroudInfo{
}

-(void)appWillTerminatWithInfo:(NSDictionary*)terminationInfo{
}

-(NSString *)mappedSystemEventName:(NSString *)key{
    NSDictionary *event = [self systemEventsMapping];
    if([event objectForKey:key] != nil) {
        return [event objectForKey:key];
    }
    return key;
}

/**
 * method to all system events
 * @return eventData as NSDictionary
 */
-(NSDictionary *)systemEventsMapping {
    if((self.eventData == nil) || (self.eventData == NULL) || (self.eventData.allValues.count == 0)) {
        self.eventData = [[NSDictionary dictionary] initWithDictionary:@{
            @"App Launched": @"appLaunched",
            @"App Terminate": @"appResignActive",
            @"Session Start": @"appLaunched",
            @"Session End": @"appResignActive",
            @"App Background": @"appInBackground",
            @"App Foreground": @"appInForeground",
            @"Notification Received": @"appNotificationReceived",
            @"Notification Viewed": @"appNotificationViewed",
            @"Notification Clicked": @"appNotificationClicked",
            @"Portrait Orientation": @"appOrientationPortrait",
            @"Landscape Orientation": @"appOrientationLandscape",
            @"App Installed": @"",
            @"App Uninstalled": @"",
            @"Click/Tap": @"",
            @"Double Click/Double Tap": @"",
            @"View": @"",
            @"AppInstall Referrer": @"",
            @"Session Info":@"appSessionInfo"
        }];
    }
    return self.eventData;
}

/**
 * method to check weather user has qualified for segment or not
 * userid is symbolic reprentation for any user qualification, for now pass nil
 * @param segmentInfo as BOASegment
 * @return qualificationResult as BOOl
 */
-(BOOL)doesUserQualifiesForSegment:(BOASegment*)segmentInfo withSyncHappenedHandler:(void (^_Nullable) (BOASegment *segmentInfo, NSError* error))segmentSyncHandler{
    @try {
        BOOL qualificationResult = NO;
        BOOL userID = NO;
        if (userID) {
            //Fetch user data for qualification
        }else{
            //Fetch current user data for qualification, current user all session data and may be life time data if needed
            NSMutableDictionary *syncedLFTFilesResults = [self performTestOnSynedLifeTimeFilesForSegment:segmentInfo];
            NSMutableDictionary *nonSyncedLFTFilesResults = [self performTestOnNonSynedLifeTimeFilesForSegment:segmentInfo];
            NSMutableDictionary *syncedSessFilesResults = [self performTestOnSynedSessionFilesForSegment:segmentInfo];
            NSMutableDictionary *nonSyncedSessFilesResults = [self performTestOnNonSynedSessionFilesForSegment:segmentInfo];
            
            NSMutableDictionary *currentDaySessionData = [self performTestOnCurrentDaySessionDataForSegment:segmentInfo];
            NSArray *allImpKeys = [self allRuleKeysToCheckForFromSegment:segmentInfo.ruleset.rules];
            
            BOOL syncedLFTCheck1 = NO;
            if (syncedLFTFilesResults.allKeys.count == allImpKeys.count) {
                for (NSString *keyName in syncedLFTFilesResults.allKeys) {
                    //Don't loop for every key and it's JSON objects. For Segment to qualify all keys should be present in single JSON
                    NSDictionary *foundJSONForKey = [syncedLFTFilesResults objectForKey:keyName];
                    NSArray *allJSONsContsKey = [foundJSONForKey objectForKey:@"inDict"];
                    
                    //TODO:
                    //Build logic to check for segment qualification using partial JSON, what that mean is, scenario below:
                    // 1: key1 found in JSON 1, key2 Found in JSON 2, Key3 found in JOSN 3 ans Key4 found in JSON 4
                    // In current logic it won't quality as it will check all keys logic in sinle JSON, that's why current loop is waste of processing.
                    // For all keys in single JSON, find common JSONs and test the logic.
                    // For partial JSON, build logic to combine from partial data, not yet in place.
                    
                    //Corretion one1: Looping logic correction for performance improvement
                    //Corretion two2: Partial keys in single JSON and combine result for qualification.
                    //difficulty is find relevent keys in single JSON. like key1, key2, key3, key4, key5,key6... now key1 and key 2 has to be present in single JSON and key3 and key4 in single, if this combination is not found then not quaified or find alternate again
                    
                    for (NSDictionary *jsonDict in allJSONsContsKey) {
                        
                        //TODO:
                        //This logic is good when all keys are found in single JSON object then we don't need to loop as per above logic
                        //If keys are found in distributed set of JSON, one in this week data and another in another day or week JSON then below check will fail.
                        //Need to find solution
                        //Also build logic to store segment ID based JSON store, so that we don't loop again and again, check for fresh data only
                        syncedLFTCheck1 = [self checkForFromSegmentRules:segmentInfo.ruleset.rules withCondition:segmentInfo.ruleset.condition inJSONDict:jsonDict];
                        if (syncedLFTCheck1) {
                            break;
                        }
                    }
                    if (syncedLFTCheck1) {
                        break;
                    }
                }
            }
            
            BOOL syncedLFTCheck2 = NO;
            if (nonSyncedLFTFilesResults.allKeys.count == allImpKeys.count) {
                for (NSString *keyName in nonSyncedLFTFilesResults.allKeys) {
                    NSDictionary *foundJSONForKey = [nonSyncedLFTFilesResults objectForKey:keyName];
                    NSArray *allJSONsContsKey = [foundJSONForKey objectForKey:@"inDict"];
                    for (NSDictionary *jsonDict in allJSONsContsKey) {
                        syncedLFTCheck2 = [self checkForFromSegmentRules:segmentInfo.ruleset.rules withCondition:segmentInfo.ruleset.condition inJSONDict:jsonDict];
                        if (syncedLFTCheck2) {
                            break;
                        }
                    }
                    if (syncedLFTCheck2) {
                        break;
                    }
                }
            }
            
            BOOL syncedLFTCheck3 = NO;
            if (syncedSessFilesResults.allKeys.count == allImpKeys.count) {
                for (NSString *keyName in syncedSessFilesResults.allKeys) {
                    NSDictionary *foundJSONForKey = [syncedSessFilesResults objectForKey:keyName];
                    NSArray *allJSONsContsKey = [foundJSONForKey objectForKey:@"inDict"];
                    for (NSDictionary *jsonDict in allJSONsContsKey) {
                        syncedLFTCheck3 = [self checkForFromSegmentRules:segmentInfo.ruleset.rules withCondition:segmentInfo.ruleset.condition inJSONDict:jsonDict];
                        if (syncedLFTCheck3) {
                            break;
                        }
                    }
                    if (syncedLFTCheck3) {
                        break;
                    }
                }
            }
            
            BOOL syncedLFTCheck4 = NO;
            if (nonSyncedSessFilesResults.allKeys.count == allImpKeys.count) {
                for (NSString *keyName in nonSyncedSessFilesResults.allKeys) {
                    NSDictionary *foundJSONForKey = [nonSyncedSessFilesResults objectForKey:keyName];
                    NSArray *allJSONsContsKey = [foundJSONForKey objectForKey:@"inDict"];
                    for (NSDictionary *jsonDict in allJSONsContsKey) {
                        syncedLFTCheck4 = [self checkForFromSegmentRules:segmentInfo.ruleset.rules withCondition:segmentInfo.ruleset.condition inJSONDict:jsonDict];
                        if (syncedLFTCheck4) {
                            break;
                        }
                    }
                    if (syncedLFTCheck4) {
                        break;
                    }
                }
            }
            
            BOOL syncedLFTCheck5 = NO;
            if (currentDaySessionData.allKeys.count == allImpKeys.count) {
                for (NSString *keyName in currentDaySessionData.allKeys) {
                    NSDictionary *foundJSONForKey = [currentDaySessionData objectForKey:keyName];
                    NSArray *allJSONsContsKey = [foundJSONForKey objectForKey:@"inDict"];
                    for (NSDictionary *jsonDict in allJSONsContsKey) {
                        syncedLFTCheck5 = [self checkForFromSegmentRules:segmentInfo.ruleset.rules withCondition:segmentInfo.ruleset.condition inJSONDict:jsonDict];
                        if (syncedLFTCheck5) {
                            break;
                        }
                    }
                    if (syncedLFTCheck5) {
                        break;
                    }
                }
            }
            
            if (syncedLFTCheck1 || syncedLFTCheck2 || syncedLFTCheck3 || syncedLFTCheck4 || syncedLFTCheck5) {
                qualificationResult = YES;
            }
        }
        
        if (!qualificationResult) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                BOOL doesQualify = [self doesUserQualifiesForSegment:segmentInfo withSyncHappenedHandler:segmentSyncHandler];
                if (doesQualify) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doesUserQualifiesForSegment:withSyncHappenedHandler:) object:nil];
                    segmentSyncHandler(segmentInfo, nil);
                }
            });
        }
        return qualificationResult;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

/**
 * method to check from segment rules with given condition in json dictionaty
 * @param rulesObj as NSArray
 * @param condition as NSString
 * @param jsonDict as NSDictionary
 * @return bitwiseResult as BOOl
 */
-(BOOL)checkForFromSegmentRules:(NSArray<BOARule *>*)rulesObj withCondition:(NSString*)condition inJSONDict:(NSDictionary*)jsonDict{
    @try {
        BOASegmentsExecutorHelper *execHelper =  [BOASegmentsExecutorHelper sharedInstanceSegmentExeHelper];
        
        NSMutableArray <NSNumber*> *conditionalValue = [NSMutableArray array];
        for (BOARule *rule in rulesObj) {
            if (rule.segmentID && ([rule.segmentID intValue] > 0)) {
                //find stored segment by segment ID and check for qualification
                //[self doesUserQualifiesForSegment:nil];
            }else if(rule.rules){
                BOOL condResults = [self checkForFromSegmentRules:rule.rules withCondition:rule.condition inJSONDict:jsonDict];
                [conditionalValue addObject:[NSNumber numberWithBool:condResults]];
                BOFLogDebug(@"rule.rules-conditionalValue count", conditionalValue);
            }else{
                if ((rule.key && ![rule.key isEqualToString:@""] && rule.value && (rule.value.count > 0)) || (rule.eventName && ![rule.eventName isEqualToString:@""])) {
                    BOOL isTrue = [execHelper doesKey:rule.key conatainsValues:rule.value byOperator: [NSNumber numberWithInt:rule.operatorKey.intValue] inDict:jsonDict forEventName:[self mappedSystemEventName: rule.eventName]];
                    [execHelper resetSettings];
                    [conditionalValue addObject:[NSNumber numberWithBool:isTrue]];
                }
            }
        }
        
        BOOL bitwiseResult = NO;
        BOFLogDebug(@"rule.rules-conditionalValue count", conditionalValue);
        if (conditionalValue.count > 1) {
            BOOL bitwiseResult1 = [[conditionalValue objectAtIndex:0] boolValue];
            BOOL bitwiseResult2 = [[conditionalValue objectAtIndex:1] boolValue];
            bitwiseResult = [execHelper resultsOfBitwiseOperator:condition onResult1:bitwiseResult1 andResult2:bitwiseResult2];
            for (int ind = 2; ind < conditionalValue.count; ind++) {
                //Need parent object "condition":"AND" to pass below and test
                bitwiseResult = [execHelper resultsOfBitwiseOperator:condition onResult1:bitwiseResult andResult2:[[conditionalValue objectAtIndex:ind] boolValue]];
            }
        }else{
            bitwiseResult = [[conditionalValue lastObject] boolValue];
        }
        BOFLogDebug(@"return-bitwiseResult", bitwiseResult);
        return bitwiseResult;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}


/**
 * method to get all rule keys to check for from segment
 * @param rulesObj as NSArray
 * @return importantKeys as NSArray
 */
-(NSArray<NSString*>*)allRuleKeysToCheckForFromSegment:(NSArray<BOARule *>*)rulesObj{
    @try {
        NSMutableArray <NSString*> *importantKeys = [NSMutableArray array];
        for (BOARule *ruleX in rulesObj) {
            if (ruleX.rules) {
                NSArray *keysFromInner = [self allRuleKeysToCheckForFromSegment:ruleX.rules];
                [importantKeys addObjectsFromArray:keysFromInner];
            }else{
                if (ruleX.key && ![importantKeys containsObject:ruleX.key]) {
                    [importantKeys addObject:ruleX.key];
                }
                if (ruleX.eventName && ![importantKeys containsObject:ruleX.eventName]) {
                    [importantKeys addObject:ruleX.eventName];
                    [importantKeys addObject:[self mappedSystemEventName:ruleX.eventName]];
                }
            }
        }
        return importantKeys;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to perform test on synced life time files for segment
 * @param segmentInfo as BOASegment
 * @return keyCheckedResult as NSMutableDictionary
 */
-(NSMutableDictionary*)performTestOnSynedLifeTimeFilesForSegment:(BOASegment*)segmentInfo{
    @try {
        NSString *syncedPathLifeTime = [BOFFileSystemManager getSyncedFilesLifeTimeEventsDirectoryPath];
        NSArray *allSyncedFilesLifeTime = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:syncedPathLifeTime];
        
        BOASegmentsExecutorHelper *execHelper =  [BOASegmentsExecutorHelper sharedInstanceSegmentExeHelper];
        NSArray *allImportantKeys = [self allRuleKeysToCheckForFromSegment:segmentInfo.ruleset.rules];
        
        NSMutableDictionary *keyCheckedResult = [NSMutableDictionary dictionary];
        
        for (NSString *filePath in allSyncedFilesLifeTime) {
            NSError *fileReadError;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:filePath withEncoding:NSUTF8StringEncoding andError:&fileReadError];
            NSDictionary *fileJSONDict = [BOAUtilities jsonObjectFromString:jsonString];
            for (NSString *keyName in allImportantKeys) {
                BOOL isFound = [execHelper isKey:keyName foundIn:fileJSONDict];
                if (isFound) {
                    if ([[keyCheckedResult allKeys] containsObject:keyName]) {
                        NSMutableDictionary *existingDict = [[keyCheckedResult objectForKey:keyName] mutableCopy];
                        
                        NSMutableArray *exsitingDictArr = [existingDict objectForKey:@"inDict"];
                        [exsitingDictArr addObject:fileJSONDict];
                        [existingDict setObject:exsitingDictArr forKey:@"inDict"];
                        
                        NSMutableArray *exsitingPathArr = [existingDict objectForKey:@"filePath"];
                        [exsitingPathArr addObject:filePath];
                        [existingDict setObject:exsitingPathArr forKey:@"filePath"];
                        
                        [keyCheckedResult setObject:existingDict forKey:keyName];
                    }else{
                        [keyCheckedResult setObject:@{
                            @"isFound":[NSNumber numberWithBool:isFound],
                            @"inDict":@[fileJSONDict],
                            @"filePath":@[filePath]
                        } forKey:keyName];
                    }
                }
            }
        }
        return keyCheckedResult;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to perform test on non synced life time files for segment
 * @param segmentInfo as BOASegment
 * @return keyCheckedResult as NSMutableDictionary
 */
-(NSMutableDictionary*)performTestOnNonSynedLifeTimeFilesForSegment:(BOASegment*)segmentInfo{
    @try {
        NSString *notSyncedPathLifeTime = [BOFFileSystemManager getNotSyncedFilesLifeTimeEventsDirectoryPath];
        NSArray *allNotSyncedFilesLifeTime = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:notSyncedPathLifeTime];
        
        BOASegmentsExecutorHelper *execHelper =  [BOASegmentsExecutorHelper sharedInstanceSegmentExeHelper];
        NSArray *allImportantKeys = [self allRuleKeysToCheckForFromSegment:segmentInfo.ruleset.rules];
        
        NSMutableDictionary *keyCheckedResult = [NSMutableDictionary dictionary];
        
        for (NSString *filePath in allNotSyncedFilesLifeTime) {
            NSError *fileReadError;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:filePath withEncoding:NSUTF8StringEncoding andError:&fileReadError];
            NSDictionary *fileJSONDict = [BOAUtilities jsonObjectFromString:jsonString];
            for (NSString *keyName in allImportantKeys) {
                BOOL isFound = [execHelper isKey:keyName foundIn:fileJSONDict];
                if (isFound) {
                    if ([[keyCheckedResult allKeys] containsObject:keyName]) {
                        NSMutableDictionary *existingDict = [[keyCheckedResult objectForKey:keyName] mutableCopy];
                        
                        NSMutableArray *exsitingDictArr = [existingDict objectForKey:@"inDict"];
                        [exsitingDictArr addObject:fileJSONDict];
                        [existingDict setObject:exsitingDictArr forKey:@"inDict"];
                        
                        NSMutableArray *exsitingPathArr = [existingDict objectForKey:@"filePath"];
                        [exsitingPathArr addObject:filePath];
                        [existingDict setObject:exsitingPathArr forKey:@"filePath"];
                        
                        [keyCheckedResult setObject:existingDict forKey:keyName];
                    }else{
                        [keyCheckedResult setObject:@{
                            @"isFound":[NSNumber numberWithBool:isFound],
                            @"inDict":@[fileJSONDict],
                            @"filePath":@[filePath]
                        } forKey:keyName];
                    }
                }
            }
        }
        return keyCheckedResult;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to perform test on synced session files for segment
 * @param segmentInfo as BOASegment
 * @return keyCheckedResult as NSMutableDictionary
 */
-(NSMutableDictionary*)performTestOnSynedSessionFilesForSegment:(BOASegment*)segmentInfo{
    @try {
        NSString *syncedPathSessionTime = [BOFFileSystemManager getSyncedFilesSessionTimeEventsDirectoryPath];
        NSArray *allSyncedFilesSessionTime = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:syncedPathSessionTime];
        
        BOASegmentsExecutorHelper *execHelper =  [BOASegmentsExecutorHelper sharedInstanceSegmentExeHelper];
        NSArray *allImportantKeys = [self allRuleKeysToCheckForFromSegment:segmentInfo.ruleset.rules];
        
        NSMutableDictionary *keyCheckedResult = [NSMutableDictionary dictionary];
        
        for (NSString *filePath in allSyncedFilesSessionTime) {
            NSError *fileReadError;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:filePath withEncoding:NSUTF8StringEncoding andError:&fileReadError];
            NSDictionary *fileJSONDict = [BOAUtilities jsonObjectFromString:jsonString];
            for (NSString *keyName in allImportantKeys) {
                BOOL isFound = [execHelper isKey:keyName foundIn:fileJSONDict];
                if (isFound) {
                    if ([[keyCheckedResult allKeys] containsObject:keyName]) {
                        NSMutableDictionary *existingDict = [[keyCheckedResult objectForKey:keyName] mutableCopy];
                        
                        NSMutableArray *exsitingDictArr = [existingDict objectForKey:@"inDict"];
                        [exsitingDictArr addObject:fileJSONDict];
                        [existingDict setObject:exsitingDictArr forKey:@"inDict"];
                        
                        NSMutableArray *exsitingPathArr = [existingDict objectForKey:@"filePath"];
                        [exsitingPathArr addObject:filePath];
                        [existingDict setObject:exsitingPathArr forKey:@"filePath"];
                        
                        [keyCheckedResult setObject:existingDict forKey:keyName];
                    }else{
                        [keyCheckedResult setObject:@{
                            @"isFound":[NSNumber numberWithBool:isFound],
                            @"inDict":@[fileJSONDict],
                            @"filePath":@[filePath]
                        } forKey:keyName];
                    }
                }
            }
        }
        return keyCheckedResult;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to perform test on non synced session files for segment
 * @param segmentInfo as BOASegment
 * @return keyCheckedResult as NSMutableDictionary
 */
-(NSMutableDictionary*)performTestOnNonSynedSessionFilesForSegment:(BOASegment*)segmentInfo{
    @try {
        NSString *notSyncedPathSessionTime = [BOFFileSystemManager getNotSyncedFilesSessionTimeEventsDirectoryPath];
        NSArray *allNotSyncedFilesSessionTime = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:notSyncedPathSessionTime];
        
        BOASegmentsExecutorHelper *execHelper =  [BOASegmentsExecutorHelper sharedInstanceSegmentExeHelper];
        NSArray *allImportantKeys = [self allRuleKeysToCheckForFromSegment:segmentInfo.ruleset.rules];
        
        NSMutableDictionary *keyCheckedResult = [NSMutableDictionary dictionary];
        
        for (NSString *filePath in allNotSyncedFilesSessionTime) {
            NSError *fileReadError;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:filePath withEncoding:NSUTF8StringEncoding andError:&fileReadError];
            NSDictionary *fileJSONDict = [BOAUtilities jsonObjectFromString:jsonString];
            for (NSString *keyName in allImportantKeys) {
                BOOL isFound = [execHelper isKey:keyName foundIn:fileJSONDict];
                if (isFound) {
                    if ([[keyCheckedResult allKeys] containsObject:keyName]) {
                        NSMutableDictionary *existingDict = [[keyCheckedResult objectForKey:keyName] mutableCopy];
                        
                        NSMutableArray *exsitingDictArr = [existingDict objectForKey:@"inDict"];
                        [exsitingDictArr addObject:fileJSONDict];
                        [existingDict setObject:exsitingDictArr forKey:@"inDict"];
                        
                        NSMutableArray *exsitingPathArr = [existingDict objectForKey:@"filePath"];
                        [exsitingPathArr addObject:filePath];
                        [existingDict setObject:exsitingPathArr forKey:@"filePath"];
                        
                        [keyCheckedResult setObject:existingDict forKey:keyName];
                    }else{
                        [keyCheckedResult setObject:@{
                            @"isFound":[NSNumber numberWithBool:isFound],
                            @"inDict":@[fileJSONDict],
                            @"filePath":@[filePath]
                        } forKey:keyName];
                    }
                }
            }
        }
        return keyCheckedResult;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to perform test on current day session data for segment
 * @param segmentInfo as BOASegment
 * @return keyCheckedResult as NSMutableDictionary
 */
-(NSMutableDictionary*)performTestOnCurrentDaySessionDataForSegment:(BOASegment*)segmentInfo{
    @try {
        BOAppSessionData *currentDaySessionObj = nil;
        currentDaySessionObj = [BOAppSessionData sharedInstanceFromJSONDictionary:nil];
        NSDictionary *currentDaySessionDictObj = [currentDaySessionObj JSONDictionary];
        
        BOASegmentsExecutorHelper *execHelper =  [BOASegmentsExecutorHelper sharedInstanceSegmentExeHelper];
        NSArray *allImportantKeys = [self allRuleKeysToCheckForFromSegment:segmentInfo.ruleset.rules];
        
        NSMutableDictionary *keyCheckedResult = [NSMutableDictionary dictionary];
        for (NSString *keyName in allImportantKeys) {
            BOOL isFound = [execHelper isKey:keyName foundIn:currentDaySessionDictObj];
            if (isFound) {
                if ([[keyCheckedResult allKeys] containsObject:keyName]) {
                    NSMutableDictionary *existingDict = [[keyCheckedResult objectForKey:keyName] mutableCopy];
                    
                    NSMutableArray *exsitingDictArr = [[existingDict objectForKey:@"inDict"] mutableCopy];
                    [exsitingDictArr addObject:currentDaySessionDictObj];
                    [existingDict setObject:exsitingDictArr forKey:@"inDict"];
                    [keyCheckedResult setObject:existingDict forKey:keyName];
                }else{
                    [keyCheckedResult setObject:@{
                        @"isFound":[NSNumber numberWithBool:isFound],
                        @"inDict":@[currentDaySessionDictObj],
                        @"filePath":@[]
                    } forKey:keyName];
                }
            }
        }
        
        return keyCheckedResult;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to load all active segments
 * @return segments as BOASegmentEvents
 */
-(BOASegmentEvents*)loadAllActiveSegments{
    @try {
        NSString *fileExtention = @"txt";
        NSString *allSegmentsDirPath = [BOFFileSystemManager getAllSegmentsToAnalyseDirectoryPath];
        NSString *allSegmentsFilePath = [NSString stringWithFormat:@"%@/%@.%@",allSegmentsDirPath,@"AllSegments",fileExtention];
        NSError *fileReadingError;
        NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:allSegmentsFilePath withEncoding:NSUTF8StringEncoding andError:&fileReadingError];
        NSError *paringError;
        BOASegmentEvents *segments = nil;
        if (jsonString && ![jsonString isEqualToString:@""]) {
            segments = [BOASegmentEvents fromJSON:jsonString encoding:NSUTF8StringEncoding error:&paringError];
        }
        return segments;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get segment network request
 * @return urlRequest as NSMutableURLRequest
 */
-(NSData*)getSegmentPayload{
    @try {
        
        BOAEventsGetRequest *funnelPullPayload = [[BOAEventsGetRequest alloc] init];
        
        BOAEventsGet *funnelSyncTime = [[BOAEventsGet alloc] init];
        funnelSyncTime.lastUpdatedTime = @0; //lastUpdateTime ? lastUpdateTime : nil;
        
        funnelPullPayload.events = funnelSyncTime;
        
        BOAGeoEventsGet *funnelSyncGeo = [[BOAGeoEventsGet alloc] init];
        NSDictionary *cKnownLocation = [BOServerDataConverter prepareGeoData];
        if(cKnownLocation != nil && cKnownLocation != (id)[NSNull null]) {
            funnelSyncGeo.city = [cKnownLocation objectForKey:@"city"];
            funnelSyncGeo.reg =  [cKnownLocation objectForKey:@"reg"];
            funnelSyncGeo.couc = [cKnownLocation objectForKey:@"couc"];
            funnelSyncGeo.zip = [cKnownLocation objectForKey:@"zip"];
            funnelSyncGeo.conc = [cKnownLocation objectForKey:@"conc"];
        }
        funnelPullPayload.geo = funnelSyncGeo;
        
        BOAMetaEventsGet *funnelMetaInfo = [[BOAMetaEventsGet alloc] init];
        NSDictionary *metaInfo = [self prepareMetaDataDict:nil];
        if(metaInfo != nil && metaInfo != (id)[NSNull null]) {
            funnelMetaInfo.plf = [metaInfo objectForKey:@"plf"];
            funnelMetaInfo.appn = [metaInfo objectForKey:@"appn"];
            funnelMetaInfo.dcomp = [metaInfo objectForKey:@"dcomp"];
            funnelMetaInfo.acomp = [metaInfo objectForKey:@"acomp"];
            funnelMetaInfo.osv = [metaInfo objectForKey:@"osv"];
            funnelMetaInfo.dmft = [metaInfo objectForKey:@"dmft"];
            funnelMetaInfo.dm = [metaInfo objectForKey:@"dm"];
        }
        funnelPullPayload.meta = funnelMetaInfo;
        
        NSError *jsonDataError = nil;
        NSData *jsonData = [funnelPullPayload toData:&jsonDataError];
        
        return jsonData;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to store session segment data
 * @param sessionSegmentsNewData as BOASegmentEvents
 */
-(void)storeSessionSegmentsNewData:(BOASegmentEvents*)sessionSegmentsNewData{
    @try {
        if (!sessionSegmentsNewData) {
            return;
        }
        BOASegmentEvents *oldSegmentsEvent = [self loadAllActiveSegments];
        BOOL newSegmentsAdded = NO;
        if (oldSegmentsEvent) {
            NSMutableArray<BOASegment *> *oldAndNewEvents = [oldSegmentsEvent.segments mutableCopy];
            //TODO: Directly adding from array can lead to duplicate Segment object if server makes a mistake.
            //TODO: Using above incomplete for loop mechanism, we can filter but will see the need & do
            
            //Once model is updated then implement logic for deleting old one as well
            for (BOASegment *newSegment in sessionSegmentsNewData.segments) {
                BOOL isSameFEvent = NO;
                for (BOASegment *oldSegment in oldAndNewEvents) {
                    if ([newSegment.identifier isKindOfClass:[NSString class]]) {
                        if ([[NSString stringWithFormat:@"%@",newSegment.identifier] isEqualToString:[NSString stringWithFormat:@"%@",oldSegment.identifier]]) {
                            isSameFEvent = YES;
                            break;
                        }
                    }else{
                        if ([newSegment.identifier isEqualToNumber:oldSegment.identifier]) {
                            isSameFEvent = YES;
                            break;
                        }
                    }
                }
                if (!isSameFEvent) {
                    [oldAndNewEvents addObject:newSegment];
                    newSegmentsAdded = YES;
                }
            }
        }else{
            oldSegmentsEvent = sessionSegmentsNewData;
            newSegmentsAdded = YES;
        }
        
        if (newSegmentsAdded) {
            [[BOCommonEvents sharedInstance] recordSegmentReceived];
        }
        
        NSError *allSegmentsDataStrError = nil;
        NSString *allSegmentsDataStr = [oldSegmentsEvent toJSON:NSUTF8StringEncoding error:&allSegmentsDataStrError];
        
        NSString *fileExtention = @"txt";
        NSString *allSegmentsDirPath = [BOFFileSystemManager getAllSegmentsToAnalyseDirectoryPath];
        NSString *allSegmentsFilePath = [NSString stringWithFormat:@"%@/%@.%@",allSegmentsDirPath,@"AllSegments",fileExtention];
        NSError *errorAllSegmentWrite;
        //else file write operation and prapare new object
        [BOFFileSystemManager pathAfterWritingString:allSegmentsDataStr toFilePath:allSegmentsFilePath writingError:&errorAllSegmentWrite];
        
        NSError *segmentPayloadError = nil;
        NSString *sessionSegmentsNewDataStr = [sessionSegmentsNewData toJSON:NSUTF8StringEncoding error:&segmentPayloadError];
        
        NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
        NSString *segmentDownloadLogsDir = [BOFFileSystemManager getLogLevelDirAllSegmentsToAnalyseDirectoryPath];
        NSString *segmentDownloadLogsFile = [NSString stringWithFormat:@"%@/%@-%ld.txt",segmentDownloadLogsDir,dateString,(long)[BOAUtilities get13DigitIntegerTimeStamp]];
        NSError *error;
        //else file write operation and prapare new object
        [BOFFileSystemManager pathAfterWritingString:sessionSegmentsNewDataStr toFilePath:segmentDownloadLogsFile writingError:&error];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to check if sessions new data is valid
 * @param sessionSegmentsNewData as BOASegmentEvents
 * @return isAllSegmentValid as BOOL
 */
-(BOOL)isSegmentsNewDataValid:(BOASegmentEvents*)sessionSegmentsNewData{
    @try {
        BOOL isAllSegmentValid = NO;
        if (sessionSegmentsNewData.segments.count > 0) {
            for (BOASegment *eventSegment in sessionSegmentsNewData.segments) {
                if (eventSegment.ruleset.rules.count >= 1) {
                    isAllSegmentValid = YES;
                    break;
                }
            }
        }
        return isAllSegmentValid;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}


/**
 * method to valid new data segments
 * this methos only filter segment events and modify objects with only valid segments
 * @param sessionSegmentsNewData as BOASegmentEvents
 * @return segmentEvents as BOASegmentEvents
 */
-(BOASegmentEvents*)validNewDataSegments:(BOASegmentEvents*)sessionSegmentsNewData{
    @try {
        BOASegmentEvents *segmentEvents = [[BOASegmentEvents alloc] init];
        NSMutableArray<BOASegment *> *segmentsArr = [NSMutableArray array];
        if (sessionSegmentsNewData.segments.count > 0) {
            for (BOASegment *eventSegment in sessionSegmentsNewData.segments) {
                if (eventSegment.ruleset.rules.count >= 1) {
                    [segmentsArr addObject:eventSegment];
                }
            }
        }
        segmentEvents.geo = sessionSegmentsNewData.geo;
        segmentEvents.segments = segmentsArr;
        return segmentEvents;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}


/**
 * method to recursively download segments
 * timer logic to run segment task under fixed frequency
 * @param networkRequest as NSURLRequest
 */
-(void)recursivelyDownloadSegmentsUsingURLRequest:(NSURLRequest*)networkRequest{
    @try {
        //write job to fetch and send data as frequency
        //Also save files in directory, expired under history/expired, live under live and then unsynced + sync
        //Create direcotry structure
        if(requestInProgress == YES) {
            return;
        }
        
        BOSegmentAPI *segmentAPI = [[BOSegmentAPI alloc] init];
        NSData *dataPayload = [self getSegmentPayload];
        
        [segmentAPI getSegmentDataModel:dataPayload success:^(id  _Nonnull responseObject) {
            //store new data after validation
            BOASegmentEvents *allSegments = responseObject;
            
            if ([self isSegmentsNewDataValid:allSegments]) {
                BOASegmentEvents *validSegmentEvents = [self validNewDataSegments:allSegments];
                [self storeSessionSegmentsNewData:validSegmentEvents];
                //Check for logic in case initially not called & on this success we call again
                //Putting single condition check as, earlier no data exists and object was nil and now possibility is there
                //Or condition here is for more improvements if needed
                //|| SegmentsAndCodifiedEventsInstance.eventsSegment.count == 0
                if (!self->isPrepareSegmentsSyncCalled) {
                    [self prepareSegmentsSyncAndAnalyser];
                }
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
        
        requestInProgress = YES;
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        [analyticsRootUD setObject:[BOAUtilities get13DigitNumberObjTimeStamp] forKey:BO_ANALYTICS_SEGMENT_LAST_SYNC_TIME_DEFAULTS_KEY];
        
        [self recursivelyDownloadSegmentsAfterDelay:[[BOASDKManifestController sharedInstance] delayInterval] usingURLRequest:networkRequest];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recursivelyDownloadSegmentsAfterDelay:(NSTimeInterval)milliSeconds usingURLRequest:(NSURLRequest*)request{
    @try {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recursivelyDownloadSegmentsUsingURLRequest:) object:request];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, milliSeconds * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self recursivelyDownloadSegmentsUsingURLRequest:request];
        });
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)loadSegmentsNetworkScheduler{
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSNumber *lastSyncTimeStamp = [analyticsRootUD objectForKey:BO_ANALYTICS_SEGMENT_LAST_SYNC_TIME_DEFAULTS_KEY];
        if (lastSyncTimeStamp && [lastSyncTimeStamp longValue] > 0) {
            long updatedSyncTime = [[BOAUtilities get13DigitNumberObjTimeStamp] longValue] - [lastSyncTimeStamp longValue];
            int delayInterval = [[BOASDKManifestController sharedInstance] delayInterval] * 1000;
            long delayNow = ((delayInterval - updatedSyncTime) > 0) ? (delayInterval - updatedSyncTime) : 0;
            delayNow = delayNow / 1000; //Conveted to seconds
            [self recursivelyDownloadSegmentsAfterDelay:delayNow usingURLRequest:nil];
        }else{
            [self recursivelyDownloadSegmentsAfterDelay:BO_ANALYTICS_POST_INIT_NETWORK_DELAY usingURLRequest:nil];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to check weather segment is available or not
 * @return status as BOOL
 */
-(BOOL)isSegmentAvailable{
    @try {
        BOASegmentEvents *segEvents = [self loadAllActiveSegments];
        if (segEvents && (segEvents.segments.count > 0)) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(BOOL)isSegmentContainsValidEvents:(BOASegment*)segments{
    //Check for ruleset count should be greater than 1
    //Check for two consecutive events, should not be same
    //Do not implement now, get confirmation for v2.0 but possible & check for event duplicate orrurance, should not contain duplicate event
    return YES;
}

//Not using for now, will use it when needed
/*
 -(void)allSegmentsUsingURLRequest:(NSURLRequest*)segmentsURLReq withCompletionHandler:(void (^_Nullable)(NSArray<BOAEventsSegment *>* allSegments, NSError * error))completionHandler{
 
 if (!segmentsURLReq) {
 return;
 }
 
 BOFNetworkPromise *segmentPromise = [[BOFNetworkPromise alloc] initWithURLRequest:segmentsURLReq completionHandler:^(NSURLResponse * _Nullable urlResponse, id  _Nullable dataOrLocation, NSError * _Nullable error) {
 if ((((NSHTTPURLResponse*)urlResponse).statusCode == 200) && dataOrLocation) {
 NSError *segmentDecodeError = nil;
 BOASegmentAndCodifiedEvents *codifiedAndSegment = [BOASegmentAndCodifiedEvents fromData:dataOrLocation error:&segmentDecodeError];
 if (codifiedAndSegment.eventsSegment.count > 0) {
 completionHandler(codifiedAndSegment.eventsSegment, nil);
 }else{
 completionHandler(nil, nil); //setup proper error message
 }
 }else{
 completionHandler(nil, nil); //setup proper error message
 }
 }];
 
 [[BOFNetworkPromiseExecutor sharedInstance] executeNetworkPromise:segmentPromise];
 
 }
 */

-(NSString*)localTestSegmentPath{
    @try {
        NSString *testsegmentPath = [[NSBundle mainBundle] pathForResource:@"segments_1_sample" ofType:@"json"];
        return testsegmentPath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSURL*)localTestSegmentDummyServerURL{
    @try {
        //Path is nil test
        NSString *testsegmentPath = [[NSBundle mainBundle] pathForResource:@"segments_1_sample" ofType:@"json"];
        NSURL *testsegmentUrl = [NSURL fileURLWithPath:testsegmentPath];
        return testsegmentUrl;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(void)dealloc{
    requestInProgress = NO;
}
@end
