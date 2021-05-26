//
//  BOANetworkConstants.h
//  BlotoutAnalytics
//
//  Created by Blotout on 07/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAPostEventsDataJob.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAConstants.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import "BOASdkToServerFormat.h"
#import "BOAppSessionData.h"
#import "BOAEvents.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOASDKServerPostSyncEventConfiguration.h"
#import "BOANotificationConstants.h"
#import "BOAAppLifetimeData.h"
#import "BOASDKManifestController.h"

#define FILE_SENT_TO_SERVER @"fileNameDataSentToServer"
#define LIFE_TIME_FILE_SENT_TO_SERVER @"fileNameDataSentToServerLifeTime"

typedef NS_ENUM(NSUInteger, BODataType) {
    BO_SESSION_EVENTS_DATA_TYPE = 0,
    BO_SESSION_RETENTION_DATA_TYPE =1,
    BO_SESSION_PII_PHI_DATA_TYPE =2,
    BO_LIFETIME_DATA_TYPE =3
};

@interface BOAPostEventsDataJob () {
    BOOL iSAppAboutToTerminate;
}

@property (atomic, assign) BOOL _executing;
@property (atomic, assign) BOOL _finished;
@end

@implementation BOAPostEventsDataJob

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminateNotificationReceived) name:BO_ANALYTICS_APP_TERMINATE_KEY object:nil];
        iSAppAboutToTerminate = NO;
    }
    return self;
}

