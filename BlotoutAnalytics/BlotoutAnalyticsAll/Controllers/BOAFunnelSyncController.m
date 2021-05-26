//
//  FunnelRetrievalControl.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/10/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOAFunnelSyncController is class to fetch and sync funnel to server
 */

#import "BOAFunnelSyncController.h"
#import "BOAFunnelAndCodifiedEvents.h"
#import "BOAFunnelPayload.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import <BlotoutFoundation/BOFSystemServices.h>
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAppSessionData.h"
#import "BOAConstants.h"
#import "BOANotificationConstants.h"
#import "BOADeviceAndAppFraudController.h"
#import "BOAAppSessionEvents.h"
#import "BlotoutAnalytics_Internal.h"
#import "BOServerDataConverter.h"
#import "BOCommonEvents.h"
#import "BOANetworkConstants.h"
#import "BOFunnelAPI.h"
#import "NSError+BOAdditions.h"

//TODO: make use with changes as needed
// nil → NSNull conversion for JSON dictionaries
//static _Nullable id NSNullifyCheck(id _Nullable x) {
//    return (x == nil || x == NSNull.null) ? NSNull.null : x;
//}
//static _Nullable id NSNullifyDictCheck(id _Nullable x) {
//    if ([x isKindOfClass:[NSDictionary class]] || [x isKindOfClass:[NSMutableDictionary class]]) {
//        return (x == nil || x == NSNull.null || (((NSDictionary *)x).allKeys.count <= 0)) ? NSNull.null : x;
//    }
//    return NSNull.null;
//}

static id sBOAFunnelSharedInstance = nil;
static BOOL isAggregate = YES;

NSString * const BOA_FUNNEL_SESSION_META_INFO_KEY = @"sessionMetaInfoFunnels";

#define EPAPostAPI @"POST"

@interface BOAFunnelSyncController (){
    BOAFunnelAndCodifiedEvents *funnelsAndCodifiedEventsInstance;
    NSMutableArray<BOAFunnelEvent*> *payloadEvents;
    
    NSInteger bgTerminationTimeCheck;
    BOOL requestInProgress;
}
@property (nonatomic, strong) NSMutableArray <NSString*> *currentViewName;
@property (nonatomic, strong) NSMutableArray <NSNumber*> *currentViewDuration;

@property (nonatomic, strong) NSNumber *launchTimeStamp;
@property (nonatomic, strong) NSNumber *terminationTimeStamp;
@property (nonatomic, strong) NSMutableArray<NSString*> *eventSequenceOrder;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *eventSubCodeSequenceOrder;
@property (nonatomic, strong) NSMutableDictionary <NSString*, NSArray<NSNumber*>*> *eventsInfo;
@property (nonatomic, strong) NSMutableDictionary <NSString*, NSNumber*> *preEventsInfo;
@property (nonatomic, strong) NSMutableDictionary <NSString*, NSNumber*> *eventsSubCode;
@property (nonatomic, strong) NSMutableDictionary <NSString*, NSArray<NSNumber*>*> *eventsDuration;

@end

@implementation BOAFunnelSyncController

-(instancetype)init{
    self = [super init];
    if (self) {
        requestInProgress = NO;
        self.isFunnelEnabled = NO;
        self.eventsInfo = [NSMutableDictionary dictionary];
        self.preEventsInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        self.eventsSubCode = [NSMutableDictionary dictionary];
        self.eventsDuration = [NSMutableDictionary dictionary];
        self.eventSequenceOrder = [NSMutableArray array];
        self.eventSubCodeSequenceOrder = [NSMutableArray array];
        
        self.currentViewName = [NSMutableArray array];
        self.currentViewDuration = [NSMutableArray array];
        
        funnelsAndCodifiedEventsInstance = nil;
        
        payloadEvents = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareGeoData:) name:BO_ANALYTICS_APP_IP_LOCATION_RECEIVED_KEY object:self];
    }
    return self;
}

/**
 * method to get the singleton instance of the BOAFunnelSyncController object,
 * @return BOAFunnelSyncController instance
 */
+ (nullable instancetype)sharedInstanceFunnelController{
    static dispatch_once_t boaFunnelOnceToken = 0;
    dispatch_once(&boaFunnelOnceToken, ^{
        sBOAFunnelSharedInstance = [[[self class] alloc] init];
    });
    return  sBOAFunnelSharedInstance;
}

/**
 * method to prepare meta data
 * @param sessionData as BOAppSessionData
 * @return metaData as NSDictionary
 */
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