- (void) start {
    @try {
        if ([self isCancelled])
        {
            // Move the operation to the finished state if it is canceled.
            [self willChangeValueForKey:@"isFinished"];
            self._finished = YES;
            [self didChangeValueForKey:@"isFinished"];
            return;
        }
        
        // If the operation is not canceled, begin executing the task.
        [self willChangeValueForKey:@"isExecuting"];
        [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
        self._executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void) main {
    @try {
        if ([self isCancelled]) {
            return;
        }
        if (self.filePath) {
            [self sendEventsWithRandomiser];
        }else if(self.sessionObject){
            [self sendEventsUsingSessionObject];
        }else if(self.filePathLifetimeData){
            [self sendEventsFromLifeTimeModelFileWithRandomiser];
        }else if(self.lifetimeDataObject){
            [self sendEventsUsingLifeTimeSessionObjectWithRandomiser];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)appWillTerminateNotificationReceived{
    iSAppAboutToTerminate = YES;
}

-(void)setSessionObject:(BOAppSessionData *)sessionObject{
    _sessionObject = nil;
    _sessionObject = sessionObject;
}

-(void)setLifetimeDataObject:(BOAAppLifetimeData *)lifetimeDataObject{
    _lifetimeDataObject = nil;
    _lifetimeDataObject = lifetimeDataObject;
}

/**
 * Map Session file that is transferred to synced file
 *
 * @param fileName String
 */
-(void)saveFileNameSentToServer:(NSString*)fileName withPrefKey:(NSString*) prefKey {
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_SESSION_HISTORY_DEFAULTS_KEY];
        //values for which we send data to server
        NSMutableArray *finalFileNames = [[analyticsRootUD objectForKey:prefKey] mutableCopy];
        
        if (finalFileNames != nil && ![finalFileNames containsObject:fileName]) {
            [finalFileNames addObject:fileName];
            [analyticsRootUD setObject:finalFileNames forKey:prefKey];
        } else if (finalFileNames == nil) {
            finalFileNames = [NSMutableArray array];
            [finalFileNames addObject:fileName];
            [analyticsRootUD setObject:finalFileNames forKey:prefKey];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)moveFileToSyncedFolder:(NSString*)filePath withDirPath:(NSString*) dirPath {
    
    @try {
        NSError *moveError = nil;
        NSString *fileName = [filePath lastPathComponent];
        NSString *destPath = [NSString stringWithFormat:@"%@/%@",dirPath,fileName];
        //if relocation error but server sync success then implament logic for rewiting file in synced folder and deleting from here.
        [BOFFileSystemManager moveFileFromLocationPath:filePath toLocationPath:destPath relocationError:&moveError];
        //if move error then write under sync direcotry and remove from notsynced as alternate approach
        if (moveError) {
            NSError *fileWriteError, *error = nil;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:self.filePath withEncoding:NSUTF8StringEncoding andError:&error];
            //else file write operation and prapare new object
            [BOFFileSystemManager pathAfterWritingString:jsonString toFilePath:destPath writingError:&fileWriteError];
            if (!fileWriteError) {
                NSError *removeError = nil;
                [BOFFileSystemManager removeFileFromLocationPath:filePath removalError:&removeError];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)eventsAfterSyncProcessingFor:(BOASystemAndDeveloperEvents*)eventsGroup sessionObject:(BOAppSessionData*)sessionDataObject applifeTimeData:(BOAAppLifetimeData*)appLifetimeDataObject withDataType:(BODataType)dataType{
    @try {
        if (dataType == BO_SESSION_EVENTS_DATA_TYPE || dataType == BO_SESSION_RETENTION_DATA_TYPE) {
            [BOASDKServerPostSyncEventConfiguration sharedInstance].sessionObject = sessionDataObject;
            [[BOASDKServerPostSyncEventConfiguration sharedInstance] updateSentToServerForSessionEvents:eventsGroup];
        }else if(dataType == BO_LIFETIME_DATA_TYPE){
            [BOASDKServerPostSyncEventConfiguration sharedInstance].lifetimeDataObject = appLifetimeDataObject;
            [[BOASDKServerPostSyncEventConfiguration sharedInstance] updateSentToServerForLifeTimeEvents:eventsGroup];
        } else if(dataType == BO_SESSION_PII_PHI_DATA_TYPE) {
            [BOASDKServerPostSyncEventConfiguration sharedInstance].sessionObject = sessionDataObject;
            [[BOASDKServerPostSyncEventConfiguration sharedInstance] updateSentToServerForPIIPHIEvents:eventsGroup forSessionData:sessionDataObject];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

//MARK: Common Randomiser
/**
 * Event Randomize
 *
 * @param serverEvents     Event Dara
 * @param groupSize        Grouping Size
 * @param isRetentionEvent EventType
 * @return Dict
 */
-(NSMutableArray <BOASystemAndDeveloperEvents*> *)randomisedEventsDataFrom:(BOASystemAndDeveloperEvents*)serverEvents withGroupSize:(int)groupSize isKindOfRetention:(BOOL)isRetentionEvent{
    @try {
        NSMutableArray<BOAEvent *> *allEvents = (NSMutableArray*)serverEvents.events;
        int groupingSize = groupSize; //2;
        NSMutableArray <BOASystemAndDeveloperEvents*> *serverEventResized  = [NSMutableArray array];
        do {
            NSMutableArray<BOAEvent *> *groupedSizedEvents = [NSMutableArray arrayWithCapacity:groupingSize];
            if (allEvents.count > groupingSize) {
                for (int i=0; i<groupingSize; i++) {
                    int lowerBound = 0;
                    int upperBound = (int)allEvents.count;
                    int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
                    [groupedSizedEvents  addObject:[allEvents objectAtIndex:rndValue]];
                    [allEvents removeObjectAtIndex:rndValue];
                }
            }else{
                [groupedSizedEvents addObjectsFromArray:allEvents];
                [allEvents removeAllObjects];
            }
            
            BOASystemAndDeveloperEvents *serverEventsL = [BOASystemAndDeveloperEvents fromJSONDictionary:@{
                BO_META: NSNullifyCheck(serverEvents.meta),
                BO_PMETA: isRetentionEvent ? NSNullifyCheck(serverEvents.pmeta) : NSNull.null,
                BO_GEO: NSNullifyCheck(serverEvents.geo), //Check for geo optimisation but good to go for now
                BO_EVENTS :NSNullifyCheck(groupedSizedEvents)
            }];
            [serverEventResized addObject:serverEventsL];
            
        } while (allEvents && (allEvents.count > 0));
        
        return serverEventResized;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

//MARK: Session Based File and Object Events
//MARK: Session Based File Events

/**
 * Send Random Event using Session Object based to time interval set on server
 */
-(void)sendEventsWithRandomiser{
    @try {
        //create historical data of all json that send to server on day by day basis
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_SESSION_HISTORY_DEFAULTS_KEY];
        
        //values for which we send data to server
        NSMutableArray *fileNames = [[analyticsRootUD objectForKey:FILE_SENT_TO_SERVER] mutableCopy];
        NSString *fileName = [self.filePath lastPathComponent];
        if(fileNames != nil && [fileNames containsObject:fileName]) {
            // data already send to server
            [self completeOperation];
        }else{
            
            NSError *error;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:self.filePath withEncoding:NSUTF8StringEncoding andError:&error];
            
            BOAppSessionData *appSessionData = [BOAppSessionData fromJSON:jsonString encoding:NSUTF8StringEncoding error:&error];
            BOASdkToServerFormat *sdkToServerEvent = [BOASdkToServerFormat sharedInstance];
            BOOL isGroupingEnabled = YES;
            int groupingSize = [self getGroupingSize];//2; //-1 will make isGroupingSizeAll to YES
            BOOL isGroupingSizeAll = [self getGroupingSize] == -1; //when size value will be -1 then this is true
            if (isGroupingEnabled && isGroupingSizeAll) {
                [self sendEvents];
                return;
            }
            
            //While using randomiser below original object are being made empty as it's copy by reference
            //make sure it is by reference only
            BOASystemAndDeveloperEvents *serverEvents =  [sdkToServerEvent serverFormatEventsFrom:appSessionData];
            BOASystemAndDeveloperEvents *serverRetentionEvents =  [sdkToServerEvent serverFormatRetentionEventsFrom:appSessionData];
            BOASystemAndDeveloperEvents *piiphiEvents =  [sdkToServerEvent serverFormatPIIPHIEventsFrom:appSessionData];
            
            if (serverEvents == nil && serverRetentionEvents == nil && piiphiEvents == nil) {
                [self saveFileNameSentToServer:fileName withPrefKey:FILE_SENT_TO_SERVER];
                [self moveFileToSyncedFolder:self.filePath withDirPath:[BOAEvents getSyncedDirectoryPath]];
                return;
            }
            
            __block NSInteger totalEventCount = serverEvents.events.count + serverRetentionEvents.events.count;
            if(piiphiEvents != nil) {
                totalEventCount = totalEventCount + 1;
            }
            
            for (int eIndex=0; eIndex<3; eIndex++) {
                NSMutableArray <BOASystemAndDeveloperEvents*> *randomGroupedServerEvents = [NSMutableArray array];
                if (eIndex == BO_SESSION_EVENTS_DATA_TYPE) {
                    if (serverEvents && (serverEvents.events.count > 0)) {
                        randomGroupedServerEvents = [self randomisedEventsDataFrom:serverEvents withGroupSize:groupingSize isKindOfRetention:NO];
                    }
                }else if(eIndex == BO_SESSION_RETENTION_DATA_TYPE){
                    if (serverRetentionEvents && (serverRetentionEvents.events.count > 0)) {
                        randomGroupedServerEvents = [self randomisedEventsDataFrom:serverRetentionEvents withGroupSize:groupingSize isKindOfRetention:YES];
                    }
                } else if(eIndex == BO_SESSION_PII_PHI_DATA_TYPE) {
                    if ((piiphiEvents.piiEvents != nil && piiphiEvents.piiEvents.count >0) || (piiphiEvents.phiEvents != nil && piiphiEvents.phiEvents.count >0)) {
                        randomGroupedServerEvents =(NSMutableArray <BOASystemAndDeveloperEvents*> *) @[piiphiEvents];
                    }
                }
                
                for (BOASystemAndDeveloperEvents *singleGroup in randomGroupedServerEvents) {
                    
                    NSError *dataError = nil;
                    NSData *eventJSONData ;
                    NSUInteger apiEnumCode;
                    if(eIndex == BO_SESSION_EVENTS_DATA_TYPE) {
                        apiEnumCode = BOUrlEndPointEventDataPOST;
                        eventJSONData = [singleGroup toEventsData:&dataError];
                    } else if(eIndex == BO_SESSION_RETENTION_DATA_TYPE) {
                        apiEnumCode = BOUrlEndPointRetentionEventDataPOST;
                        eventJSONData = [singleGroup toEventsData:&dataError];
                    } else if(eIndex == BO_SESSION_PII_PHI_DATA_TYPE) {
                        apiEnumCode = BOUrlEndPointEventDataPOST;
                        eventJSONData = [singleGroup toPIIData:&dataError];
                    }
                    
                    if (eventJSONData && !dataError) {
                        BOFLogDebug(@"Server Format Data %@", [NSString stringWithFormat:@"%@", eventJSONData]);
                        BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
                        [api postEventDataModel:eventJSONData withAPICode:apiEnumCode success:^(id  _Nonnull responseObject) {
                            
                            
                            //#TODO: Added by Blotout - review needed with Ankur as original sync written by Him
                            //Set the server sync time and then same the file
                            appSessionData.singleDaySessions.lastServerSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                            appSessionData.singleDaySessions.allEventsSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                            
                            //This is reverse of SDKtoServer event, here we reverse check mid match and set in that event sentToServer true, also lastServerSyncTimeStamp if needed
                            if(eIndex == BO_SESSION_PII_PHI_DATA_TYPE) {
                                [self eventsAfterSyncProcessingFor:piiphiEvents sessionObject:appSessionData applifeTimeData:nil withDataType:eIndex];
                            } else {
                                [self eventsAfterSyncProcessingFor:singleGroup sessionObject:appSessionData applifeTimeData:nil withDataType:eIndex];
                            }
                            
                            if(eIndex == BO_SESSION_PII_PHI_DATA_TYPE) {
                                totalEventCount =  totalEventCount - 1;
                            } else {
                                totalEventCount =  totalEventCount - singleGroup.events.count;
                            }
                            
                            if (self->iSAppAboutToTerminate || (totalEventCount == 0)) {
                                NSError *jsonConversionError = nil;
                                NSString *appSessionString = [appSessionData toJSON:NSUTF8StringEncoding error:&jsonConversionError];
                                NSError *writeError = nil;
                                NSString *filePath = [BOFFileSystemManager pathAfterWritingString:appSessionString toFilePath:self.filePath writingError:&writeError];
                                if(filePath){
                                    //
                                    BOFLogDebug(@"Rewrite success at:%@", filePath);
                                }else{
                                    //Test and then if it fails, directly write file in syned directory and delete from not syned
                                    BOFLogDebug(@"Rewrite failed at:%@", filePath);
                                }
                            }
                            
                            if (totalEventCount == 0) {
                                [self saveFileNameSentToServer:fileName withPrefKey:FILE_SENT_TO_SERVER];
                                [self moveFileToSyncedFolder:self.filePath withDirPath:[BOAEvents getSyncedDirectoryPath]];
                            }
                            
                        } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
                            if(((NSHTTPURLResponse*)urlResponse).statusCode >= 500){
                                //[randomGroupedServerEvents removeObject:singleGroup];
                                //write logic for reattempt and only 5 max time
                            }
                        }];
                    }
                }
            }
        }
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    
}

/**
 * Send all session events that is not sent to server
 */
-(void)sendEvents {
    @try {
        
        //create historical data of all json that send to server on day by day basis
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_SESSION_HISTORY_DEFAULTS_KEY];
        
        //values for which we send data to server
        NSMutableArray *fileNames = [[analyticsRootUD objectForKey:FILE_SENT_TO_SERVER] mutableCopy];
        NSString *fileName = [self.filePath lastPathComponent];
        if(fileNames != nil && [fileNames containsObject:fileName]) {
            // data already send to server
            [self moveFileToSyncedFolder:self.filePath withDirPath:[BOAEvents getSyncedDirectoryPath]];
            [self completeOperation];
        } else {
            //read file
            NSError *error;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:self.filePath withEncoding:NSUTF8StringEncoding andError:&error];
            
            BOAppSessionData *appSessionData = [BOAppSessionData fromJSON:jsonString encoding:NSUTF8StringEncoding error:&error];
            BOASdkToServerFormat *sdkToServerEvent = [BOASdkToServerFormat sharedInstance];
            
            BOASystemAndDeveloperEvents *serverEvents =  [sdkToServerEvent serverFormatEventsFrom:appSessionData];
            BOASystemAndDeveloperEvents *serverRetentionEvents =  [sdkToServerEvent serverFormatRetentionEventsFrom:appSessionData];
            BOASystemAndDeveloperEvents *piiphiEvents =  [sdkToServerEvent serverFormatPIIPHIEventsFrom:appSessionData];
            
            if (serverEvents == nil && serverRetentionEvents == nil && piiphiEvents == nil) {
                [self saveFileNameSentToServer:fileName withPrefKey:FILE_SENT_TO_SERVER];
                [self moveFileToSyncedFolder:self.filePath withDirPath:[BOAEvents getSyncedDirectoryPath]];
                return;
            }
            
            for (int eIndex=0; eIndex<3; eIndex++) {
                NSData *allEventsData;
                NSUInteger apiEnumCode;
                if(eIndex == BO_SESSION_EVENTS_DATA_TYPE) {
                    apiEnumCode = BOUrlEndPointEventDataPOST;
                    allEventsData = [serverEvents toEventsData:nil];
                } else if(eIndex == BO_SESSION_RETENTION_DATA_TYPE) {
                    apiEnumCode = BOUrlEndPointRetentionEventDataPOST;
                    allEventsData = [serverRetentionEvents toEventsData:nil];
                } else if(eIndex == BO_SESSION_PII_PHI_DATA_TYPE) {
                    apiEnumCode = BOUrlEndPointEventDataPOST;
                    allEventsData = [piiphiEvents toPIIData:nil];
                }
                
                
                if (allEventsData) {
                    BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
                    [api postEventDataModel:allEventsData withAPICode:apiEnumCode success:^(id  _Nonnull responseObject) {
                        
                        [self saveFileNameSentToServer:fileName withPrefKey:FILE_SENT_TO_SERVER];
                        
                        //#TODO: Added by Blotout - review needed with Ankur as original sync written by Him
                        //Set the server sync time and then same the file
                        appSessionData.singleDaySessions.lastServerSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                        appSessionData.singleDaySessions.allEventsSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                        
                        NSError *jsonConversionError = nil;
                        
                        NSString *appSessionString = [appSessionData toJSON:NSUTF8StringEncoding error:&jsonConversionError];
                        NSString *filePath = [BOFFileSystemManager pathAfterWritingString:appSessionString toFilePath:self.filePath writingError:nil];
                        if(filePath){
                            //
                            BOFLogDebug(@"Rewrite success at:%@", filePath);
                        }else{
                            //Test and then if it fails, directly write file in syned directory and delete from not syned
                            BOFLogDebug(@"Rewrite failed at:%@", filePath);
                        }
                        
                        [self moveFileToSyncedFolder:self.filePath withDirPath:[BOAEvents getSyncedDirectoryPath]];
                        
                    } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
                        
                    }];
                }
                
            }
        }
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

//MARK: Session Based Object Events
/**
 * Send Event using Session Object based to time interval set on server
 */
-(void)sendEventsUsingSessionObject {
    @try {
        BOAppSessionData *appSessionDataL = self.sessionObject;
        BOASdkToServerFormat *sdkToServerEvent = [BOASdkToServerFormat sharedInstance];
        BOOL isGroupingEnabled = YES;
        int groupingSize = [self getGroupingSize];//2; //-1 will make isGroupingSizeAll to YES
        BOOL isGroupingSizeAll = [self getGroupingSize] == -1; //when size value will be -1 then this is true
        if (isGroupingEnabled && isGroupingSizeAll) {
            BOASystemAndDeveloperEvents *eventsData =  [sdkToServerEvent serverFormatEventsFrom:appSessionDataL];
            [self sendAllEventsData:eventsData withEventType:BO_SESSION_EVENTS_DATA_TYPE];
            BOASystemAndDeveloperEvents *retentionEventsData =  [sdkToServerEvent serverFormatRetentionEventsFrom:appSessionDataL];
            [self sendAllEventsData:retentionEventsData withEventType:BO_SESSION_RETENTION_DATA_TYPE];
            BOASystemAndDeveloperEvents *piiphiEventsData =  [sdkToServerEvent serverFormatPIIPHIEventsFrom:appSessionDataL];
            [self sendAllEventsData:piiphiEventsData withEventType:BO_SESSION_PII_PHI_DATA_TYPE];
            return;
        }
        //While using randomiser below original object are being made empty as it's copy by reference
        //make sure it is by reference only
        BOASystemAndDeveloperEvents *serverEvents =  [sdkToServerEvent serverFormatEventsFrom:appSessionDataL];
        BOASystemAndDeveloperEvents *serverRetentionEvents =  [sdkToServerEvent serverFormatRetentionEventsFrom:appSessionDataL];
        BOASystemAndDeveloperEvents *piiphiEvents =  [sdkToServerEvent serverFormatPIIPHIEventsFrom:appSessionDataL];
        if (!(serverEvents || serverRetentionEvents || piiphiEvents)) {
            return;
        }
        
        for (int eIndex=0; eIndex<3; eIndex++) {
            NSMutableArray <BOASystemAndDeveloperEvents*> *randomGroupedServerEvents = [NSMutableArray array];
            
            if (eIndex == BO_SESSION_EVENTS_DATA_TYPE) {
                if (serverEvents && (serverEvents.events.count > 0)) {
                    randomGroupedServerEvents = [self randomisedEventsDataFrom:serverEvents withGroupSize:groupingSize isKindOfRetention:NO];
                }
            }else if(eIndex == BO_SESSION_RETENTION_DATA_TYPE){
                if (serverRetentionEvents && (serverRetentionEvents.events.count > 0)) {
                    randomGroupedServerEvents = [self randomisedEventsDataFrom:serverRetentionEvents withGroupSize:groupingSize isKindOfRetention:YES];
                }
            } else if(eIndex == BO_SESSION_PII_PHI_DATA_TYPE) {
                if ((piiphiEvents.piiEvents != nil && piiphiEvents.piiEvents.count >0) || (piiphiEvents.phiEvents != nil && piiphiEvents.phiEvents.count >0)) {
                    randomGroupedServerEvents =(NSMutableArray <BOASystemAndDeveloperEvents*> *) @[piiphiEvents];
                }
            }
            
            for (BOASystemAndDeveloperEvents *singleGroup in randomGroupedServerEvents) {
                NSError *dataError = nil;
                //we can remove key/value if needed here and use manual data creation from dictionary
                NSData *eventJSONData ;
                NSUInteger apiEnumCode;
                if(eIndex == BO_SESSION_EVENTS_DATA_TYPE) {
                    apiEnumCode = BOUrlEndPointEventDataPOST;
                    eventJSONData = [singleGroup toEventsData:&dataError];
                } else if(eIndex == BO_SESSION_RETENTION_DATA_TYPE) {
                    apiEnumCode = BOUrlEndPointRetentionEventDataPOST;
                    eventJSONData = [singleGroup toEventsData:&dataError];
                } else if(eIndex == BO_SESSION_PII_PHI_DATA_TYPE) {
                    apiEnumCode = BOUrlEndPointEventDataPOST;
                    eventJSONData = [singleGroup toPIIData:&dataError];
                }
                
                if (eventJSONData && !dataError) {
                    BOFLogDebug(@"Server Format Data %@", [NSString stringWithFormat:@"%@", eventJSONData]);
                    BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
                    [api postEventDataModel:eventJSONData withAPICode:apiEnumCode success:^(id  _Nonnull responseObject) {
                        self.sessionObject.singleDaySessions.lastServerSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                        if(eIndex == BO_SESSION_PII_PHI_DATA_TYPE) {
                            [self eventsAfterSyncProcessingFor:piiphiEvents sessionObject:appSessionDataL applifeTimeData:nil withDataType:eIndex];
                        } else {
                            [self eventsAfterSyncProcessingFor:singleGroup sessionObject:appSessionDataL applifeTimeData:nil withDataType:eIndex];
                        }
                    } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
                        BOFLogDebug(@"Sync Error:- %@ & Res:-", error, urlResponse);
                    }];
                }
                
            }
        }
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)sendAllEventsData:(BOASystemAndDeveloperEvents*)eventData withEventType:(BODataType)dataType{
    @try {
        if (eventData) {
            BOFLogDebug(@"Server Format Data %@", [NSString stringWithFormat:@"%@", eventData]);
            BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
            BOUrlEndPoint eventEndPoint;
            NSData *eventDataObj;
            
            if (dataType == BOUrlEndPointRetentionEventDataPOST) {
                eventEndPoint = BOUrlEndPointRetentionEventDataPOST;
                eventDataObj = [eventData toEventsData:nil];
            }else if(dataType == BO_SESSION_PII_PHI_DATA_TYPE) {
                eventEndPoint = BOUrlEndPointEventDataPOST;
                eventDataObj = [eventData toPIIData:nil];
            } else {
                eventEndPoint = BOUrlEndPointEventDataPOST;
                eventDataObj = [eventData toEventsData:nil];
            }
            
            [api postEventDataModel:eventDataObj withAPICode:eventEndPoint success:^(id  _Nonnull responseObject) {
                [self eventsAfterSyncProcessingFor:eventData sessionObject:self.sessionObject applifeTimeData:nil withDataType:dataType];
                self.sessionObject.singleDaySessions.lastServerSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
            }];
        }
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

//---------------------------------------------Using LifeTimeModel------------------------------------------------
//MARK: LifeTime(Monthly) Session Based File and Object Events
//MARK: LifeTime(Monthly) Session Based File Events
/**
 * Send Lifetime Event using Lifetime file based to time interval set on server
 */
-(void)sendEventsFromLifeTimeModelFileWithRandomiser{
    
    @try {
        //create historical data of all json that send to server on day by day basis
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_SESSION_HISTORY_DEFAULTS_KEY];
        
        //values for which we send data to server
        NSMutableArray *fileNames = [[analyticsRootUD objectForKey:LIFE_TIME_FILE_SENT_TO_SERVER] mutableCopy];
        NSString *fileName = [self.filePathLifetimeData lastPathComponent];
        if(fileNames != nil && [fileNames containsObject:fileName]) {
            // data already send to server
            [self completeOperation];
        }else{
            
            NSError *error;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:self.filePathLifetimeData withEncoding:NSUTF8StringEncoding andError:&error];
            
            BOAAppLifetimeData *appLifeTimeData = [BOAAppLifetimeData fromJSON:jsonString encoding:NSUTF8StringEncoding error:&error];
            BOASdkToServerFormat *sdkToServerEvent = [BOASdkToServerFormat sharedInstance];
            BOOL isGroupingEnabled = YES;
            int groupingSize = [self getGroupingSize];//2; //-1 will make isGroupingSizeAll to YES
            BOOL isGroupingSizeAll = [self getGroupingSize] == -1; //when size value will be -1 then this is true
            if (isGroupingEnabled && isGroupingSizeAll) {
                [self sendEventsFromLifeTimeModelFile];
                return;
            }
            
            //While using randomiser below original object are being made empty as it's copy by reference
            //make sure it is by reference only
            
            BOASystemAndDeveloperEvents *serverEvents =  [sdkToServerEvent serverFormatLifeTimeEventsFrom:appLifeTimeData];
            BOASystemAndDeveloperEvents *serverRetentionEvents =  [sdkToServerEvent serverFormatLifeTimeRetentionEventsFrom:appLifeTimeData];
            
            if (!(serverEvents || serverRetentionEvents)) {
                return;
            }
            
            __block NSInteger totalEventCount = serverEvents.events.count + serverRetentionEvents.events.count;
            
            for (int eIndex=0; eIndex<2; eIndex++) {
                NSMutableArray <BOASystemAndDeveloperEvents*> *randomGroupedServerEvents = [NSMutableArray array];
                if (eIndex == 0) {
                    if (serverEvents && (serverEvents.events.count > 0)) {
                        randomGroupedServerEvents = [self randomisedEventsDataFrom:serverEvents withGroupSize:groupingSize isKindOfRetention:NO];
                    }
                }else{
                    if (serverRetentionEvents && (serverRetentionEvents.events.count > 0)) {
                        randomGroupedServerEvents = [self randomisedEventsDataFrom:serverRetentionEvents withGroupSize:groupingSize isKindOfRetention:YES];
                    }
                }
                for (BOASystemAndDeveloperEvents *singleGroup in randomGroupedServerEvents) {
                    if (singleGroup.events.count > 0) {
                        NSError *dataError = nil;
                        NSData *eventJSONData = [singleGroup toEventsData:&dataError];
                        if (eventJSONData && !dataError) {
                            BOFLogDebug(@"Server Format Data %@", [NSString stringWithFormat:@"%@", eventJSONData]);
                            BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
                            NSUInteger apiEnumCode = BOUrlEndPointEventDataPOST;
                            if (eIndex == 1) {
                                apiEnumCode = BOUrlEndPointRetentionEventDataPOST;
                            }
                            [api postEventDataModel:eventJSONData withAPICode:apiEnumCode success:^(id  _Nonnull responseObject) {
                                //#TODO: Added by Blotout - review needed with Ankur as original sync written by Him
                                //Set the server sync time and then same the file
                                appLifeTimeData.lastServerSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                                appLifeTimeData.allEventsSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                                
                                //This is reverse of SDKtoServer event, here we reverse check mid match and set in that event sentToServer true, also lastServerSyncTimeStamp if needed
                                [self eventsAfterSyncProcessingFor:singleGroup sessionObject:nil applifeTimeData:appLifeTimeData withDataType:BO_LIFETIME_DATA_TYPE];
                                totalEventCount =  totalEventCount - singleGroup.events.count;
                                
                                if (self->iSAppAboutToTerminate || (totalEventCount == 0)) {
                                    NSError *jsonConversionError = nil;
                                    NSString *appSessionString = [appLifeTimeData toJSON:NSUTF8StringEncoding error:&jsonConversionError];
                                    NSError *writeError = nil;
                                    NSString *filePath = [BOFFileSystemManager pathAfterWritingString:appSessionString toFilePath:self.filePathLifetimeData writingError:&writeError];
                                    if(filePath){
                                        //
                                        BOFLogDebug(@"Rewrite success at:%@", filePath);
                                    }else{
                                        //Test and then if it fails, directly write file in syned directory and delete from not syned
                                        BOFLogDebug(@"Rewrite failed at:%@", filePath);
                                    }
                                }
                                
                                if (totalEventCount == 0) {
                                    
                                    NSString *date = appLifeTimeData.date;
                                    BOOL isSameMonth = [BOAUtilities isMonthAndYearSameOfDate:[BOAUtilities getCurrentDate] andDateStr:date inFormat:@"yyyy-MM-dd"];
                                    if (!isSameMonth) {
                                        [self saveFileNameSentToServer:fileName withPrefKey:LIFE_TIME_FILE_SENT_TO_SERVER];
                                        [self moveFileToSyncedFolder:self.filePathLifetimeData withDirPath:[BOAEvents getLifeTimeDataSyncedDirectoryPath]];
                                    }
                                }
                                
                            } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
                                if(((NSHTTPURLResponse*)urlResponse).statusCode >= 500){
                                    //[randomGroupedServerEvents removeObject:singleGroup];
                                    //write logic for reattempt and only 5 max time
                                }
                            }];
                        }
                        
                    }
                }
            }
        }
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

/**
 * Send Event using Lifetime Session file
 */
-(void)sendEventsFromLifeTimeModelFile{
    @try {
        
        //create historical data of all json that send to server on day by day basis
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_SESSION_HISTORY_DEFAULTS_KEY];
        
        //values for which we send data to server
        NSMutableArray *fileNames = [[analyticsRootUD objectForKey:LIFE_TIME_FILE_SENT_TO_SERVER] mutableCopy];
        NSString *fileName = [self.filePathLifetimeData lastPathComponent];
        if(fileNames != nil && [fileNames containsObject:fileName]) {
            // data already send to server
            [self completeOperation];
        } else {
            //read file
            NSError *error;
            NSString *jsonString = [BOFFileSystemManager contentOfFileAtPath:self.filePathLifetimeData withEncoding:NSUTF8StringEncoding andError:&error];
            
            BOAAppLifetimeData *appLifeTimeData = [BOAAppLifetimeData fromJSON:jsonString encoding:NSUTF8StringEncoding error:&error];
            BOASdkToServerFormat *sdkToServerEvent = [BOASdkToServerFormat sharedInstance];
            
            BOASystemAndDeveloperEvents *otherEventData =  [sdkToServerEvent serverFormatLifeTimeEventsFrom:appLifeTimeData];
            BOASystemAndDeveloperEvents *retentionEventData =  [sdkToServerEvent serverFormatLifeTimeRetentionEventsFrom:appLifeTimeData];
            
            if (!otherEventData && !retentionEventData) {
                return;
            }
            
            for (int eIndex=0; eIndex<2; eIndex++) {
                BOASystemAndDeveloperEvents *allEvents = otherEventData;
                NSData *allEventsData = [otherEventData toEventsData:nil];
                NSUInteger apiEnumCode = BOUrlEndPointEventDataPOST;
                if (eIndex == 1) {
                    allEventsData = [retentionEventData toEventsData:nil];
                    allEvents = retentionEventData;
                    apiEnumCode = BOUrlEndPointRetentionEventDataPOST;
                }
                
                if (allEventsData) {
                    BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
                    [api postEventDataModel:allEventsData withAPICode:apiEnumCode success:^(id  _Nonnull responseObject) {
                        
                        //#TODO: Added by Blotout - review needed with Ankur as original sync written by Him
                        //Set the server sync time and then same the file
                        appLifeTimeData.lastServerSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                        appLifeTimeData.allEventsSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                        [self eventsAfterSyncProcessingFor:allEvents sessionObject:nil applifeTimeData:appLifeTimeData withDataType:BO_LIFETIME_DATA_TYPE];
                        NSError *jsonConversionError = nil;
                        NSString *appSessionString = [appLifeTimeData toJSON:NSUTF8StringEncoding error:&jsonConversionError];
                        NSString *filePath = [BOFFileSystemManager pathAfterWritingString:appSessionString toFilePath:self.filePathLifetimeData writingError:nil];
                        
                        if(filePath){
                            //
                            BOFLogDebug(@"Rewrite success at:%@", filePath);
                        }else{
                            //Test and then if it fails, directly write file in syned directory and delete from not syned
                            BOFLogDebug(@"Rewrite failed at:%@", filePath);
                        }
                        
                        NSString *date = appLifeTimeData.date;
                        BOOL isSameMonth = [BOAUtilities isMonthAndYearSameOfDate:[BOAUtilities getCurrentDate] andDateStr:date inFormat:@"yyyy-MM-dd"];
                        
                        if (!isSameMonth) {
                            [self saveFileNameSentToServer:fileName withPrefKey:LIFE_TIME_FILE_SENT_TO_SERVER];
                            [self moveFileToSyncedFolder:self.filePathLifetimeData withDirPath:[BOAEvents getLifeTimeDataSyncedDirectoryPath]];
                        }
                        
                    } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
                        
                    }];
                }
            }
        }
        
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

//MARK: LifeTime(Monthly) Session Based Object Events
/**
 * Send Lifetime Random Event using Lifetime Object based to time interval set on server
 */
-(void)sendEventsUsingLifeTimeSessionObjectWithRandomiser {
    @try {
        BOAAppLifetimeData *appLifeTimeData = self.lifetimeDataObject;
        BOASdkToServerFormat *sdkToServerEvent = [BOASdkToServerFormat sharedInstance];
        BOOL isGroupingEnabled = YES;
        int groupingSize = [self getGroupingSize];//2; //-1 will make isGroupingSizeAll to YES
        BOOL isGroupingSizeAll = [self getGroupingSize] == -1; //when size value will be -1 then this is true
        if (isGroupingEnabled && isGroupingSizeAll) {
            BOASystemAndDeveloperEvents *eventsData =  [sdkToServerEvent serverFormatLifeTimeEventsFrom:appLifeTimeData];
            [self sendAllLifeTimeEventsData:eventsData withRetentionCheck:NO];
            BOASystemAndDeveloperEvents *retentionEventsData =  [sdkToServerEvent serverFormatLifeTimeRetentionEventsFrom:appLifeTimeData];
            [self sendAllLifeTimeEventsData:retentionEventsData withRetentionCheck:YES];
            return;
        }
        
        //While using randomiser below original object are being made empty as it's copy by reference
        //make sure it is by reference only
        BOASystemAndDeveloperEvents *serverEvents =  [sdkToServerEvent serverFormatLifeTimeEventsFrom:appLifeTimeData];
        BOASystemAndDeveloperEvents *serverRetentionEvents =  [sdkToServerEvent serverFormatLifeTimeRetentionEventsFrom:appLifeTimeData];
        
        if (!(serverEvents || serverRetentionEvents)) {
            return;
        }
        
        for (int eIndex=0; eIndex<2; eIndex++) {
            NSMutableArray <BOASystemAndDeveloperEvents*> *randomGroupedServerEvents = [NSMutableArray array];
            if (eIndex == 0) {
                if (serverEvents && (serverEvents.events.count > 0)) {
                    randomGroupedServerEvents = [self randomisedEventsDataFrom:serverEvents withGroupSize:groupingSize isKindOfRetention:NO];
                }
            }else{
                if (serverRetentionEvents && (serverRetentionEvents.events.count > 0)) {
                    randomGroupedServerEvents = [self randomisedEventsDataFrom:serverRetentionEvents withGroupSize:groupingSize isKindOfRetention:YES];
                }
            }
            for (BOASystemAndDeveloperEvents *singleGroup in randomGroupedServerEvents) {
                if (singleGroup.events.count > 0) {
                    NSError *dataError = nil;
                    NSData *eventJSONData = [singleGroup toEventsData:&dataError];
                    if (eventJSONData && !dataError) {
                        BOFLogDebug(@"Server Format Data %@", [NSString stringWithFormat:@"%@", eventJSONData]);
                        BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
                        NSUInteger apiEnumCode = BOUrlEndPointEventDataPOST;
                        if (eIndex == 1) {
                            apiEnumCode = BOUrlEndPointRetentionEventDataPOST;
                        }
                        
                        [api postEventDataModel:eventJSONData withAPICode:apiEnumCode success:^(id  _Nonnull responseObject) {
                            self.lifetimeDataObject.lastServerSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
                            
                            //This is reverse of SDKtoServer event, here we reverse check mid match and set in that event sentToServer true, also lastServerSyncTimeStamp if needed
                            [self eventsAfterSyncProcessingFor:singleGroup sessionObject:nil applifeTimeData:self.lifetimeDataObject withDataType:BO_LIFETIME_DATA_TYPE];
                            
                            //self.lifetimeDataObject = nil;
                        } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
                        }];
                    }
                    
                }
            }
        }
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)sendAllLifeTimeEventsData:(BOASystemAndDeveloperEvents*)eventData withRetentionCheck:(BOOL)isRetentionEvent{
    @try {
        if (eventData) {
            BOFLogDebug(@"Server Format Data %@", [NSString stringWithFormat:@"%@", eventData]);
            BOEventPostAPI *api = [[BOEventPostAPI alloc] init];
            
            BOUrlEndPoint eventEndPoint = BOUrlEndPointEventDataPOST;
            if (isRetentionEvent) {
                eventEndPoint = BOUrlEndPointRetentionEventDataPOST;
            }
            NSData *eventDataObj = [eventData toEventsData:nil];
            [api postEventDataModel:eventDataObj withAPICode:eventEndPoint success:^(id  _Nonnull responseObject) {
                [self eventsAfterSyncProcessingFor:eventData sessionObject:nil applifeTimeData:self.lifetimeDataObject withDataType:BO_LIFETIME_DATA_TYPE];
                self.lifetimeDataObject.lastServerSyncTimeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
            }];
        }
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (int)getGroupingSize {
    @try {
        NSNumber *mergeCounter = [[BOASDKManifestController sharedInstance] eventCodifiedMergeCounter];
        return mergeCounter.intValue > 0 ? mergeCounter.intValue : 1;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 1;
}

//MARK: Operation class methods
- (BOOL) isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return self._executing;
}

- (BOOL)isFinished {
    return self._finished;
}

- (void)completeOperation {
    @try {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        
        self._executing = NO;
        self._finished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