-(BOAFunnelMeta*)prepareMetaData:(BOAppSessionData*)sessionData {
    @try {
        NSDictionary *metaInfo = [self prepareMetaDataDict:sessionData];
        return (metaInfo && (metaInfo.allValues.count > 0)) ? [BOAFunnelMeta fromJSONDictionary:metaInfo] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to prepare geo data
 * @param sessionData as BOAppSessionData
 * @return geoData as NSDictionary
 */
-(NSDictionary*)prepareGeoDataDict:(BOAppSessionData*)sessionData {
    NSDictionary *geoDatas = [BOServerDataConverter prepareGeoData];
    if((geoDatas != nil) && (geoDatas != (id)[NSNull null])) {
        return geoDatas;
    } else {
        return nil;
    }
    return nil;
}

-(BOAFunnelGeo*)prepareGeoData:(NSDictionary*)lastIPLocation {
    
    @try {
        NSDictionary *geoInfo = [self prepareGeoDataDict:nil];
        return (geoInfo && (geoInfo.allValues.count > 0)) ? [BOAFunnelGeo fromJSONDictionary:geoInfo] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method application launched with information
 * @param launchInfo as NSDictionary
 */
-(void)appLaunchedWithInfo:(NSDictionary*)launchInfo{
    @try {
        if (self.isFunnelEnabled && [BOASDKManifestController sharedInstance].isManifestAvailable) {
            self.launchTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            
            BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
            NSDate *lastLaunchDate = [analyticsRootUD objectForKey:BO_ANALYTICS_FUNNEL_APP_LAUNCH_PREV_DAY_DEFAULTS_KEY];
            NSString *lastLauchDateStr = [BOAUtilities convertDate:lastLaunchDate inFormat:@"yyyy-MM-dd"];
            
            NSDate *curretDate = [BOAUtilities getCurrentDate];
            lastLaunchDate = lastLaunchDate ? lastLaunchDate : curretDate;
            
            BOOL isDaySame = [BOAUtilities isDayMonthAndYearSameOfDate:lastLaunchDate andDate2:curretDate];
            BOOL isLesserDate = [BOAUtilities isDate:lastLaunchDate lessThan:curretDate];
            BOOL isConfirmedPreviousDate = !isDaySame && isLesserDate;
            //TODO: comment it once ready for integration, For testing purpose only until ready for Beta testing
            //        if (isAggregate && lastLauchDateStr && isConfirmedPreviousDate) {
            //            [self preapreDailyAggregatedFunnelEventAndSaveToDiskWithServerSyncForDate:lastLauchDateStr];
            //        }
            
            if (lastLauchDateStr) {
                //Do for all previous day
                [self serverSynSessionFunnelPayloadOfDate:nil withCompletionHandler:^(BOOL isSuccess, NSError *error) {
                    if (isSuccess) {
                        //Do this once only at App launch using previous day sesssion events, prepare daily aggregation, save it and send it to server as well
                        //We can do after session funnel event sync as after that only session event move to complete
                        //[self preapreDailyAggregatedFunnelEventAndSaveToDiskWithServerSyncForDate:nil];
                        if (isAggregate && lastLauchDateStr && isConfirmedPreviousDate) {
                            [self preapreDailyAggregatedFunnelEventAndSaveToDiskWithServerSyncForDate:lastLauchDateStr];
                        }
                        [self serverSynDailyAggregatedFunnelPayload:nil forDate:nil andFunnelID:nil]; //check for error & test on all IOS versions
                    }else{
                        //try in next launch or in sometime and if fails again then try alternate file movement
                    }
                }];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method application in background with information
 * @param backgroudInfo as NSDictionary
 */
-(void)appInBackgroundWithInfo:(NSDictionary*)backgroudInfo{
    @try {
        if(self.isFunnelEnabled) {
            //Do it when app goes in background, make changes later
            [self analyseAndUpdateFunnelsPayloadForEventsOccuredSoFar];
            
            [self checkAndUpdateTraversalCompleteForFunnels];
            
            bgTerminationTimeCheck = [BOAUtilities get13DigitIntegerTimeStamp];
            //    //Do it when app goes in background
            //    [self analyseAndUpdateFunnelsPayloadForEvents:eventName eventCode:eventSubCode happenedAt:eventTimeStamp];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method application will terminate with information
 * @param terminationInfo as NSDictionary
 */
-(void)appWillTerminatWithInfo:(nullable NSDictionary*)terminationInfo{
    @try {
        if(self.isFunnelEnabled) {
            NSNumber *appTerminationTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            NSString *preEventName = [self.preEventsInfo.allKeys lastObject];
            [self recordEventDurationsFor:preEventName usingReferenceTime:appTerminationTimeStamp];
            
            self.terminationTimeStamp = appTerminationTimeStamp;
            
            BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
            [analyticsRootUD setObject:[BOAUtilities getCurrentDate] forKey:BO_ANALYTICS_FUNNEL_APP_LAUNCH_PREV_DAY_DEFAULTS_KEY];
            
            [self storeSessionFunnelMetaInfo];
            
            //Test this logic of timegap
            NSInteger currentTime = [BOAUtilities get13DigitIntegerTimeStamp];
            if ((currentTime - bgTerminationTimeCheck) > 300*1000) {
                BOFLogDebug(@"TimeGap > 5 min %d", (currentTime - bgTerminationTimeCheck));
                // [self checkAndUpdateTraversalCompleteForFunnels];
            }
            //Meta info and geo info within single session remains same. practically different geo locations are possible but v1.0 doing this
            BOAFunnelMeta *metaInfo = [self prepareMetaData:nil];
            BOAFunnelGeo *geoInfo = [self prepareGeoData:nil];
            
            NSDictionary *payloadFunnelDict = @{
                @"meta": NSNullifyCheck(metaInfo),
                @"geo": NSNullifyCheck(geoInfo),
                @"fevents": NSNullifyCheck(payloadEvents)
            };
            BOAFunnelPayload *completePayload = [BOAFunnelPayload fromJSONDictionary:payloadFunnelDict];
            [self storeSessionFunnelInfoPayload:completePayload];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to prepare funnel sync and analyser
 */
-(void)prepareFunnnelSyncAndAnalyser{
    @try {
        
        if(!self.isFunnelEnabled) {
            return;
        }
        
        if (!funnelsAndCodifiedEventsInstance) {
            funnelsAndCodifiedEventsInstance = [self loadAllActiveFunnels];
        }
        //TODO: Check logic and verify, only concern atm is, network is aync and this won't wait for new funnel rather move to load existing one.
        //Fine for now
        [self performSelector:@selector(loadFunnelNetworkScheduler) withObject:nil afterDelay:BO_ANALYTICS_POST_INIT_NETWORK_DELAY];
        
        for (int indx= 0; indx<funnelsAndCodifiedEventsInstance.eventsFunnel.count; indx++) {
            BOAEventsFunnel *funnelEvent = [funnelsAndCodifiedEventsInstance.eventsFunnel objectAtIndex:indx];
            
            BOOL isNewFunnelToLoad = YES;
            for (BOAFunnelEvent *fTestIDEvent in payloadEvents) {
                if ([fTestIDEvent.identifier isEqualToString:funnelEvent.identifier]) {
                    isNewFunnelToLoad = NO;
                    break;
                }
            }
            
            if (isNewFunnelToLoad) {
                BOAFunnelEvent *funnelPayloadEvent = [[BOAFunnelEvent alloc] init];
                
                funnelPayloadEvent.identifier = funnelEvent.identifier;
                funnelPayloadEvent.version = funnelEvent.version;
                funnelPayloadEvent.name = funnelEvent.name;
                funnelPayloadEvent.eventTime = [BOAUtilities get13DigitNumberObjTimeStamp];
                funnelPayloadEvent.dayOfAnalysis = [BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"];
                funnelPayloadEvent.daySessionCount = [NSNumber numberWithInt:1];
                //Setting here will make timeStamp worth else no meaning like recording and updating at when app goes in background
                funnelPayloadEvent.messageID = [BOAUtilities generateMessageIDForEvent:funnelEvent.name evnetCode:funnelEvent.identifier happenedAt:[BOAUtilities get13DigitNumberObjTimeStamp]];
                funnelPayloadEvent.isaDayEvent = [NSNumber numberWithBool:NO];
                funnelPayloadEvent.isTraversed = [NSNumber numberWithBool:NO];
                funnelPayloadEvent.dayTraversedCount = [NSNumber numberWithInt:0];
                
                //Just to make sure array index beyond bound never happen when values are filled
                NSMutableArray *fVisits = [NSMutableArray array];
                for (int initIndx=0; initIndx<funnelEvent.eventList.count; initIndx++) {
                    [fVisits addObject:[NSNumber numberWithInt:0]];
                }
                funnelPayloadEvent.visits = fVisits;
                
                //Just to make sure array index beyond bound never happen when values are filled
                NSMutableArray *fNavigationTime = [NSMutableArray array];
                for (int initIndx=0; initIndx<funnelEvent.eventList.count; initIndx++) {
                    [fNavigationTime addObject:[NSNumber numberWithInt:0]];
                }
                funnelPayloadEvent.navigationTime = fNavigationTime;
                funnelPayloadEvent.userReferral = [NSNumber numberWithBool:NO];
                funnelPayloadEvent.userTraversedCount = [NSNumber numberWithInt:0]; //send this value at day level
                funnelPayloadEvent.prevTraversalDay = [NSString stringWithFormat:@"%@",NSNull.null];
                
                [payloadEvents addObject:funnelPayloadEvent];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to store sessin funnelinfo payload to file system
 * @param sessionFunnelPayload as BOAFunnelPayload
 */
-(void)storeSessionFunnelInfoPayload:(BOAFunnelPayload*)sessionFunnelPayload{
    @try {
        if (!sessionFunnelPayload) {
            return;
        }
        BOAFunnelPayload *funnelPayload = sessionFunnelPayload;
        NSString *funnelID = [funnelPayload.funnelEvents lastObject].identifier;
        NSError *funnelPayloadError = nil;
        NSString *sessionInfoFunnelsString = [funnelPayload toJSON:NSUTF8StringEncoding error:&funnelPayloadError];
        
        if (funnelID && ![funnelID isEqualToString:@""] && sessionInfoFunnelsString && ![sessionInfoFunnelsString isEqualToString:@""]) {
            NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
            NSString *funnelInfoDatePath = [BOFFileSystemManager getSyncPendingSessionFunnelInfoDirectoryPathForDate:dateString andFunnelID:funnelID];
            NSString *funnelInfoFilePath = [NSString stringWithFormat:@"%@/%ld.txt",funnelInfoDatePath,(long)[BOAUtilities get13DigitIntegerTimeStamp]];
            NSError *error;
            //else file write operation and prapare new object
            [BOFFileSystemManager pathAfterWritingString:sessionInfoFunnelsString toFilePath:funnelInfoFilePath writingError:&error];
            
            
            //TODO: for testing only
            NSString *funnelInfoDatePathTest = [BOFFileSystemManager getSyncCompleteSessionFunnelInfoDirectoryPathForDate:dateString andFunnelID:funnelID];
            NSString *funnelInfoFilePathTest = [NSString stringWithFormat:@"%@/%ld.txt",funnelInfoDatePathTest,(long)[BOAUtilities get13DigitIntegerTimeStamp]];
            NSError *errorTest;
            [BOFFileSystemManager pathAfterWritingString:sessionInfoFunnelsString toFilePath:funnelInfoFilePathTest writingError:&errorTest];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to store sessin funnel meta info to file system
 */
-(void)storeSessionFunnelMetaInfo{
    @try {
        //Write creating separate file and saving it under date folder, so all session for the day goes inside same directory
        //Alternatively we can do array below with timeStamp and same in a single file with date as file name.
        
        //As we are saving at App close and when App crosses day in a single session,
        //then using multiple files last file gets saved to separate folder as at end day has chnaged.
        
        //In the alternate approach, we will load data at the begining and save in the same file on day change so data of same file will have timeStamp of another day.
        //Another approach possible to create another file if day has changed, but going with multi file approach for now and will test any performance impact before switching to single file approach
        NSDictionary *sessionMetaInfoFunnels = @{
            @"launchTimeStamp":self.launchTimeStamp,
            @"terminationTimeStamp":self.terminationTimeStamp,
            @"eventSequenceOrder":self.eventSequenceOrder,
            @"eventSubCodeSequenceOrder":self.eventSubCodeSequenceOrder,
            @"eventsInfo":self.eventsInfo,
            @"preEventsInfo":self.preEventsInfo,
            @"eventsSubCode":self.eventsSubCode,
            @"eventsDuration":self.eventsDuration
        };
        
        for (int i = 0; i < self.eventSequenceOrder.count; i++) {
            BOFLogDebug(@"events in order= %@", self.eventSequenceOrder[i]);
        }
        
        if ([NSJSONSerialization isValidJSONObject:sessionMetaInfoFunnels]) {
            NSString *sessionMetaInfoFunnelsString = [BOAUtilities jsonStringFrom:sessionMetaInfoFunnels withPrettyPrint:NO];
            
            NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
            NSString *metaInfoDatePath = [BOFFileSystemManager getSyncPendingSessionFunnelMetaInfoDirectoryPathForDate:dateString];
            NSString *metaInfoFilePath = [NSString stringWithFormat:@"%@/%ld.txt",metaInfoDatePath,(long)self.terminationTimeStamp];
            NSError *error;
            //else file write operation and prapare new object
            [BOFFileSystemManager pathAfterWritingString:sessionMetaInfoFunnelsString toFilePath:metaInfoFilePath writingError:&error];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to record event duration for event
 * @param preEventNameRef as NSString
 * @param changeRefTime as NSNumber
 */
-(void)recordEventDurationsFor:(NSString*)preEventNameRef usingReferenceTime:(NSNumber*)changeRefTime{
    @try {
        
        if (!self.isFunnelEnabled) {
            return;
        }
        
        if (!preEventNameRef || [preEventNameRef isEqualToString:@""]) {
            return;
        }
        //preEventNameRef are not activaly used
        NSNumber *changeRefTimeL = changeRefTime;
        NSString *preEventName = [self.preEventsInfo.allKeys lastObject];
        NSNumber *preEventTimeStamp = [self.preEventsInfo objectForKey:preEventName];
        NSNumber *preEventCurrentDuration = [NSNumber numberWithInteger:([changeRefTimeL integerValue] - [preEventTimeStamp integerValue])];
        
        if ([self.eventsDuration.allKeys containsObject:preEventName]) {
            NSMutableArray *preEventDurations = [[self.eventsDuration objectForKey:preEventName] mutableCopy];
            [preEventDurations addObject:preEventCurrentDuration];
            [self.eventsDuration setObject:preEventDurations forKey:preEventName];
        }else{
            [self.eventsDuration setObject:@[preEventCurrentDuration] forKey:preEventName];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to record dev with name subcode and details
 * @param eventName as NSString
 * @param eventSubCode as NSNumber
 * @param eventDetails as NSDictionary
 */
-(void)recordDevEvent:(NSString*)eventName withEventSubCode:(NSNumber*)eventSubCode withDetails:(NSDictionary*)eventDetails{
    @try {
        
        if (!self.isFunnelEnabled) {
            return;
        }
        
        if (eventName && ![eventName isEqualToString:@""]) {
            
            NSNumber *eventTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            [self.eventSequenceOrder addObject:eventName];
            [self.eventSubCodeSequenceOrder addObject:eventSubCode];
            
            if ([self.eventsInfo.allKeys containsObject:eventName]) {
                NSMutableArray *eventTimes = [[self.eventsInfo objectForKey:eventName] mutableCopy];
                [eventTimes addObject:eventTimeStamp];
                [self.eventsInfo setObject:eventTimes forKey:eventName];
            }else{
                [self.eventsInfo setObject:@[eventTimeStamp] forKey:eventName];
            }
            
            NSString *preEventName = nil;
            if (![[self.preEventsInfo.allKeys lastObject] isEqualToString:eventName]) {
                preEventName = [self.preEventsInfo.allKeys lastObject];
                [self recordEventDurationsFor:preEventName usingReferenceTime:eventTimeStamp];
            }
            
            if (eventSubCode && ([eventSubCode intValue] != 0)) {
                [self.eventsSubCode setObject:eventSubCode forKey:eventName];
            }
            
            //Do it when app goes in background, make changes later, now doing it in background
            //[self analyseAndUpdateFunnelsPayloadForEvents:eventName eventCode:eventSubCode happenedAt:eventTimeStamp];
            
            if (self.preEventsInfo.allKeys.count > 0) {
                [self.preEventsInfo removeAllObjects];
            }
            [self.preEventsInfo setObject:eventTimeStamp forKey:eventName];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordNavigationEventFrom:(NSString*)fromVC to:(NSString*)toVC withDetails:(NSDictionary*)eventDetails{
    BOFLogDebug(@"from: %@,to: %@",fromVC,toVC);
}

/**
 * method to check and update traversal complete for funnels
 */
-(void)checkAndUpdateTraversalCompleteForFunnels{
    @try {
        for (int gIndx= 0; gIndx<funnelsAndCodifiedEventsInstance.eventsFunnel.count; gIndx++) {
            
            BOAEventsFunnel *funnelEvent = [funnelsAndCodifiedEventsInstance.eventsFunnel objectAtIndex:gIndx];
            BOAFunnelEvent *funnelPayloadEvent = [payloadEvents objectAtIndex:gIndx];
            if (funnelPayloadEvent) {
                int funnelEventsCount = (int)funnelEvent.eventList.count;
                
                NSArray *eventOccuredSoFar = self.eventSequenceOrder;
                NSMutableArray *allFunnelEventsName = [NSMutableArray arrayWithCapacity:funnelEventsCount];
                
                NSArray *eventSubCodeOccuredSoFar = self.eventSubCodeSequenceOrder;
                NSMutableArray *allFunnelEventsSubCode = [NSMutableArray arrayWithCapacity:funnelEventsCount];
                
                BOOL isTraversed = NO;
                int  traversedCount = 0;
                
                //V1.0 solution, discuss about improvements once featuers are ready
                //funnel events, sequence example = [A,B,A,A,B,C,B,A,A,C,B,A,A,B,C,D,E,C,B,A];
                //event A indices=[0,2,3,7,8,11,12,19]
                //event B indices=[1,4,6,10,13,18]
                //event C indices=[5,9,14,17]
                //event D indices=[15]
                
                //As funnel forward sequence must start with A, so create arrays with funnel events count startng indexes of A
                //Test all array for name match with extaxt sequence and if yes then traversed else not
                for (int indx=0; indx < funnelEventsCount; indx++) {
                    BOAEventList *event = [funnelEvent.eventList objectAtIndex:indx];
                    
                    //event name and eventCategorySubtype both are mandatory
                    if (event && event.eventName && event.eventCategorySubtype) {
                        [allFunnelEventsName addObject:event.eventName];
                        [allFunnelEventsSubCode addObject:event.eventCategorySubtype];
                    }
                    
                }
                
                NSIndexSet *allIndexesOfFirstEvent = [eventOccuredSoFar indexesOfObjectsPassingTest:^BOOL (id str, NSUInteger i, BOOL *stop) {
                    return [str isEqualToString:[allFunnelEventsName firstObject]];
                }];
                
                //Not using it for testing but going forward will incorporate
                NSIndexSet *allIndexesOfFirstSubCodeEvent = [eventSubCodeOccuredSoFar indexesOfObjectsPassingTest:^BOOL (id subCode, NSUInteger i, BOOL *stop) {
                    return [[NSString stringWithFormat:@"%@",subCode] isEqualToString:[allFunnelEventsSubCode firstObject]];
                }];
                
                NSMutableArray <NSMutableArray*> *eventsGroupArr = [NSMutableArray array];
                
                [allIndexesOfFirstEvent enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    //... do something with idx
                    // *stop = YES; to stop iteration early
                    int fEventCount = funnelEventsCount;
                    // 2 3 4  3 2 1
                    NSMutableArray *eventsGroupOfCount = [NSMutableArray arrayWithCapacity:funnelEventsCount];
                    for (NSUInteger indx=idx; fEventCount>=1 ; fEventCount--) {
                        [eventsGroupOfCount addObject:[eventOccuredSoFar objectAtIndex:indx]];
                        indx++;
                        if (indx >= eventOccuredSoFar.count) {
                            break;
                        }
                    }
                    [eventsGroupArr addObject:eventsGroupOfCount];
                }];
                
                
                for (int indxG=0; indxG<eventsGroupArr.count; indxG++) {
                    NSMutableArray *eventsGrouped = [eventsGroupArr objectAtIndex:indxG];
                    int totalNameMatch = 0;
                    BOOL traversalCheck = NO;
                    //Test
                    if (eventsGrouped.count == allFunnelEventsName.count) {
                        for (int yndx=0; yndx<eventsGrouped.count; yndx++) {
                            NSString *eventNameOccured = [eventsGrouped objectAtIndex:yndx];
                            NSString *eventFunnelName = [allFunnelEventsName objectAtIndex:yndx];
                            if ([eventNameOccured isEqualToString:eventFunnelName]) {
                                totalNameMatch = totalNameMatch + 1;
                                if (totalNameMatch == eventsGrouped.count) {
                                    isTraversed = YES;
                                    traversalCheck = YES;
                                    break;
                                }
                            }else{
                                break;
                            }
                        }
                    }else{
                        BOFLogDebug(@"Funnel Test: Event group count not matching");
                    }
                    
                    if (traversalCheck) {
                        traversedCount = traversedCount + 1;
                    }
                }
                funnelPayloadEvent.isTraversed = [NSNumber numberWithBool:isTraversed];
                funnelPayloadEvent.dayTraversedCount = [NSNumber numberWithInt:traversedCount];
                
                //This is update only operation so cases like payloadEvents with 0 objects in it and first insert operation happening here must not be the case
                [payloadEvents insertObject:funnelPayloadEvent atIndex:gIndx];
                //Remove the old one & as per behaviour mentione here
                //https://developer.apple.com/documentation/foundation/nsmutablearray/1416682-insertobject?language=objc
                //Objects gets shifted by 1
                [payloadEvents removeObjectAtIndex:(gIndx+1)];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to analyse and update funnels payload for events occured so far
 */
-(void)analyseAndUpdateFunnelsPayloadForEventsOccuredSoFar{
    @try {
        NSArray *uniqueEventNames = [[[NSOrderedSet orderedSetWithArray:self.eventSequenceOrder] array] copy];
        NSArray *uniqueEventSubcodes = [[[NSOrderedSet orderedSetWithArray:self.eventSubCodeSequenceOrder] array] copy];
        
        //uniqueEventNames
        //uniqueEventSubcodes
        //Above unique values will reduce fot loop counter and improve performance as at the time of count we are taking count from
        //NSUInteger eventsSoFarCount = self.eventSequenceOrder.count;
        
        for (int gIndexEvent=0; gIndexEvent < uniqueEventNames.count; gIndexEvent++) {
            
            BOFLogDebug(@"Index value 506 = %d count = %d subcount = %d", gIndexEvent, uniqueEventNames.count, uniqueEventSubcodes.count);
            
            NSString *eventNameArg = [uniqueEventNames objectAtIndex:gIndexEvent];
            NSNumber *eventCodeArg = [uniqueEventSubcodes objectAtIndex:gIndexEvent];
            
            BOFLogDebug(@"Index value 511");
            //TODO: improvements
            //Logic can be improved by knowing funnels which contains event name and process for those only
            //Let it work in 1.0 launch and then improve logic later
            for (int indx= 0; indx<funnelsAndCodifiedEventsInstance.eventsFunnel.count; indx++) {
                
                BOAEventsFunnel *funnelEvent = [funnelsAndCodifiedEventsInstance.eventsFunnel objectAtIndex:indx];
                BOAFunnelEvent *funnelPayloadEvent = [payloadEvents objectAtIndex:indx];
                //Making sure funnelPayloadEvent is not nil
                if (funnelPayloadEvent) {
                    for (BOAEventList *event in funnelEvent.eventList) {
                        if ([event.eventName isEqualToString:eventNameArg] && [event.eventCategorySubtype isEqualToString:[NSString stringWithFormat:@"%@",eventCodeArg]]) {
                            NSMutableArray<NSNumber*> *visits = [funnelPayloadEvent.visits mutableCopy];
                            NSMutableArray<NSNumber*> *navigationTime = [funnelPayloadEvent.navigationTime mutableCopy];
                            NSUInteger eventMatchIndex = [funnelEvent.eventList indexOfObject:event];
                            NSArray<NSNumber*> *eventDuraitons = eventNameArg ? [self.eventsDuration objectForKey:eventNameArg] : nil;
                            int totalVisitCount = (int)eventDuraitons.count;
                            NSNumber *totalEventDuration = eventDuraitons ? [eventDuraitons valueForKeyPath:@"@sum.self"] : [NSNumber numberWithInt:0];
                            
                            //After making changes in init prepare method, this if should never be true, still for safety let it be until 100% tested
                            if (eventMatchIndex > (visits.count-1)) {
                                BOFLogDebug(@"Index is more than count, not expected");
                                for (int preFillIndx = ((int)visits.count-1); preFillIndx < eventMatchIndex; preFillIndx++) {
                                    [visits addObject:[NSNumber numberWithInt:0]];
                                    [navigationTime addObject:[NSNumber numberWithInt:0]];
                                }
                            }
                            [visits insertObject:[NSNumber numberWithInt:totalVisitCount] atIndex:eventMatchIndex];
                            NSUInteger oldObjectIndex = eventMatchIndex+1;
                            if ((visits.count > 1) && oldObjectIndex < visits.count) {
                                [visits removeObjectAtIndex:oldObjectIndex];
                            }
                            [navigationTime insertObject:totalEventDuration atIndex:eventMatchIndex];
                            if ((navigationTime.count > 1) && oldObjectIndex < navigationTime.count) {
                                [navigationTime removeObjectAtIndex:oldObjectIndex];
                            }
                            
                            [funnelPayloadEvent setVisits:visits];
                            [funnelPayloadEvent setNavigationTime:navigationTime];
                        }
                    }
                    //This is update only operation so cases like payloadEvents with 0 objects in it and first insert operation happening here must not be the case
                    [payloadEvents insertObject:funnelPayloadEvent atIndex:indx];
                    //Remove the old one & as per behaviour mentione here
                    //https://developer.apple.com/documentation/foundation/nsmutablearray/1416682-insertobject?language=objc
                    //Objects gets shifted by 1
                    int oldObjectNewIndex = indx+1;
                    [payloadEvents removeObjectAtIndex:oldObjectNewIndex];
                }
            }
        }
        BOFLogDebug(@" after update 571Line = %@", payloadEvents);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to analyse and update funnel payload for events
 * @param eventNameArg as NSString
 * @param eventCodeArg as NSNumber
 * @param timeStamp as NSNumber
 */
-(void)analyseAndUpdateFunnelsPayloadForEvents:(NSString*)eventNameArg eventCode:(NSNumber*)eventCodeArg happenedAt:(NSNumber*)timeStamp{
    @try {
        if (!funnelsAndCodifiedEventsInstance) {
            //This is true, find way to make sure object init happen before this call
            BOFLogDebug(@"something not good");
            return;
        }
        //TODO: improvements
        //Logic can be improved by knowing funnels which contains event name and process for those only
        //Let it work in 1.0 launch and then improve logic later
        for (int indx= 0; indx<funnelsAndCodifiedEventsInstance.eventsFunnel.count; indx++) {
            
            BOAEventsFunnel *funnelEvent = [funnelsAndCodifiedEventsInstance.eventsFunnel objectAtIndex:indx];
            BOAFunnelEvent *funnelPayloadEvent = [payloadEvents objectAtIndex:indx];
            //Making sure funnelPayloadEvent is not nil
            if (funnelPayloadEvent) {
                for (BOAEventList *event in funnelEvent.eventList) {
                    if ([event.eventName isEqualToString:eventNameArg] && [event.eventCategorySubtype isEqualToString:[NSString stringWithFormat:@"%@",eventCodeArg]]) {
                        NSMutableArray<NSNumber*> *visits = [funnelPayloadEvent.visits mutableCopy];
                        NSMutableArray<NSNumber*> *navigationTime = [funnelPayloadEvent.navigationTime mutableCopy];
                        NSUInteger eventMatchIndex = [funnelEvent.eventList indexOfObject:event];
                        
                        NSString *preEventName = nil;//[[self.preEventsInfo allKeys] lastObject];
                        NSUInteger eventsSoFarCount = self.eventSequenceOrder.count;
                        if (eventsSoFarCount <= 1) {
                            preEventName = [self.eventSequenceOrder lastObject];
                        }else{
                            preEventName = [self.eventSequenceOrder objectAtIndex:(eventsSoFarCount - 2)];
                        }
                        NSArray<NSNumber*> *eventDuraitons = preEventName ? [self.eventsDuration objectForKey:preEventName] : nil;
                        int totalVisitCount = (int)eventDuraitons.count;
                        NSNumber *totalEventDuration = eventDuraitons ? [eventDuraitons valueForKeyPath:@"@sum.self"] : [NSNumber numberWithInt:0];
                        if (eventMatchIndex > (visits.count-1)) {
                            BOFLogDebug(@"Index is more than count, not expected");
                            for (int preFillIndx = ((int)visits.count-1); preFillIndx < eventMatchIndex; preFillIndx++) {
                                [visits addObject:[NSNumber numberWithInt:0]];
                                [navigationTime addObject:[NSNumber numberWithInt:0]];
                            }
                        }
                        
                        [visits insertObject:[NSNumber numberWithInt:totalVisitCount] atIndex:eventMatchIndex];
                        NSUInteger oldObjectIndex = eventMatchIndex+1;
                        if ((visits.count > 1) && oldObjectIndex < visits.count) {
                            [visits removeObjectAtIndex:oldObjectIndex];
                        }
                        [navigationTime insertObject:totalEventDuration atIndex:eventMatchIndex];
                        if ((navigationTime.count > 1) && oldObjectIndex < navigationTime.count) {
                            [navigationTime removeObjectAtIndex:oldObjectIndex];
                        }
                        
                        [funnelPayloadEvent setVisits:visits];
                        [funnelPayloadEvent setNavigationTime:navigationTime];
                    }
                }
                //[payloadEvents removeObjectAtIndex:indx];
                
                //This is update only operation so cases like payloadEvents with 0 objects in it and first insert operation happening here must not be the case
                [payloadEvents insertObject:funnelPayloadEvent atIndex:indx];
                //Remove the old one & as per behaviour mentione here
                //https://developer.apple.com/documentation/foundation/nsmutablearray/1416682-insertobject?language=objc
                //Objects gets shifted by 1
                int oldObjectNewIndex = indx+1;
                [payloadEvents removeObjectAtIndex:oldObjectNewIndex];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    if (!eventNameArg || [eventNameArg isEqualToString:@""]) {
        return;
    }
}

/**
 * method to sync session funnel payload of date
 * sync shoud consider all previous days files, as if App is launched once is a day and then next day then session not sycned is previous day, similar for previous chain
 * @param syncDateStr as NSString
 */
-(void)serverSynSessionFunnelPayloadOfDate:(NSString*)syncDateStr withCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * error))completionHandler{
    @try {
        NSString *todayDateStr = syncDateStr ? syncDateStr : [BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"];
        NSString *allSessionFunnelsDir = [BOFFileSystemManager getSyncPendingSessionFunnelInfoDirectoryPath];
        NSArray *allFunnelsDir = [BOFFileSystemManager getAllDirsInside:allSessionFunnelsDir];
        
        //All stored session funnels IDs
        NSMutableArray *allStoredFunnelIDs = [NSMutableArray arrayWithCapacity:allFunnelsDir.count];
        for (NSString *fDirPath in allFunnelsDir) {
            //TODO: check for dir name as funnel ID match
            NSString *dirName = [fDirPath lastPathComponent];
            [allStoredFunnelIDs addObject:dirName];
        }
        
        //All today session Funnels files
        NSMutableArray *allFunnelsSessionFunnels = [NSMutableArray array];
        for (NSString *funnelID in allStoredFunnelIDs) {
            NSArray *allFunnelsFiles =  [self getAllStoredSyncPendingSessionsFunnelPayloadFilesFor:funnelID ofDate:todayDateStr];
            [allFunnelsSessionFunnels addObject:allFunnelsFiles];
        }
        
        __block BOOL isSuccess = NO;
        for (int loop1 = 0; loop1 <  allFunnelsSessionFunnels.count; loop1++) {
            NSArray *allFunnelSessionFiles = [allFunnelsSessionFunnels objectAtIndex:loop1];
            for (int loop2 = 0; loop2 <  allFunnelSessionFiles.count; loop2++) {
                NSString *sessionFunnelFile = [allFunnelSessionFiles objectAtIndex:loop2];
                
                //File may have funnels without meta info due to certain crash in App, check before sending
                NSData *fileData = [NSData dataWithContentsOfFile:sessionFunnelFile];
                if (fileData.length < 10) {
                    NSError *junkFileRemove;
                    [BOFFileSystemManager removeFileFromLocationPath:sessionFunnelFile removalError:&junkFileRemove];
                    continue;
                }
                NSError *fileReadErrorFunnel;
                NSString *fileDataStrToCheck = [NSString stringWithContentsOfFile:sessionFunnelFile encoding:NSUTF8StringEncoding error:&fileReadErrorFunnel];
                NSMutableDictionary *fileDataDict = [[BOAUtilities jsonObjectFromString:fileDataStrToCheck] mutableCopy];
                
                if (![fileDataDict objectForKey:@"meta"] || ([fileDataDict objectForKey:@"meta"] == NULL)) {
                    [fileDataDict setObject:[self prepareMetaDataDict:nil] forKey:@"meta"];
                    
                    fileDataStrToCheck = [BOAUtilities jsonStringFrom:fileDataDict withPrettyPrint:NO];
                    
                    NSError *errorModifiedFileWrite;
                    NSError *oldFileRemoveError;
                    //else file write operation and prapare new object
                    [BOFFileSystemManager removeFileFromLocationPath:sessionFunnelFile removalError:&oldFileRemoveError];
                    [BOFFileSystemManager pathAfterWritingString:fileDataStrToCheck toFilePath:sessionFunnelFile writingError:&errorModifiedFileWrite];
                    
                    fileData = [fileDataStrToCheck dataUsingEncoding:NSUTF8StringEncoding];
                }
                NSString *funnelFilePathCopy1 = [sessionFunnelFile copy];
                NSString *funnelIDStr = [[[funnelFilePathCopy1 stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] lastPathComponent];
                
                BOFunnelAPI *postFunnelApi = [[BOFunnelAPI alloc] init];
                [postFunnelApi postFunnelDataModel:fileData success:^(id  _Nonnull responseObject) {
                    
                    [[BOCommonEvents sharedInstance] recordFunnelTriggered];
                    NSString *funnelIDnDateDirInsideComplete = [BOFFileSystemManager getSyncCompleteSessionFunnelInfoDirectoryPathForDate:todayDateStr andFunnelID:funnelIDStr];
                    //Because file has already been written to pending directory, so moving from pending to complete
                    //Already written becasue of uncertain user behaviour and app may get closed just after launch
                    NSError *fileRelocationError = nil;
                    isSuccess = [BOFFileSystemManager moveFileFromLocationPath:sessionFunnelFile toLocationPath:funnelIDnDateDirInsideComplete relocationError:&fileRelocationError];
                } failure:^(NSError * _Nonnull error) {
                    
                }];
            }
        }
        if (isSuccess) {
            completionHandler(isSuccess, nil);
        }else{
            //TODO: fix this using error class framework
            NSError *fileMoveError = [NSError errorWithDomain:@"com.blotout.funnel" code:6000111 userInfo:@{@"info": @"File Relocation Error"}];
            completionHandler(isSuccess, fileMoveError);
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        completionHandler(NO, [NSError boErrorForDict:exception.userInfo]);
    }
}

/**
 * method to get all stored sync pending sessions funnel payload files
 * @param funnelID as NSString
 * @param dateStr as NSString
 * @return allFunnelIDFiles as NSArray
 */
-(NSArray<NSString*>*)getAllStoredSyncPendingSessionsFunnelPayloadFilesFor:(NSString*)funnelID ofDate:(NSString*)dateStr{
    @try {
        NSString *funnelIDDateDir =  [BOFFileSystemManager getSyncPendingSessionFunnelInfoDirectoryPathForDate:dateStr andFunnelID:funnelID];
        NSArray *allFunnelIDFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:funnelIDDateDir];
        return allFunnelIDFiles;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get all stored sync pending sessions funnel payload
 * @param funnelID as NSString
 * @param dateStr as NSString
 * @return funnelPayloadsArr as BOAFunnelPayload
 */
-(NSArray <BOAFunnelPayload*>*)getAllStoredSyncPendingSessionsFunnelPayloadFor:(NSString*)funnelID ofDate:(NSString*)dateStr{
    @try {
        NSString *funnelIDDateDir =  [BOFFileSystemManager getSyncPendingSessionFunnelInfoDirectoryPathForDate:dateStr andFunnelID:funnelID];
        NSArray *allFunnelIDFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:funnelIDDateDir];
        
        NSMutableArray <BOAFunnelPayload*> *funnelPayloadsArr = [NSMutableArray arrayWithCapacity:allFunnelIDFiles.count];
        for (NSString *funnelFiles in allFunnelIDFiles) {
            NSError *fileReadError = nil;
            NSString *fileDataStr = [BOFFileSystemManager contentOfFileAtPath:funnelFiles withEncoding:NSUTF8StringEncoding andError:&fileReadError];
            NSError *jsonParseError = nil;
            BOAFunnelPayload *funnelPayload = [BOAFunnelPayload fromJSON:fileDataStr encoding:NSUTF8StringEncoding error:&jsonParseError];
            [funnelPayloadsArr addObject:funnelPayload];
        }
        return funnelPayloadsArr;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get all stored sync complete sessions funnel payload files
 * @param funnelID as NSString
 * @param dateStr as NSString
 * @return allFunnelIDFiles as NSArray
 */
-(NSArray<NSString*>*)getAllStoredSyncCompleteSessionsFunnelPayloadFilesFor:(NSString*)funnelID ofDate:(NSString*)dateStr{
    @try {
        NSString *funnelIDDateDir =  [BOFFileSystemManager getSyncCompleteSessionFunnelInfoDirectoryPathForDate:dateStr andFunnelID:funnelID];
        NSArray *allFunnelIDFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:funnelIDDateDir];
        return allFunnelIDFiles;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get all stored sync complete sessions funnel payload
 * @param funnelID as NSString
 * @param dateStr as NSString
 * @return funnelPayloadsArr as BOAFunnelPayload
 */
-(NSArray <BOAFunnelPayload*>*)getAllStoredSyncCompleteSessionsFunnelPayloadFor:(NSString*)funnelID ofDate:(NSString*)dateStr{
    @try {
        NSString *funnelIDDateDir =  [BOFFileSystemManager getSyncCompleteSessionFunnelInfoDirectoryPathForDate:dateStr andFunnelID:funnelID];
        NSArray *allFunnelIDFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:funnelIDDateDir];
        
        NSMutableArray <BOAFunnelPayload*> *funnelPayloadsArr = [NSMutableArray arrayWithCapacity:allFunnelIDFiles.count];
        for (NSString *funnelFiles in allFunnelIDFiles) {
            NSError *fileReadError = nil;
            NSString *fileDataStr = [BOFFileSystemManager contentOfFileAtPath:funnelFiles withEncoding:NSUTF8StringEncoding andError:&fileReadError];
            NSError *jsonParseError = nil;
            BOAFunnelPayload *funnelPayload = [BOAFunnelPayload fromJSON:fileDataStr encoding:NSUTF8StringEncoding error:&jsonParseError];
            [funnelPayloadsArr addObject:funnelPayload];
        }
        return funnelPayloadsArr;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to prepare daily aggregate funnel event and save to disk with server sync date
 * do this once only at App launch using previous day sesssion events, prepare daily aggregation, save it and send it to server as well
 * if any major issue found during testing then you can preapre this object along with funnel and sync with server on date change, but for now seems ok
 * @param dateString as NSString
 */
-(void)preapreDailyAggregatedFunnelEventAndSaveToDiskWithServerSyncForDate:(NSString*)dateString{
    @try {
        //Make sure to take care of session movement
        NSString *previousDateStr = dateString ? dateString : [BOAUtilities getPreviousDayDateInFormat:@"yyyy-MM-dd" fromReferenceDate:[BOAUtilities getCurrentDate]];
        NSString *allSessionFunnelsDir = [BOFFileSystemManager getSyncCompleteSessionFunnelInfoDirectoryPath];
        NSArray *allFunnelsDir = [BOFFileSystemManager getAllDirsInside:allSessionFunnelsDir];
        
        //All stored session funnels IDs
        NSMutableArray *allStoredFunnelIDs = [NSMutableArray arrayWithCapacity:allFunnelsDir.count];
        for (NSString *fDirPath in allFunnelsDir) {
            //TODO: check for dir name as funnel ID match
            NSString *dirName = [fDirPath lastPathComponent];
            [allStoredFunnelIDs addObject:dirName];
        }
        
        //All previous day session Funnels objects
        NSMutableArray *allPreDaySessionFunnels = [NSMutableArray array];
        for (NSString *funnelID in allStoredFunnelIDs) {
            NSArray *allFunnelsFiles =  [self getAllStoredSyncCompleteSessionsFunnelPayloadFor:funnelID ofDate:previousDateStr];
            [allPreDaySessionFunnels addObject:allFunnelsFiles];
        }
        
        
        //BOAFunnelAndCodifiedEvents *funnelsAndCodifiedEvents = [self loadAllActiveFunnels];
        for (NSArray<BOAFunnelPayload*> *funnelSessionPayloadArr in allPreDaySessionFunnels) {
            
            BOAFunnelPayload *dailyFunnelEventPay = [[BOAFunnelPayload alloc] init];
            BOAFunnelEvent *dailyEvent = [[BOAFunnelEvent alloc] init];
            BOAFunnelPayload *funnelSessionP = [funnelSessionPayloadArr lastObject];
            //last object or first object both should be fine as we are maintaining single funnel event per file
            BOAFunnelEvent *funnelPayloadEvent = [funnelSessionP.funnelEvents lastObject];
            dailyEvent.identifier = funnelPayloadEvent.identifier;
            dailyEvent.version = funnelPayloadEvent.version;
            dailyEvent.name = funnelPayloadEvent.name;
            dailyEvent.eventTime = funnelPayloadEvent.eventTime;//eventTimeStamp;
            dailyEvent.dayOfAnalysis = previousDateStr;
            dailyEvent.daySessionCount = [NSNumber numberWithUnsignedInteger:funnelSessionPayloadArr.count];
            dailyEvent.messageID = [BOAUtilities generateMessageIDForEvent:funnelPayloadEvent.name evnetCode:funnelPayloadEvent.identifier happenedAt:funnelPayloadEvent.eventTime];
            dailyEvent.isaDayEvent = [NSNumber numberWithBool:YES];
            BOOL isTraversed = NO;
            int traversedCount = 0;
            for (BOAFunnelPayload *funnelSessionPayLoop in funnelSessionPayloadArr) {
                BOAFunnelEvent *eve = [funnelSessionPayLoop.funnelEvents lastObject];
                if ([eve.isTraversed boolValue]) {
                    isTraversed = YES;
                    traversedCount = traversedCount + 1;
                }
            }
            NSNumber *todaysCount = [NSNumber numberWithInt:traversedCount];
            dailyEvent.isTraversed = [NSNumber numberWithBool:isTraversed];
            dailyEvent.dayTraversedCount = todaysCount;
            
            NSMutableArray<NSNumber*> *dailyVisits = [NSMutableArray array];
            NSMutableArray<NSNumber*> *dailyEventNavigation = [NSMutableArray array];
            for (int indx=0; indx<funnelPayloadEvent.visits.count; indx++) {
                long visitSum = 0;
                long navigationSum = 0;
                for (int yndx=0; yndx<funnelSessionPayloadArr.count; yndx++) {
                    //last object because in payload store file, we are storing single session data and single funnel data per file
                    BOAFunnelEvent *fEvent = [[funnelSessionPayloadArr objectAtIndex:yndx].funnelEvents lastObject];
                    //BOAFunnelEvent *visitTemp = [funnelSessionP.funnelEvents objectAtIndex:yndx];
                    NSNumber *firstEventFirstVisit = [fEvent.visits objectAtIndex:indx];
                    visitSum = visitSum + [firstEventFirstVisit longValue];
                    //Becasue visits & navigation counter is same, so doing both job in the same loop
                    NSNumber *firstEventFirstNavigation = [fEvent.navigationTime objectAtIndex:indx];
                    navigationSum = navigationSum + [firstEventFirstNavigation longValue];
                }
                
                //No delete needed as insertion is happening on fresh object being created at line 689 & 690
                //TODO: Check whether insert at index is working properly
                [dailyVisits insertObject:[NSNumber numberWithLong:visitSum] atIndex:indx];
                [dailyEventNavigation insertObject:[NSNumber numberWithLong:navigationSum] atIndex:indx];
                
                BOFLogDebug(@"Daily Aggregated check visits= %@ and eventNavigation= %@", dailyVisits, dailyEventNavigation);
            }
            
            dailyEvent.visits = dailyVisits;
            dailyEvent.navigationTime = dailyEventNavigation;
            dailyEvent.userReferral = [NSNumber numberWithInt:0]; //TODO: need to work on this
            dailyEvent.userTraversedCount = [self getAndUpdateUserLevelFunnelCountForID:funnelPayloadEvent.identifier andTodaysCount:todaysCount];
            dailyEvent.prevTraversalDay = [self getAndUpdateFunnelPrevTraversalDateForID:funnelPayloadEvent.identifier withTodayTraversal:isTraversed];
            
            BOAFunnelMeta *dailyMetaInfo = funnelSessionP.meta;
            BOAFunnelGeo *dailyGeoInfo = funnelSessionP.geo;
            NSArray<BOAFunnelEvent*> *dailyFunnelEvents = @[dailyEvent];
            
            [dailyFunnelEventPay setMeta:dailyMetaInfo];
            [dailyFunnelEventPay setGeo:dailyGeoInfo];
            [dailyFunnelEventPay setFunnelEvents:dailyFunnelEvents];
            //work on looping part for other funnel ID as above just make ready for one
            [self storeDailyAggregatedFunnelPayload:dailyFunnelEventPay forDate:previousDateStr andFunnelID:funnelPayloadEvent.identifier];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to store daily aggregate funnel payload to file directory
 * @param dailyAggregatedPayload as BOAFunnelPayload
 * @param dateStr as NSString
 * @param funnelID as NSString
 */
-(void)storeDailyAggregatedFunnelPayload:(BOAFunnelPayload*)dailyAggregatedPayload forDate:(NSString*)dateStr andFunnelID:(NSString*)funnelID{
    @try {
        NSString *previousDateStr = dateStr?  dateStr : [BOAUtilities getPreviousDayDateInFormat:@"yyyy-MM-dd" fromReferenceDate:[BOAUtilities getCurrentDate]];
        
        NSError *dailyAggregatedEventError = nil;
        NSString *dailyAggregatedEventStr = [dailyAggregatedPayload toJSON:NSUTF8StringEncoding error:&dailyAggregatedEventError];
        
        NSString *fileExtention = @"txt";
        NSString *dailyAggregatedPendingDir = [BOFFileSystemManager getDailyAggregatedFunnelEventsSyncPendingDirectoryPath];
        NSString *dateDirInsidePending = [BOFFileSystemManager getChildDirectory:previousDateStr byCreatingInParent:dailyAggregatedPendingDir];
        NSString *dailyAggregatedFunnelIDFile = [NSString stringWithFormat:@"%@/%@.%@",dateDirInsidePending,funnelID,fileExtention];
        NSError *errorDailyFunnelWrite;
        //else file write operation and prapare new object
        [BOFFileSystemManager pathAfterWritingString:dailyAggregatedEventStr toFilePath:dailyAggregatedFunnelIDFile writingError:&errorDailyFunnelWrite];
        
        [self serverSynDailyAggregatedFunnelPayload:dailyAggregatedPayload forDate:previousDateStr andFunnelID:funnelID];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to sync daily aggregated funnel payload
 * @param dailyAggregatedEvent as BOAFunnelPayload
 * @param dateStr as NSString
 * @param funnelID as NSString
 */
-(void)serverSynDailyAggregatedFunnelPayload:(BOAFunnelPayload*)dailyAggregatedEvent forDate:(NSString*)dateStr andFunnelID:(NSString*)funnelID{
    @try {
        NSString *previousDateStr = dateStr ?  dateStr : [BOAUtilities getPreviousDayDateInFormat:@"yyyy-MM-dd" fromReferenceDate:[BOAUtilities getCurrentDate]];
        NSString *fileExtention = @"txt";
        if (dailyAggregatedEvent) {
            
            NSError *dailyAggregatedEventError = nil;
            NSData *dailyAggregatedEventData = [dailyAggregatedEvent toData:&dailyAggregatedEventError];
            
            if(dailyAggregatedEventData == nil) {
                return;
            }
            
            BOFunnelAPI *postFunnelApi = [[BOFunnelAPI alloc] init];
            [postFunnelApi postFunnelDataModel:dailyAggregatedEventData success:^(id  _Nonnull responseObject) {
                NSString *dailyAggregatedPendingDir = [BOFFileSystemManager getDailyAggregatedFunnelEventsSyncPendingDirectoryPath];
                NSString *dateDirInsidePending = [BOFFileSystemManager getChildDirectory:previousDateStr byCreatingInParent:dailyAggregatedPendingDir];
                
                NSString *dailyAggregatedCompleteDir = [BOFFileSystemManager getDailyAggregatedFunnelEventsSyncCompleteDirectoryPath];
                NSString *dateDirInsideComplete = [BOFFileSystemManager getChildDirectory:previousDateStr byCreatingInParent:dailyAggregatedCompleteDir];
                
                NSString *funnleFilePath = [NSString stringWithFormat:@"%@/%@.%@",dateDirInsidePending,funnelID,fileExtention];
                
                //Because file has already been written to pending directory, so moving from pending to complete
                //Already written becasue of uncertain user behaviour and app may get closed just after launch
                NSError *fileRelocationError = nil;
                [BOFFileSystemManager moveFileFromLocationPath:funnleFilePath toLocationPath:dateDirInsideComplete relocationError:&fileRelocationError];
            } failure:^(NSError * _Nonnull error) {
                
            }];
        }else{
            NSString *dailyAggregatedPendingDir = [BOFFileSystemManager getDailyAggregatedFunnelEventsSyncPendingDirectoryPath];
            NSString *dateDirInsidePending = [BOFFileSystemManager getChildDirectory:previousDateStr byCreatingInParent:dailyAggregatedPendingDir];
            NSArray *allFunnelPayloadFiles = [BOFFileSystemManager getAllFilesWithExtention:fileExtention fromDir:dateDirInsidePending];
            
            for (NSString *singleFilePath in allFunnelPayloadFiles) {
                
                NSData *fileData = [NSData dataWithContentsOfFile:singleFilePath];
                BOFunnelAPI *postFunnelApi = [[BOFunnelAPI alloc] init];
                [postFunnelApi postFunnelDataModel:fileData success:^(id  _Nonnull responseObject) {
                    NSString *dailyAggregatedCompleteDir = [BOFFileSystemManager getDailyAggregatedFunnelEventsSyncCompleteDirectoryPath];
                    NSString *dateDirInsideComplete = [BOFFileSystemManager getChildDirectory:previousDateStr byCreatingInParent:dailyAggregatedCompleteDir];
                    NSError *fileRelocationError = nil;
                    [BOFFileSystemManager moveFileFromLocationPath:singleFilePath toLocationPath:dateDirInsideComplete relocationError:&fileRelocationError];
                } failure:^(NSError * _Nonnull error) {
                    
                }];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to get and update user level funnel cound
 * @param funnelID as NSString
 * @param todaysCount as NSNumber
 * @return newCountObj as NSNumber
 */
-(NSNumber*)getAndUpdateUserLevelFunnelCountForID:(NSString*)funnelID andTodaysCount:(NSNumber*)todaysCount{
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSMutableDictionary *userFunnelCount = [[analyticsRootUD objectForKey:BO_ANALYTICS_FUNNEL_USER_TRAVERSAL_COUNT_DEFAULTS_KEY] mutableCopy];
        NSNumber *prevCount = [userFunnelCount objectForKey:funnelID];
        long newCount = [prevCount longValue] + [todaysCount longValue];
        NSNumber *newCountObj = [NSNumber numberWithLong:newCount];
        [userFunnelCount setObject:newCountObj forKey:funnelID];
        [analyticsRootUD setObject:userFunnelCount forKey:BO_ANALYTICS_FUNNEL_USER_TRAVERSAL_COUNT_DEFAULTS_KEY];
        return newCountObj;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get and update funnel prev traversal date
 * @param funnelID as NSString
 * @param todayTraversed as BOOL
 * @return prevDay as NSString
 */
-(NSString*)getAndUpdateFunnelPrevTraversalDateForID:(NSString*)funnelID withTodayTraversal:(BOOL)todayTraversed{
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSMutableDictionary *userFunnelVisitDay = [[analyticsRootUD objectForKey:BO_ANALYTICS_FUNNEL_USER_TRAVERSAL_PREV_DAY_DEFAULTS_KEY] mutableCopy];
        NSString *prevDay = [userFunnelVisitDay objectForKey:funnelID];
        if (todayTraversed) {
            NSString *newDate = [BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"];
            [userFunnelVisitDay setObject:newDate forKey:funnelID];
        }
        [analyticsRootUD setObject:userFunnelVisitDay forKey:BO_ANALYTICS_FUNNEL_USER_TRAVERSAL_COUNT_DEFAULTS_KEY];
        return prevDay;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to load all active funnels from file system
 * @return funnelsAndCodifiedEvents as BOAFunnelAndCodifiedEvents
 */
-(BOAFunnelAndCodifiedEvents*)loadAllActiveFunnels{
    @try {
        NSString *fileExtention = @"txt";
        NSString *allFunnelsDirPath = [BOFFileSystemManager getAllFunnelsToAnalyseDirectoryPath];
        NSString *allFunnelsFilePath = [NSString stringWithFormat:@"%@/%@.%@",allFunnelsDirPath,@"AllFunnels",fileExtention];
        NSError *fileReadingError;
        NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:allFunnelsFilePath withEncoding:NSUTF8StringEncoding andError:&fileReadingError];
        NSError *paringError;
        BOAFunnelAndCodifiedEvents *funnelsAndCodifiedEvents = nil;
        if (jsonString && ![jsonString isEqualToString:@""]) {
            funnelsAndCodifiedEvents = [BOAFunnelAndCodifiedEvents fromJSON:jsonString encoding:NSUTF8StringEncoding error:&paringError];
        }
        return funnelsAndCodifiedEvents;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * funnel network request
 * @return urlRequest as NSURLRequest
 */
-(NSData*)getFunnelPayload{
    @try {
        
        BOAEventsGetRequest *funnelPullPayload = [[BOAEventsGetRequest alloc] init];
        
        BOAEventsGet *funnelSyncTime = [[BOAEventsGet alloc] init];
        funnelSyncTime.lastUpdatedTime = @0; //lastUpdateTime ? lastUpdateTime : nil;
        
        funnelPullPayload.events = funnelSyncTime;
        
        BOAGeoEventsGet *funnelSyncGeo = [[BOAGeoEventsGet alloc] init];
        
        NSDictionary *cKnownLocation = [BOServerDataConverter prepareGeoData];
        if(cKnownLocation != nil && cKnownLocation != (id)[NSNull null]) {
            funnelSyncGeo.city = [cKnownLocation objectForKey:@"city"];
            funnelSyncGeo.reg = [cKnownLocation objectForKey:@"reg"];
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
 * method to store session funnel new data to file system
 * @param sessionFunnelsNewData as BOAFunnelAndCodifiedEvents
 */
-(void)storeSessionFunnelsNewData:(BOAFunnelAndCodifiedEvents*)sessionFunnelsNewData{
    @try {
        if (!sessionFunnelsNewData) {
            return;
        }
        BOAFunnelAndCodifiedEvents *oldFunnelsEvent = [self loadAllActiveFunnels];
        BOOL newFunnelsAdded = NO;
        if (oldFunnelsEvent) {
            NSMutableArray<BOAEventsFunnel *> *oldAndNewEvents = [oldFunnelsEvent.eventsFunnel mutableCopy];
            //TODO: Directly adding from array can lead to duplicate funnel object if server makes a mistake.
            //TODO: Using above incomplete for loop mechanism, we can filter but will see the need & do
            
            //Once model is updated then implement logic for deleting old one as well
            for (BOAEventsFunnel *newEFunnel in sessionFunnelsNewData.eventsFunnel) {
                BOOL isSameFEvent = NO;
                for (BOAEventsFunnel *oldEFunnel in oldAndNewEvents) {
                    if ([newEFunnel.identifier isEqualToString:oldEFunnel.identifier]) {
                        isSameFEvent = YES;
                        break;
                    }
                }
                if (!isSameFEvent) {
                    [oldAndNewEvents addObject:newEFunnel];
                    newFunnelsAdded = YES;
                }
            }
            //Below was duplicating funnel events
            //[oldAndNewEvents addObjectsFromArray:sessionFunnelsNewData.eventsFunnel];
            [oldFunnelsEvent setEventsFunnel:oldAndNewEvents];
        }else{
            oldFunnelsEvent = sessionFunnelsNewData;
            newFunnelsAdded = YES;
        }
        
        if (newFunnelsAdded) {
            [[BOCommonEvents sharedInstance] recordFunnelReceived];
        }
        
        NSError *allFunnelsDataStrError = nil;
        NSString *allFunnelsDataStr = [oldFunnelsEvent toJSON:NSUTF8StringEncoding error:&allFunnelsDataStrError];
        
        NSString *fileExtention = @"txt";
        NSString *allFunnelsDirPath = [BOFFileSystemManager getAllFunnelsToAnalyseDirectoryPath];
        NSString *allFunnelsFilePath = [NSString stringWithFormat:@"%@/%@.%@",allFunnelsDirPath,@"AllFunnels",fileExtention];
        NSError *errorAllFunnelWrite;
        //else file write operation and prapare new object
        [BOFFileSystemManager pathAfterWritingString:allFunnelsDataStr toFilePath:allFunnelsFilePath writingError:&errorAllFunnelWrite];
        
        NSError *funnelPayloadError = nil;
        NSString *sessionFunnelsNewDataStr = [sessionFunnelsNewData toJSON:NSUTF8StringEncoding error:&funnelPayloadError];
        
        NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
        NSString *funnelDownloadLogsDir = [BOFFileSystemManager getLogLevelDirAllFunnelsToAnalyseDirectoryPath];
        NSString *funnelDownloadLogsFile = [NSString stringWithFormat:@"%@/%@-%ld.txt",funnelDownloadLogsDir,dateString,(long)[BOAUtilities get13DigitIntegerTimeStamp]];
        NSError *error;
        //else file write operation and prapare new object
        [BOFFileSystemManager pathAfterWritingString:sessionFunnelsNewDataStr toFilePath:funnelDownloadLogsFile writingError:&error];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to validate funnel data
 * @param sessionFunnelsNewData as BOAFunnelAndCodifiedEvents
 * @return isAllFunnelValid as BOOL
 */
-(BOOL)isFunnelsNewDataValid:(BOAFunnelAndCodifiedEvents*)sessionFunnelsNewData{
    @try {
        BOOL isAllFunnelValid = NO;
        if (sessionFunnelsNewData.eventsFunnel.count > 0) {
            for (BOAEventsFunnel *eventFunnel in sessionFunnelsNewData.eventsFunnel) {
                if (eventFunnel.eventList.count >= 2) {
                    isAllFunnelValid = YES;
                }
            }
        }
        return isAllFunnelValid;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}


/**
 * method to validate new data funnel
 * this methos only filter funnel events and modify objects with only valid funnels
 * @param sessionFunnelsNewData as BOAFunnelAndCodifiedEvents
 * @return funnelsAndCodifiedEvents as BOAFunnelAndCodifiedEvents
 */
-(BOAFunnelAndCodifiedEvents*)validNewDataFunnels:(BOAFunnelAndCodifiedEvents*)sessionFunnelsNewData{
    @try {
        BOAFunnelAndCodifiedEvents *funnelsAndCodifiedEvents = [[BOAFunnelAndCodifiedEvents alloc] init];
        NSMutableArray<BOAEventsFunnel *> *eventFunnelsArr = [NSMutableArray array];
        if (sessionFunnelsNewData.eventsFunnel.count > 0) {
            for (BOAEventsFunnel *eventFunnel in sessionFunnelsNewData.eventsFunnel) {
                if (eventFunnel.eventList.count >= 2) {
                    [eventFunnelsArr addObject:eventFunnel];
                }
            }
        }
        funnelsAndCodifiedEvents.eventsCodified = sessionFunnelsNewData.eventsCodified;
        funnelsAndCodifiedEvents.eventsFunnel = eventFunnelsArr;
        return funnelsAndCodifiedEvents;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

/**
 * method to recursively download funnels
 * timer logic to run funnel task under fixed frequency
 * @param networkRequest as NSURLRequest
 */

-(void)recursivelyDownloadFunnelsUsingURLRequest:(NSURLRequest*)networkRequest{
    @try {
        //write job to fetch and send data as frequency
        //Also save files in directory, expired under history/expired, live under live and then unsynced + sync
        //Create direcotry structure
        //__block BOAFunnelAndCodifiedEvents *bfunnelsAndCodifiedEventsInstance = funnelsAndCodifiedEventsInstance;
        if (requestInProgress) {
            return;
        }
        
        BOFunnelAPI *api = [[BOFunnelAPI alloc] init];
        NSData *payloadData = [self getFunnelPayload];
        [api getFunnelDataModel:payloadData success:^(id  _Nonnull responseObject) {
            
            BOAFunnelAndCodifiedEvents *allFunnels = responseObject;
            //store new data after validation
            if ([self isFunnelsNewDataValid:allFunnels]) {
                //[[BOCommonEvents sharedInstance] recordFunnelReceived];
                BOAFunnelAndCodifiedEvents *validCFEvents = [self validNewDataFunnels:allFunnels];
                [self storeSessionFunnelsNewData:validCFEvents];
                BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
                [analyticsRootUD setObject:[BOAUtilities get13DigitNumberObjTimeStamp] forKey:BO_ANALYTICS_FUNNEL_LAST_UPDATE_TIME_DEFAULTS_KEY];
                //Check for logic in case initially not called & on this success we call again
                //Putting single condition check as, earlier no data exists and object was nil and now possibility is there
                //Or condition here is for more improvements if needed
                //|| funnelsAndCodifiedEventsInstance.eventsFunnel.count == 0
                if (self->funnelsAndCodifiedEventsInstance == nil) {
                    [self prepareFunnnelSyncAndAnalyser];
                }
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
        
        requestInProgress  = YES;
        
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        [analyticsRootUD setObject:[BOAUtilities get13DigitNumberObjTimeStamp] forKey:BO_ANALYTICS_FUNNEL_LAST_SYNC_TIME_DEFAULTS_KEY];
        
        [self recursivelyDownloadFunnelsAfterDelay:[[BOASDKManifestController sharedInstance] delayInterval] usingURLRequest:networkRequest];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to recursively download funnels after delay
 * timer logic to run funnel task under fixed frequency
 * @param milliSeconds as NSTimeInterval
 * @param request as NSURLRequest
 */
-(void)recursivelyDownloadFunnelsAfterDelay:(NSTimeInterval)milliSeconds usingURLRequest:(NSURLRequest*)request{
    @try {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recursivelyDownloadFunnelsUsingURLRequest:) object:request];
        [self performSelector:@selector(recursivelyDownloadFunnelsUsingURLRequest:) withObject:request afterDelay:milliSeconds];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to load funnel network scheduler
 */
-(void)loadFunnelNetworkScheduler{
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        NSNumber *lastSyncTimeStamp = [analyticsRootUD objectForKey:BO_ANALYTICS_FUNNEL_LAST_SYNC_TIME_DEFAULTS_KEY];
        
        BOOL testModeFunnelRetrieve = YES;
        
        if (!testModeFunnelRetrieve && lastSyncTimeStamp && [lastSyncTimeStamp longValue] > 0) {
            long updatedSyncTime = [[BOAUtilities get13DigitNumberObjTimeStamp] longValue] - [lastSyncTimeStamp longValue];
            long possibleDelay = [[BOASDKManifestController sharedInstance] delayInterval]*1000 - updatedSyncTime;
            long delayNow = (possibleDelay > 0) ? possibleDelay : 0;
            delayNow = delayNow / 1000 ; //conevrted in seconds
            [self recursivelyDownloadFunnelsAfterDelay:delayNow usingURLRequest:nil];
        }else{
            [self recursivelyDownloadFunnelsAfterDelay:BO_ANALYTICS_POST_INIT_NETWORK_DELAY usingURLRequest:nil];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * method to check if funnel available
 * @return status as BOOL
 */
-(BOOL)isFunnnelAvailable{
    @try {
        BOAFunnelAndCodifiedEvents *fcEvents = [self loadAllActiveFunnels];
        if (fcEvents && (fcEvents.eventsFunnel.count > 0)) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(BOOL)isFunnelContainsValidEvents:(BOAEventsFunnel*)funnel{
    //Check for events count should be greater than 1
    //Check for two consecutive events, should not be same
    //Do not implement now, get confirmation for v2.0 but possible & check for event duplicate orrurance, should not contain duplicate event
    return YES;
}

//Not using for now, will use it when needed
/*
 -(void)allFunnelsUsingURLRequest:(NSURLRequest*)funnelsURLReq withCompletionHandler:(void (^_Nullable)(NSArray<BOAEventsFunnel *>* allFunnels, NSError * error))completionHandler{
 
 if (!funnelsURLReq) {
 return;
 }
 
 BOFNetworkPromise *funnelPromise = [[BOFNetworkPromise alloc] initWithURLRequest:funnelsURLReq completionHandler:^(NSURLResponse * _Nullable urlResponse, id  _Nullable dataOrLocation, NSError * _Nullable error) {
 if ((((NSHTTPURLResponse*)urlResponse).statusCode == 200) && dataOrLocation) {
 NSError *funnelDecodeError = nil;
 BOAFunnelAndCodifiedEvents *codifiedAndFunnel = [BOAFunnelAndCodifiedEvents fromData:dataOrLocation error:&funnelDecodeError];
 if (codifiedAndFunnel.eventsFunnel.count > 0) {
 completionHandler(codifiedAndFunnel.eventsFunnel, nil);
 }else{
 completionHandler(nil, nil); //setup proper error message
 }
 }else{
 completionHandler(nil, nil); //setup proper error message
 }
 }];
 
 [[BOFNetworkPromiseExecutor sharedInstance] executeNetworkPromise:funnelPromise];
 
 }
 */

-(NSString*)localTestFunnelPath{
    @try {
        NSString *testFunnelPath = [[NSBundle mainBundle] pathForResource:@"login_signup_funnel" ofType:@"json"];
        return testFunnelPath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSURL*)localTestFunnelDummyServerURL{
    @try {
        //Path is nil test
        NSString *testFunnelPath = [[NSBundle mainBundle] pathForResource:@"login_signup_funnel" ofType:@"json"];
        NSURL *testFunnelUrl = [NSURL fileURLWithPath:testFunnelPath];
        return testFunnelUrl;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(void)dealloc{
    requestInProgress = NO;
}
@end
