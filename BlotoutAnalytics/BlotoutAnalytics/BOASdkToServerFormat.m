//
//  BOASdkToServerFormat.m
//  BlotoutAnalytics
//
//  Created by Blotout on 20/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOASdkToServerFormat.h"
#import "BOAppSessionData.h"
#import <BlotoutFoundation/BOFSystemServices.h>
#import "BOANetworkConstants.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAConstants.h"
#import "BOADeviceAndAppFraudController.h"
#import "BOAAppSessionEvents.h"
#import "BOAAppLifetimeData.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOServerDataConverter.h"
#import "BOANetworkConstants.h"
#import "BOASDKManifestController.h"
#import "BlotoutAnalytics.h"
#import "BOASDKManifestController.h"
#import "BOAEvents.h"
#import <BlotoutFoundation/BOCrypt.h>
#import "BOEncryptionManager.h"
#import "BOSharedManager.h"

static id sBOASdkToServerFormat = nil;
static NSString *BO_CRYPTO_IVX = @"Q0BG17E2819IWZYQ";

@implementation BOASdkToServerFormat

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaSdkToServerFormatOnceToken = 0;
    dispatch_once(&boaSdkToServerFormatOnceToken, ^{
        sBOASdkToServerFormat = [[[self class] alloc] init];
    });
    return  sBOASdkToServerFormat;
}

-(BOASystemAndDeveloperEvents*)serverFormatEventsFromJSONString:(NSString*)sessionJSON{
    return nil;
}

-(BOASystemAndDeveloperEvents*)serverFormatEventsFromDict:(NSDictionary*)eventDict{
    return nil;
}

-(BOASystemAndDeveloperEvents*)serverFormatEventsFromJSONData:(NSData*)sessionData{
    return nil;
}

-(BOASystemAndDeveloperEvents*)serverFormatRetentionEventsFrom:(BOAppSessionData*)sessionData{
    @try {
        
        //Return No retention Event in case of firstParty container
        if([BOASDKManifestController sharedInstance].sdkDeploymentMode == BO_DEPLOYMENT_MODE_FIRST_PARTY) {
            return nil;
        }
        
        //prepare UBI Events
        NSMutableArray *events = [NSMutableArray array];
        [events addObjectsFromArray:[self prepareRetentionEvents:sessionData]];
        if (!events || (events.count == 0)) {
            return nil;
        }
        //add userID mapping
        if([[BOASDKManifestController sharedInstance] sdkMapUserId]) {
            events = [self addUserIdMapping: events];
        }
        
        NSDictionary *pmetaInfoDict = [BOServerDataConverter preparePreviousMetaData:sessionData]; //check & send previous session
        BOAMeta *pMetaInfo = pmetaInfoDict ? [BOAMeta fromJSONDictionary:pmetaInfoDict] : nil;
        
        BOAMeta *metaInfo = [self prepareMetaData:sessionData];
        BOAGeo *geoInfo = [self prepareGeoData:sessionData];
        
        if (metaInfo) {
            BOASystemAndDeveloperEvents *serverEvents = [BOASystemAndDeveloperEvents fromJSONDictionary:@{
                BO_META: NSNullifyCheck(metaInfo),
                BO_PMETA: NSNullifyCheck(pMetaInfo),
                BO_GEO: NSNullifyCheck(geoInfo),
                BO_EVENTS: events
            }];
            
            //Return data only when there are events else nil
            if (serverEvents.events.count > 0) {
                return serverEvents;
            }
        }
        //When nil is returned then check should be made to call server APIs
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(BOASystemAndDeveloperEvents*)serverFormatEventsFrom:(BOAppSessionData*)sessionData{
    @try {
        //prepare UBI Events
        NSMutableArray *events = [NSMutableArray array];
        if([[BlotoutAnalytics sharedInstance] isDeveloperEventsEnabled] && [[BlotoutAnalytics sharedInstance] isEnabled]) {
            [events addObjectsFromArray:[self prepareDeveloperCodifiedEvents:sessionData]];
        }
        
        if([[BlotoutAnalytics sharedInstance] isEnabled]) {
            [events addObjectsFromArray:[self prepareCrashEvents:sessionData]];
            
            //system events
            if([[BOASDKManifestController sharedInstance] sdkPushSystemEvents]) {
                [events addObjectsFromArray:[self prepareAppStateEvents:sessionData]];
                [events addObjectsFromArray:[self prepareCommonEvents:sessionData]];
                [events addObjectsFromArray:[self prepareDeviceEvents:sessionData]];
                [events addObjectsFromArray:[self prepareMemoryEvents:sessionData]];
            }
            if([[BOASDKManifestController sharedInstance] sdkPushPIIEvents]) {
                [events addObjectsFromArray:[self preparePIIEvents:sessionData]];
                [events addObjectsFromArray:[self prepareAdInfo:sessionData]];
            }
            if([[BOASDKManifestController sharedInstance] sdkBehaviourEvents]) {
                [events addObjectsFromArray:[self prepareNavigationEvents:sessionData]];
            }
        }
        
        
        if (!events || (events.count == 0)) {
            return nil;
        }
        
        //add userID mapping
        if([[BOASDKManifestController sharedInstance] sdkMapUserId]) {
            events = [self addUserIdMapping: events];
        }
        
        BOAMeta *metaInfo = [self prepareMetaData:sessionData];
        BOAGeo *geoInfo = [self prepareGeoData:sessionData];
        
        if (metaInfo) {
            BOASystemAndDeveloperEvents *serverEvents = [BOASystemAndDeveloperEvents fromJSONDictionary:@{
                BO_META: NSNullifyCheck(metaInfo),
                BO_PMETA: NSNull.null,
                BO_GEO: NSNullifyCheck(geoInfo),
                BO_EVENTS: events
            }];
            
            //Return data only when there are events else nil
            if (serverEvents.events.count > 0) {
                return serverEvents;
            }
        }
        
        //When nil is returned then check should be made to call server APIs
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(BOAPIIPHIEvent*)getEncryptedEvent:(NSString*)publicKey withSecretKey:(NSString*)secretKey withDictionary:(NSArray*)events {
    
    @try {
        NSString *piiEncryptedData = nil;
        NSString *piiEncryptedSecretKey = nil;
        if(events != nil && events.count > 0) {
            NSMutableArray *dataArray = [NSMutableArray array];
            for (BOAEvent *event in events) {
                [dataArray addObject:[event JSONDictionary]];
            }
            
            NSData * dataToEncryptPII = [NSJSONSerialization dataWithJSONObject:dataArray options:NSJSONWritingFragmentsAllowed error:nil ];
            
            piiEncryptedData = [BOCrypt encryptDataWithoutHash:dataToEncryptPII key:secretKey iv:BO_CRYPTO_IVX];
            
            piiEncryptedSecretKey = [BOEncryptionManager encryptString:secretKey publicKey:publicKey];
            
            NSMutableDictionary *piiPayload = [NSMutableDictionary dictionary];
            [piiPayload setObject:NSNullifyCheck(piiEncryptedSecretKey) forKey:BO_KEY];
            [piiPayload setObject:NSNullifyCheck(BO_CRYPTO_IVX) forKey:BO_IV];
            [piiPayload setObject:NSNullifyCheck(piiEncryptedData) forKey:BO_DATA];
            
            if(piiEncryptedSecretKey != nil && piiEncryptedSecretKey.length > 0 && piiEncryptedData != nil && piiEncryptedData.length > 0) {
                BOAPIIPHIEvent *piiEventObject = [BOAPIIPHIEvent fromJSONDictionary:piiPayload];
                return piiEventObject;
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    
    return nil;
}

-(BOASystemAndDeveloperEvents*)serverFormatPIIPHIEventsFrom:(BOAppSessionData*)sessionData{
    @try {
        //prepare UBI Events
        NSMutableArray *piiEvents = [NSMutableArray array];
        NSMutableArray *phiEvents = [NSMutableArray array];
        
        if([BlotoutAnalytics sharedInstance].isDeveloperEventsEnabled && [BlotoutAnalytics sharedInstance].isEnabled) {
            
            if([BOASDKManifestController sharedInstance].sdkPushPIIEvents) {
                [piiEvents addObjectsFromArray:[self prepareDeveloperCodifiedPIIEvents:sessionData]];
            }
            
            if([BOASDKManifestController sharedInstance].sdkPushPHIEvents) {
                [phiEvents addObjectsFromArray:[self prepareDeveloperCodifiedPHIEvents:sessionData]];
            }
        }
        
        //add userID mapping
        if([BOASDKManifestController sharedInstance].sdkMapUserId) {
            if(piiEvents != nil && piiEvents.count > 0) {
                piiEvents = [self addUserIdMapping:piiEvents];
            }
            
            if(phiEvents != nil && phiEvents.count > 0) {
                phiEvents = [self addUserIdMapping:phiEvents];
            }
        }
        
        NSMutableDictionary *serverEvents = [NSMutableDictionary dictionary];
        
        if ((piiEvents != nil && piiEvents.count > 0)
            || (phiEvents != nil && phiEvents.count > 0) ) {
            
            NSString *secretKey = [BOAUtilities getUUIDString];
            secretKey = [secretKey stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            BOAPIIPHIEvent *piiEventObject = [self getEncryptedEvent:[BOASDKManifestController sharedInstance].piiPublicKey withSecretKey:secretKey withDictionary:piiEvents];
            if(piiEventObject != nil) {
                [serverEvents setObject:NSNullifyCheck(piiEventObject) forKey:BO_PII];
            } else {
                [serverEvents setObject:NSNullifyCheck(piiEventObject) forKey:BO_PII];
            }
            
            BOAPIIPHIEvent *phiEventObject = [self getEncryptedEvent:[BOASDKManifestController sharedInstance].phiPublickey withSecretKey:secretKey withDictionary:phiEvents];
            if(phiEventObject != nil) {
                [serverEvents setObject:NSNullifyCheck(phiEventObject) forKey:BO_PHI];
            } else {
                [serverEvents setObject:NSNullifyCheck(phiEventObject) forKey:BO_PHI];
            }
            
            if(piiEventObject != nil  || phiEventObject != nil) {
                BOAMeta *metaInfo = [self prepareMetaData:sessionData];
                BOAGeo *geoInfo = [self prepareGeoData:sessionData];
                
                [serverEvents setObject:NSNullifyCheck(metaInfo) forKey:BO_META];
                [serverEvents setObject:NSNullifyCheck(geoInfo) forKey:BO_GEO];
                [serverEvents setObject:NSNullifyCheck(piiEvents) forKey:BO_PII_EVENTS];
                [serverEvents setObject:NSNullifyCheck(phiEvents) forKey:BO_PHI_EVENTS];
                
                
                BOASystemAndDeveloperEvents *developerEvents = [BOASystemAndDeveloperEvents fromJSONDictionary:(NSDictionary*)serverEvents];
                return developerEvents;
                
            } else {
                return nil;
            }
            
        } else {
            return nil;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSData*)serverFormatEventsJSONFrom:(BOAppSessionData*)sessionData{
    @try {
        //prepare UBI Events
        NSMutableArray *events = [NSMutableArray array];
        if([[BlotoutAnalytics sharedInstance] isDeveloperEventsEnabled] && [[BlotoutAnalytics sharedInstance] isEnabled]) {
            [events addObjectsFromArray:[self prepareDeveloperCodifiedEvents:sessionData]];
        }
        
        if([[BlotoutAnalytics sharedInstance] isEnabled]) {
            [events addObjectsFromArray:[self prepareCrashEvents:sessionData]];
            
            //system events
            if([[BOASDKManifestController sharedInstance] sdkPushSystemEvents]) {
                [events addObjectsFromArray:[self prepareAppStateEvents:sessionData]];
                [events addObjectsFromArray:[self prepareCommonEvents:sessionData]];
                [events addObjectsFromArray:[self prepareDeviceEvents:sessionData]];
                [events addObjectsFromArray:[self prepareMemoryEvents:sessionData]];
            }
            if([[BOASDKManifestController sharedInstance] sdkPushPIIEvents]) {
                [events addObjectsFromArray:[self preparePIIEvents:sessionData]];
                [events addObjectsFromArray:[self prepareAdInfo:sessionData]];
            }
            if([[BOASDKManifestController sharedInstance] sdkBehaviourEvents]) {
                [events addObjectsFromArray:[self prepareNavigationEvents:sessionData]];
            }
        }
        
        
        if (!events || (events.count == 0)) {
            return nil;
        }
        
        //add userID mapping
        if([[BOASDKManifestController sharedInstance] sdkMapUserId]) {
            events = [self addUserIdMapping: events];
        }
        
        BOAMeta *metaInfo = [self prepareMetaData:sessionData];
        BOAGeo *geoInfo = [self prepareGeoData:sessionData];
        BOASystemAndDeveloperEvents *serverEvents = [BOASystemAndDeveloperEvents fromJSONDictionary:@{
            BO_META: NSNullifyCheck(metaInfo),
            BO_PMETA: NSNull.null,
            BO_GEO: NSNullifyCheck(geoInfo),
            BO_EVENTS: events
        }];
        
        NSError *jsonError;
        NSString *dataJSONString = [serverEvents toJSON:NSUTF8StringEncoding error:&jsonError];
        BOFLogDebug(@"Server Format Data String%@", dataJSONString);
        
        //Return data only when there are events else nil
        if (serverEvents.events.count > 0) {
            NSError *dataError;
            NSData *eventJSONData = [serverEvents toData:&dataError];
            return eventJSONData;
        }
        //When nil is returned then check should be made to call server APIs
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSData*)serverFormatRetentionEventsJSONFrom:(BOAppSessionData*)sessionData{
    @try {
        
        //Return No retention Event in case of firstParty container
        if([BOASDKManifestController sharedInstance].sdkDeploymentMode == BO_DEPLOYMENT_MODE_FIRST_PARTY) {
            return nil;
        }
        
        //prepare UBI Events
        NSMutableArray *events = [NSMutableArray array];
        [events addObjectsFromArray:[self prepareRetentionEvents:sessionData]];
        if (!events || (events.count == 0)) {
            return nil;
        }
        
        //add userID mapping
        if([[BOASDKManifestController sharedInstance] sdkMapUserId]) {
            events = [self addUserIdMapping: events];
        }
        
        NSDictionary *pMetaInfoDict = [BOServerDataConverter preparePreviousMetaData:sessionData]; //check & send previous session
        BOAMeta *pMetaInfo = pMetaInfoDict ? [BOAMeta fromJSONDictionary:pMetaInfoDict] : nil;
        
        BOAMeta *metaInfo = [self prepareMetaData:sessionData];
        BOAGeo *geoInfo = [self prepareGeoData:sessionData];
        BOASystemAndDeveloperEvents *serverEvents = [BOASystemAndDeveloperEvents fromJSONDictionary:@{
            BO_META: NSNullifyCheck(metaInfo),
            BO_PMETA: NSNullifyCheck(pMetaInfo),
            BO_GEO: NSNullifyCheck(geoInfo),
            BO_EVENTS: events
        }];
        
        //dataJSONString - For testing purpose to see what is being sent
        NSError *jsonError;
        NSString *dataJSONString = [serverEvents toJSON:NSUTF8StringEncoding error:&jsonError];
        BOFLogDebug(@"Server Format Data String%@", dataJSONString);
        
        //Return data only when there are events else nil
        if (serverEvents.events.count > 0) {
            NSError *dataError;
            NSData *eventJSONData = [serverEvents toData:&dataError];
            return eventJSONData;
        }
        //When nil is returned then check should be made to call server APIs
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSData*)serverFormatLifeTimeEventsJSONFrom:(BOAAppLifetimeData*)lifetimeSessionData{
    return nil;
}

-(NSData*)serverFormatLifeTimeRetentionEventsJSONFrom:(BOAAppLifetimeData*)lifetimeSessionData{
    @try {
        
        //Return No retention Event in case of firstParty container
        if([BOASDKManifestController sharedInstance].sdkDeploymentMode == BO_DEPLOYMENT_MODE_FIRST_PARTY) {
            return nil;
        }
        
        //prepare UBI Events
        NSMutableArray *events = [NSMutableArray array];
        [events addObjectsFromArray:[self prepareRetentionEventsFromLifeTime:lifetimeSessionData]];
        if (!events || (events.count == 0)) {
            return nil;
        }
        
        //add userID mapping
        if([[BOASDKManifestController sharedInstance] sdkMapUserId]) {
            events = [self addUserIdMapping: events];
        }
        
        BOAMeta *metaInfo = [self prepareMetaData:nil];
        BOAGeo *geoInfo = [self prepareGeoData:nil];
        
        BOASystemAndDeveloperEvents *serverEvents = [BOASystemAndDeveloperEvents fromJSONDictionary:@{
            BO_META: NSNullifyCheck(metaInfo),
            BO_PMETA: NSNull.null,
            BO_GEO: NSNullifyCheck(geoInfo),
            BO_EVENTS: events
        }];
        
        //dataJSONString - For testing purpose to see what is being sent
        NSError *jsonError;
        NSString *dataJSONString = [serverEvents toJSON:NSUTF8StringEncoding error:&jsonError];
        BOFLogDebug(@"Server Format Data String%@", dataJSONString);
        
        //Return data only when there are events else nil
        if (serverEvents.events.count > 0) {
            NSError *dataError;
            NSData *eventJSONData = [serverEvents toData:&dataError];
            return eventJSONData;
        }
        //When nil is returned then check should be made to call server APIs
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
-(BOASystemAndDeveloperEvents*)serverFormatLifeTimeEventsFrom:(BOAAppLifetimeData*)lifetimeSessionData{
    //When nil is returned then check should be made to call server APIs
    return nil;
}

-(BOASystemAndDeveloperEvents*)serverFormatLifeTimeRetentionEventsFrom:(BOAAppLifetimeData*)lifetimeSessionData{
    @try {
        
        //Return No retention Event in case of firstParty container
        if([BOASDKManifestController sharedInstance].sdkDeploymentMode == BO_DEPLOYMENT_MODE_FIRST_PARTY) {
            return nil;
        }
        
        //prepare UBI Events
        NSMutableArray *events = [NSMutableArray array];
        [events addObjectsFromArray:[self prepareRetentionEventsFromLifeTime:lifetimeSessionData]];
        
        if (!events || (events.count == 0)) {
            return nil;
        }
        
        //add userID mapping
        if([[BOASDKManifestController sharedInstance] sdkMapUserId]) {
            events = [self addUserIdMapping: events];
        }
        
        //put check and test why meta info is nil
        BOAMeta *metaInfo = [self prepareMetaData:nil];
        BOAGeo *geoInfo = [self prepareGeoData:nil];
        
        if (events && (events.count > 0) && metaInfo) {
            BOASystemAndDeveloperEvents *serverEvents = [BOASystemAndDeveloperEvents fromJSONDictionary:@{
                BO_META: NSNullifyCheck(metaInfo),
                BO_PMETA: NSNull.null,
                BO_GEO: NSNullifyCheck(geoInfo),
                BO_EVENTS: events
            }];
            
            //Return data only when there are events else nil
            if (serverEvents.events.count > 0) {
                return serverEvents;
            }
        }
        //When nil is returned then check should be made to call server APIs
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
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

-(BOAMeta*)prepareMetaData:(BOAppSessionData*)sessionData {
    @try {
        NSDictionary *metaInfo = [self prepareMetaDataDict:sessionData];
        return [BOAMeta fromJSONDictionary:metaInfo];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSDictionary*)prepareGeoDataDict:(BOAppSessionData*)sessionData {
    NSDictionary *geoDict = [BOServerDataConverter prepareGeoData];
    NSMutableDictionary *geoDatas = (geoDict != nil && geoDict != (id)[NSNull null]) ? [geoDict mutableCopy] : nil;
    for (NSString *geoKey in geoDatas.allKeys) {
        id geoVal = [geoDatas objectForKey:geoKey];
        if ([geoVal isEqual:NSNull.null] || [geoVal isEqual:NULL]) {
            [geoDatas removeObjectForKey:geoKey];
        }
    }
    if((geoDatas != nil) && (geoDatas != NULL) && (geoDatas.allValues.count > 0)) {
        return geoDatas;
    } else {
        return nil;
    }
    return nil;
}

-(BOAGeo*)prepareGeoData:(BOAppSessionData*)sessionData {
    @try {
        NSDictionary *geoInfo = [self prepareGeoDataDict:nil];
        return (geoInfo != nil && (geoInfo.allValues.count > 0)) ? [BOAGeo fromJSONDictionary:geoInfo] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareDeveloperCodifiedPIIEvents:(BOAppSessionData*)sessionData {
    
    NSMutableArray *eventsArray = [NSMutableArray array];
    
    @try {
        
        BODeveloperCodified *developerCodified = sessionData.singleDaySessions.developerCodified;
        if([developerCodified.piiEvents count] >0) {
            for (BOCustomEvent *customEvent in developerCodified.piiEvents) {
                if (![customEvent.sentToServer boolValue]) {
                    NSNumber *eventSubCode = customEvent.eventSubCode;
                    if (eventSubCode && customEvent.eventName && ![customEvent.eventName isEqualToString:@""]) {
                        
                        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                        [properties setValue:customEvent.eventInfo ? customEvent.eventInfo : NSNull.null forKey:BO_CODIFIED_INFO];
                        [properties setValue:customEvent.session_id forKey:BO_SESSION_ID];
                        
                        BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                            //In case of custom events logic needs update as object will be unique but event name based counter needed
                            BO_EVENTS_TIME:[BOAUtilities roundOffTimeStamp:customEvent.timeStamp],
                            BO_EVENT_CATEGORY_SUBTYPE: eventSubCode,
                            BO_PROPERTIES: properties,
                            BO_MESSAGE_ID: customEvent.mid,
                            BO_SCREEN_NAME: customEvent.visibleClassName ? customEvent.visibleClassName : NSNull.null,
                            BO_EVENT_NAME_MAPPING: customEvent.eventName ? customEvent.eventName : NSNull.null
                        }];
                        [eventsArray addObject:event];
                    }else{
                        //make errro API call to record this error and analyse
                        BOFLogError(@"Dev_Codified_Event: %@", @"Events unique subcode generation error");
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    
    return eventsArray;
}

-(NSMutableArray*)prepareDeveloperCodifiedPHIEvents:(BOAppSessionData*)sessionData {
    
    NSMutableArray *eventsArray = [NSMutableArray array];
    @try {
        
        BODeveloperCodified *developerCodified = sessionData.singleDaySessions.developerCodified;
        if([developerCodified.phiEvents count] >0) {
            for (BOCustomEvent *customEvent in developerCodified.phiEvents) {
                if (![customEvent.sentToServer boolValue]) {
                    NSNumber *eventSubCode = customEvent.eventSubCode;
                    if (eventSubCode && customEvent.eventName && ![customEvent.eventName isEqualToString:@""]) {
                        
                        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                        [properties setValue:customEvent.eventInfo ? customEvent.eventInfo : NSNull.null forKey:BO_CODIFIED_INFO];
                        [properties setValue:customEvent.session_id forKey:BO_SESSION_ID];
                        
                        BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                            //In case of custom events logic needs update as object will be unique but event name based counter needed
                            BO_EVENTS_TIME:[BOAUtilities roundOffTimeStamp:customEvent.timeStamp],
                            BO_EVENT_CATEGORY_SUBTYPE: eventSubCode,
                            BO_PROPERTIES: properties,
                            BO_MESSAGE_ID: customEvent.mid,
                            BO_SCREEN_NAME: customEvent.visibleClassName ? customEvent.visibleClassName : NSNull.null,
                            BO_EVENT_NAME_MAPPING: customEvent.eventName ? customEvent.eventName : NSNull.null
                        }];
                        [eventsArray addObject:event];
                    }else{
                        //make errro API call to record this error and analyse
                        BOFLogError(@"Dev_Codified_Event: %@", @"Events unique subcode generation error");
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    
    return eventsArray;
}

-(NSMutableArray*)prepareDeveloperCodifiedEvents:(BOAppSessionData*)sessionData {
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        BODeveloperCodified *developerCodified = sessionData.singleDaySessions.developerCodified;
        if([developerCodified.addToCart count] > 0) {
            for (BOAddToCart *cart in developerCodified.addToCart) {
                if(![cart.sentToServer boolValue]){
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:cart.additionalInfo ? cart.additionalInfo : NSNull.null forKey:BO_CODIFIED_INFO];
                    [properties setValue:cart.session_id forKey:BO_SESSION_ID];
                    
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_ADD_TO_CART,
                        BO_EVENTS_TIME:[BOAUtilities roundOffTimeStamp:cart.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_DEV_EVENT_ADD_TO_CART_KEY],
                        BO_PROPERTIES: properties,
                        BO_MESSAGE_ID: cart.mid,
                        BO_SCREEN_NAME: cart.cartClassName ? cart.cartClassName : NSNull.null
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if([developerCodified.chargeTransaction count] >0) {
            for (BOChargeTransaction *transaction in developerCodified.chargeTransaction) {
                if (![transaction.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:transaction.transactionInfo ? transaction.transactionInfo : NSNull.null forKey:BO_CODIFIED_INFO];
                    [properties setValue:transaction.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_CHARGE_TRANSACTION,
                        BO_EVENTS_TIME:[BOAUtilities roundOffTimeStamp:transaction.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_DEV_EVENT_CHARGE_TRANSACTION_BUTTON_KEY],
                        BO_PROPERTIES: properties,
                        BO_MESSAGE_ID: transaction.mid,
                        BO_SCREEN_NAME: transaction.transactionClassName ? transaction.transactionClassName : NSNull.null
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if([developerCodified.customEvents count] >0) {
            for (BOCustomEvent *customEvent in developerCodified.customEvents) {
                if (![customEvent.sentToServer boolValue]) {
                    NSNumber *eventSubCode = customEvent.eventSubCode;
                    if (eventSubCode && customEvent.eventName && ![customEvent.eventName isEqualToString:@""]) {
                        
                        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                        [properties setValue:customEvent.eventInfo ? customEvent.eventInfo : NSNull.null forKey:BO_CODIFIED_INFO];
                        [properties setValue:customEvent.session_id forKey:BO_SESSION_ID];
                        
                        BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                            //In case of custom events logic needs update as object will be unique but event name based counter needed
                            BO_EVENTS_TIME:[BOAUtilities roundOffTimeStamp:customEvent.timeStamp],
                            BO_EVENT_CATEGORY_SUBTYPE: eventSubCode,
                            BO_PROPERTIES: properties,
                            BO_MESSAGE_ID: customEvent.mid,
                            BO_SCREEN_NAME: customEvent.visibleClassName ? customEvent.visibleClassName : NSNull.null,
                            BO_EVENT_NAME_MAPPING: customEvent.eventName ? customEvent.eventName : NSNull.null
                        }];
                        [eventsArray addObject:event];
                    }else{
                        //make errro API call to record this error and analyse
                        BOFLogError(@"Dev_Codified_Event: %@", @"Events unique subcode generation error");
                    }
                }
            }
        }
        
        //TODO: incomplete
        if([developerCodified.timedEvent count] >0) {
            for (BOTimedEvent *timedEvent in developerCodified.timedEvent) {
                if(![timedEvent.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:timedEvent.timedEvenInfo ? timedEvent.timedEvenInfo : NSNull.null forKey:BO_CODIFIED_INFO];
                    [properties setValue:timedEvent.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENTS_TIME:[BOAUtilities roundOffTimeStamp:timedEvent.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_DEV_EVENT_TIMED_KEY],
                        BO_PROPERTIES: properties,
                        BO_MESSAGE_ID: timedEvent.mid,
                        BO_SCREEN_NAME: timedEvent.startVisibleClassName ? timedEvent.startVisibleClassName : NSNull.null,
                        BO_EVENT_NAME_MAPPING: timedEvent.eventName ? timedEvent.eventName : NSNull.null
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareAppStateEvents:(BOAppSessionData*)sessionData {
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        BOAppStates *appStates = sessionData.singleDaySessions.appStates;
        if([appStates.appLaunched count] > 0) {
            for (BOApp *appInfo in appStates.appLaunched) {
                if(![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_APP_LAUNCHED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_SESSION_START_KEY],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_SCREEN_NAME: appInfo.visibleClassName ? appInfo.visibleClassName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(appStates.appResignActive != nil && [appStates.appResignActive count] > 0) {
            for (BOApp *appInfo in appStates.appResignActive) {
                if(![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_RESIGN_ACTIVE,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_SESSION_END_KEY],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_SCREEN_NAME: appInfo.visibleClassName ? appInfo.visibleClassName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if([appStates.appInBackground count] > 0) {
            for (BOApp *appInfo in appStates.appInBackground) {
                if(![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_APP_IN_BACKGROUND,
                        BO_EVENTS_TIME:[BOAUtilities roundOffTimeStamp:appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_BACKGROUND_KEY],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_SCREEN_NAME: appInfo.visibleClassName ? appInfo.visibleClassName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        
        if([appStates.appInForeground count] > 0) {
            for (BOApp *appInfo in appStates.appInForeground) {
                if(![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_APP_IN_FOREGROUND,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_FOREGROUND_KEY],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_SCREEN_NAME: appInfo.visibleClassName ? appInfo.visibleClassName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        if([appStates.appOrientationPortrait count] > 0) {
            for (BOApp *appInfo in appStates.appOrientationPortrait) {
                if(![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_APP_ORIENTATION_PORTRAIT,
                        BO_EVENTS_TIME:[BOAUtilities roundOffTimeStamp:appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_PORTRAIT_ORIENTATION_KEY],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_SCREEN_NAME: appInfo.visibleClassName ? appInfo.visibleClassName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        if([appStates.appOrientationLandscape count] > 0) {
            for (BOApp *appInfo in appStates.appOrientationLandscape) {
                if(![appInfo.sentToServer boolValue]) {
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_APP_ORIENTATION_LANDSCAPE,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_LANDSCAPE_ORIENTATION_KEY],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_SCREEN_NAME: appInfo.visibleClassName ? appInfo.visibleClassName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if([appStates.appNotificationReceived count] > 0) {
            for (BOApp *appInfo in appStates.appNotificationReceived) {
                if(![appInfo.sentToServer boolValue]) {
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_APP_NOTIFICATION_RECEIVED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_NOTIFICATION_RECEIVED_KEY],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_SCREEN_NAME: appInfo.visibleClassName ? appInfo.visibleClassName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        if([appStates.appNotificationViewed count] > 0) {
            for (BOApp *appInfo in appStates.appNotificationViewed) {
                if(![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_APP_NOTIFICATION_VIEWED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_NOTIFICATION_VIEWED_KEY],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_SCREEN_NAME: appInfo.visibleClassName ? appInfo.visibleClassName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if([appStates.appNotificationClicked count] > 0) {
            for (BOApp *appInfo in appStates.appNotificationClicked) {
                if(![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_APP_NOTIFICATION_CLICKED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_NOTIFICATION_CLICKED_KEY],
                        BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:BO_APP_NOTIFICATION_CLICKED],
                        BO_SCREEN_NAME: appInfo.visibleClassName ? appInfo.visibleClassName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if([appStates.appSessionInfo count] > 0) {
            for (BOSessionInfo *sessionInfo in appStates.appSessionInfo) {
                if(![sessionInfo.sentToServer boolValue] && sessionInfo.start > 0 && sessionInfo.end > 0) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:sessionInfo.session_id forKey:BO_SESSION_ID];
                    [properties setValue:@{@"start":sessionInfo.start,@"end":sessionInfo.end,@"duration":sessionInfo.duration} forKey:BO_CODIFIED_INFO];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_APP_SESSION_INFO,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:sessionInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_SESSION_INFO],
                        BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:BO_APP_SESSION_INFO],
                        BO_PROPERTIES:properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareRetentionEvents:(BOAppSessionData*)sessionData {
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        BORetentionEvent *retentionEvent = sessionData.singleDaySessions.retentionEvent;
        if(retentionEvent.dau != nil && ![retentionEvent.dau.sentToServer boolValue]) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.dau.dauInfo ? retentionEvent.dau.dauInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_DAU,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.dau.timeStamp] ,
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_DAU_KEY],
                BO_MESSAGE_ID: retentionEvent.dau.mid,
                BO_PROPERTIES: properties
            }];
            [eventsArray addObject:event];
        }
        
        if(retentionEvent.dpu != nil && ![retentionEvent.dpu.sentToServer boolValue]) {
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.dpu.dpuInfo ? retentionEvent.dpu.dpuInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_DPU,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.dpu.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_DPU_KEY],
                BO_MESSAGE_ID: retentionEvent.dpu.mid,
                BO_PROPERTIES: properties
            }];
            [eventsArray addObject:event];
        }
        
        if(retentionEvent.appInstalled != nil && ![retentionEvent.appInstalled.sentToServer boolValue]) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.appInstalled.appInstalledInfo ? retentionEvent.appInstalled.appInstalledInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_APP_INSTALLED,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.appInstalled.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_APP_INSTALL_KEY],
                BO_MESSAGE_ID: retentionEvent.appInstalled.mid,
                BO_IS_FIRST_LAUNCH: retentionEvent.appInstalled.isFirstLaunch,
                BO_PROPERTIES: properties
                
            }];
            [eventsArray addObject:event];
        }
        
        if(retentionEvent.theNewUser != nil && ![retentionEvent.theNewUser.sentToServer boolValue]) {
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.theNewUser.theNewUserInfo ? retentionEvent.theNewUser.theNewUserInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_NUO,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.theNewUser.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_NUO_KEY],
                BO_MESSAGE_ID: retentionEvent.theNewUser.mid,
                BO_PROPERTIES: properties
                
            }];
            [eventsArray addObject:event];
        }
        
        if(retentionEvent.dast != nil && ![retentionEvent.dast.sentToServer boolValue]) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.dast.payload ? retentionEvent.dast.payload : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_DAST,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.dast.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_DAST_KEY],
                BO_MESSAGE_ID: retentionEvent.dast.mid,
                BO_TST: retentionEvent.dast.averageSessionTime,
                BO_PROPERTIES: properties
                
            }];
            [eventsArray addObject:event];
        }
        
        if([retentionEvent.customEvents count] >0) {
            for (BOCustomEvent *customEvent in retentionEvent.customEvents) {
                if (![customEvent.sentToServer boolValue]) {
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:retentionEvent.session_id forKey:BO_SESSION_ID];
                    [properties setValue:customEvent.eventInfo ? customEvent.eventInfo : NSNull.null forKey:BO_CODIFIED_INFO];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:customEvent.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_CUS_KEY1],
                        BO_MESSAGE_ID: customEvent.mid,
                        BO_SCREEN_NAME: customEvent.visibleClassName ? customEvent.visibleClassName : NSNull.null,
                        BO_EVENT_NAME_MAPPING: customEvent.eventName ? customEvent.eventName : NSNull.null,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareCrashEvents:(BOAppSessionData*)sessionData{
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        
        NSMutableArray <BOCrashDetail *> *crashEvents = [NSMutableArray arrayWithArray:sessionData.singleDaySessions.crashDetails];
        if([crashEvents count] >0) {
            for (BOCrashDetail *crashEvent in crashEvents) {
                if (![crashEvent.sentToServer boolValue]) {
                    NSDictionary *crashEventProperties = @{
                        
                        @"info": crashEvent.info ? [NSString stringWithFormat:@"%@",crashEvent.info] : NSNull.null,
                        @"callStackSymbols": crashEvent.callStackSymbols ? [NSString stringWithFormat:@"%@",crashEvent.callStackSymbols] : NSNull.null,
                        @"callStackAddress": crashEvent.callStackReturnAddress ? [NSString stringWithFormat:@"%@",crashEvent.callStackReturnAddress] : NSNull.null,
                    };
                    //This will send the count properly but for same event, multiple time event will be sent
                    //Find fix, considering buy passing send and set sentToServer to true
                    int objCount = 0;
                    for(BOCrashDetail *crashEventToRemove in crashEvents){
                        if ([crashEventToRemove.name isEqualToString:crashEvent.name]) {
                            objCount = objCount + 1;
                            //[crashEvents removeObject:crashEventToRemove];
                        }
                    }
                    //Check here, crashEvent should not be null or nil
                    BOFLogDebug(@"CrashEvent Info %@",crashEvent);
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:crashEvent.session_id forKey:BO_SESSION_ID];
                    [properties setValue:NSNullifyCheck(crashEventProperties) forKey:BO_CODIFIED_INFO];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        //[NSNumber numberWithInt:(int)[crashEvents indexOfObject:crashEvent]],
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:crashEvent.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_EVENT_APP_RUN_TIME_EXCEPTION],
                        BO_PROPERTIES: properties,
                        BO_MESSAGE_ID: crashEvent.mid,//[NSString stringWithFormat:@"%d-%ld-%@",BO_EVENT_EXCEPTION_KEY, (long)[BOAUtilities get13DigitIntegerTimeStamp],crashEvent.timeStamp],
                        BO_SCREEN_NAME: crashEvent.callStackSymbols ? [NSString stringWithFormat:@"%@",[crashEvent.callStackSymbols lastObject]] : NSNull.null,
                        BO_EVENT_NAME_MAPPING: crashEvent.name ? crashEvent.name : NSNull.null,
                        @"value": crashEvent.reason ? crashEvent.reason : NSNull.null,
                        //To prepare proper all uustate values, check for weekly and monthly files falling under same week and same month when this crash occured based on crashEvent.timeStamp
                        @"uustate": @[@101]//@[@101, @201, @301, @401]
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareCommonEvents:(BOAppSessionData*)sessionData{
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        
        NSArray <BOCommonEvent *> *commonEvents = sessionData.singleDaySessions.commonEvents;
        if([commonEvents count] >0) {
            for (BOCommonEvent *commonEvent in commonEvents) {
                if (![commonEvent.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:commonEvent.session_id forKey:BO_SESSION_ID];
                    [properties setValue:NSNullifyCheck(commonEvent.eventInfo) forKey:BO_CODIFIED_INFO];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:commonEvent.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: commonEvent.eventSubCode,
                        BO_PROPERTIES: properties,
                        BO_MESSAGE_ID: commonEvent.mid,
                        BO_EVENT_NAME_MAPPING: commonEvent.eventName ? commonEvent.eventName : NSNull.null
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareDeviceEvents:(BOAppSessionData*)sessionData{
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        
        BODeviceInfo *deviceInfo = sessionData.singleDaySessions.deviceInfo;
        if(deviceInfo.batteryLevel != NULL && deviceInfo.batteryLevel.count > 0) {
            for (BOBatteryLevel *appInfo in deviceInfo.batteryLevel) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_BATTERY_LEVEL,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.percentage != nil ? [NSString stringWithFormat:@"%d",[appInfo.percentage intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.multitaskingEnabled != NULL && deviceInfo.multitaskingEnabled.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.multitaskingEnabled) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_MULTITASKING_ENABLED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.status != nil ? [NSString stringWithFormat:@"%d",[appInfo.status intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.proximitySensorEnabled != NULL && deviceInfo.proximitySensorEnabled.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.proximitySensorEnabled) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_PROXIMITY_SENSOR_ENABLED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.status != nil ? [NSString stringWithFormat:@"%d",[appInfo.status intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.debuggerAttached != NULL && deviceInfo.debuggerAttached.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.debuggerAttached) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_DEBUGGER_ATTACHED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.status != nil ? [NSString stringWithFormat:@"%d",[appInfo.status intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.pluggedIn != NULL && deviceInfo.pluggedIn.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.pluggedIn) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_PLUGGEDIN,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.status != nil ? [NSString stringWithFormat:@"%d",[appInfo.status intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.jailBroken != NULL && deviceInfo.jailBroken.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.jailBroken) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_JAIL_BROKEN,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.status != nil ? [NSString stringWithFormat:@"%d",[appInfo.status intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.numberOfActiveProcessors != NULL && deviceInfo.numberOfActiveProcessors.count > 0) {
            for (BONumberOfA *appInfo in deviceInfo.numberOfActiveProcessors) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_NUMBER_OF_ACTIVE_PROCESSORS,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.number != nil ? [NSString stringWithFormat:@"%d",[appInfo.number intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.processorsUsage != NULL && deviceInfo.processorsUsage.count > 0) {
            for (BOProcessorsUsage *appInfo in deviceInfo.processorsUsage) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_NUMBER_OF_ACTIVE_PROCESSORS,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.usagePercentage != nil ? [NSString stringWithFormat:@"%d",[appInfo.usagePercentage intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.accessoriesAttached != NULL && deviceInfo.accessoriesAttached.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.debuggerAttached) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_ACCESSORIES_ATTACHED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.status != nil ? [NSString stringWithFormat:@"%d",[appInfo.status intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.headphoneAttached != NULL && deviceInfo.headphoneAttached.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.headphoneAttached) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_HEADPHONE_ATTACHED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.status != nil ? [NSString stringWithFormat:@"%d",[appInfo.status intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.numberOfAttachedAccessories != NULL && deviceInfo.numberOfAttachedAccessories.count > 0) {
            for (BONumberOfA *appInfo in deviceInfo.numberOfAttachedAccessories) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_NUMBER_OF_ATTACHED_ACCESSORIES,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.number != nil ? [NSString stringWithFormat:@"%d",[appInfo.number intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.nameOfAttachedAccessories != NULL && deviceInfo.nameOfAttachedAccessories.count > 0) {
            for (BONameOfAttachedAccessory *appInfo in deviceInfo.nameOfAttachedAccessories) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_NAME_OF_ATTACHED_ACCESSORIES,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: NSNullifyCheck(appInfo.names),
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.isCharging != NULL && deviceInfo.isCharging.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.isCharging) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_IS_CHARGING,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.status != nil ? [NSString stringWithFormat:@"%d",[appInfo.status intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(deviceInfo.fullyCharged != NULL && deviceInfo.fullyCharged.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.fullyCharged) {
                if (![appInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:appInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_FULLY_CHARGED,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: appInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: appInfo.mid,
                        BO_VALUE: appInfo.status != nil ? [NSString stringWithFormat:@"%d",[appInfo.status intValue]] : [NSNull null],
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareMemoryEvents:(BOAppSessionData*)sessionData{
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        
        if(sessionData.singleDaySessions.memoryInfo != NULL && sessionData.singleDaySessions.memoryInfo.count > 0) {
            for (BOMemoryInfo *memoryInfo in sessionData.singleDaySessions.memoryInfo) {
                if (![memoryInfo.sentToServer boolValue]) {
                    NSDictionary *properties = @{
                        BO_EVENT_ACTIVE_MEMORY: NSNullifyCheck(memoryInfo.activeMemory),
                        BO_EVENT_AT_MEMORY_WARNING: NSNullifyCheck(memoryInfo.atMemoryWarning),
                        BO_EVENT_FREE_MEMORY: NSNullifyCheck(memoryInfo.freeMemory),
                        BO_EVENT_INACTIVE_MEMORY: NSNullifyCheck(memoryInfo.inActiveMemory),
                        BO_EVENT_PURGEABLE_MEMORY: NSNullifyCheck(memoryInfo.purgeableMemory),
                        BO_EVENT_TOTAL_RAM: NSNullifyCheck(memoryInfo.totalRAM),
                        BO_EVENT_USED_MEMORY: NSNullifyCheck(memoryInfo.usedMemory),
                        BO_EVENT_WIRED_MEMORY: NSNullifyCheck(memoryInfo.wiredMemory)
                    };
                    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
                    [eventInfo setValue:memoryInfo.session_id forKey:BO_SESSION_ID];
                    [eventInfo setValue:NSNullifyCheck(properties) forKey:BO_CODIFIED_INFO];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_MEMORY_INFO,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: memoryInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: memoryInfo.mid,
                        BO_PROPERTIES: NSNullifyCheck(eventInfo)
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(sessionData.singleDaySessions.storageInfo != NULL && sessionData.singleDaySessions.storageInfo.count > 0) {
            for (BOStorageInfo *storageInfo in sessionData.singleDaySessions.storageInfo) {
                if (![storageInfo.sentToServer boolValue]) {
                    NSDictionary *properties = @{
                        BO_EVENT_UNIT: storageInfo.unit,
                        BO_EVENT_TOTAL_DISK_SPACE: storageInfo.totalDiskSpace,
                        BO_EVENT_FREE_DISK_SPACE: storageInfo.freeDiskSpace,
                        BO_EVENT_USED_DISK_SPACE: storageInfo.usedDiskSpace
                    };
                    
                    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
                    [eventInfo setValue:storageInfo.session_id forKey:BO_SESSION_ID];
                    [eventInfo setValue:NSNullifyCheck(properties) forKey:BO_CODIFIED_INFO];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_STORAGE_INFO,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: storageInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: storageInfo.mid,
                        BO_PROPERTIES: NSNullifyCheck(eventInfo)
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)preparePIIEvents:(BOAppSessionData*)sessionData{
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        BONetworkInfo *networkInfoArray = sessionData.singleDaySessions.networkInfo;
        if(networkInfoArray.currentIPAddress != NULL && networkInfoArray.currentIPAddress.count > 0) {
            for (BOIPAddress *networkInfo in networkInfoArray.currentIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_CURRENT_IP_ADDRESS,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.ipAddress,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.cellBroadcastAddress != NULL && networkInfoArray.cellBroadcastAddress.count > 0) {
            for (BOBroadcastAddress *networkInfo in networkInfoArray.cellBroadcastAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_CELL_BROADCAST_ADDRESS,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.broadcastAddress,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.cellIPAddress != NULL && networkInfoArray.cellIPAddress.count > 0) {
            for (BOIPAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_CELL_IP_ADDRESS,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.ipAddress,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.cellNetMask != NULL && networkInfoArray.cellNetMask.count > 0) {
            for (BONetMask *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_CELL_NETMASK,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.netmask,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.connectedToCellNetwork != NULL && networkInfoArray.connectedToCellNetwork.count > 0) {
            for (BOConnectedTo *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_CONNECTED_TO_CELL_NETWORK,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.isConnected,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.connectedToWifi != NULL && networkInfoArray.connectedToWifi.count > 0) {
            for (BOConnectedTo *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_CONNECTED_WIFI,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.isConnected,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.externalIPAddress != NULL && networkInfoArray.externalIPAddress.count > 0) {
            for (BOIPAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_EXTERNAL_IP_ADDRESS,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.ipAddress,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.wifiBroadcastAddress != NULL && networkInfoArray.wifiBroadcastAddress.count > 0) {
            for (BOBroadcastAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_WIFI_BROADCAST_ADDRESS,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.broadcastAddress,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.wifiIPAddress != NULL && networkInfoArray.wifiIPAddress.count > 0) {
            for (BOIPAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_WIFI_IP_ADDRESS,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.ipAddress,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.wifiRouterAddress != NULL && networkInfoArray.wifiRouterAddress.count > 0) {
            for (BOWifiRouterAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_WIFI_ROUTER_ADDRESS,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.routerAddress,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.wifiSSID != NULL && networkInfoArray.wifiSSID.count > 0) {
            for (BOWifiSSID *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_WIFI_SSID,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.ssid,
                        BO_PROPERTIES: properties
                    }];
                    
                    [eventsArray addObject:event];
                }
            }
        }
        
        if(networkInfoArray.wifiNetMask != NULL && networkInfoArray.wifiNetMask.count > 0) {
            for (BONetMask *networkInfo in networkInfoArray.cellIPAddress) {
                if (![networkInfo.sentToServer boolValue]) {
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:networkInfo.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_WIFI_NET_MASK,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: networkInfo.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DEVICE_INFO],
                        BO_MESSAGE_ID: networkInfo.mid,
                        BO_VALUE: networkInfo.netmask,
                        BO_PROPERTIES: properties
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        
        
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareNavigationEvents:(BOAppSessionData*)sessionData{
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        BOUbiAutoDetected *autoDetected = sessionData.singleDaySessions.ubiAutoDetected;
        
        NSMutableArray *screenName = [NSMutableArray array];
        NSMutableArray *screenTime = [NSMutableArray array];
        
        if(autoDetected.appNavigation != NULL && autoDetected.appNavigation.count > 0) {
            for (BOAppNavigation *appNavigation in autoDetected.appNavigation) {
                [screenName addObject:NSNullifyCheck(appNavigation.to)];
                [screenTime addObject:NSNullifyCheck(appNavigation.timeSpent)];
            }
        }
        if ([screenName count] > 0 && [screenTime count] > 0) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:[BOSharedManager sharedInstance].sessionId forKey:BO_SESSION_ID];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_APP_NAVIGATION,
                BO_EVENTS_TIME: [BOAUtilities get13DigitNumberObjTimeStamp],
                BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_NAVIGATION],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_APP_NAVIGATION],
                BO_NAVIGATION_SCREEN: screenName,
                BO_NAVIGATION_TIME: screenTime,
                BO_PROPERTIES: properties
            }];
            
            [eventsArray addObject:event];
        }
        
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareAdInfo:(BOAppSessionData*)sessionData{
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        
        if(sessionData.singleDaySessions.adInfo != NULL && sessionData.singleDaySessions.adInfo > 0) {
            for (BOAdInfo *adInformation in sessionData.singleDaySessions.adInfo) {
                if(![adInformation.sentToServer boolValue]){
                    NSDictionary *property = @{
                        BO_AD_IDENTIFIER: NSNullifyCheck(adInformation.advertisingId),
                        BO_AD_DO_NOT_TRACK: NSNullifyCheck(adInformation.isAdDoNotTrack)
                    };
                    
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    [properties setValue:NSNullifyCheck(property) forKey:BO_CODIFIED_INFO];
                    [properties setValue:adInformation.session_id forKey:BO_SESSION_ID];
                    
                    BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                        BO_EVENT_NAME_MAPPING: BO_EVENT_AD_INFO,
                        BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp: adInformation.timeStamp],
                        BO_EVENT_CATEGORY_SUBTYPE: [NSNumber numberWithInt: BO_EVENT_APP_DO_NOT_TRACK],
                        BO_MESSAGE_ID: adInformation.mid,
                        BO_PROPERTIES: NSNullifyCheck(properties)
                    }];
                    [eventsArray addObject:event];
                }
            }
        }
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}


-(NSMutableArray*)addUserIdMapping:(NSMutableArray*)events{
    @try {
        NSMutableArray *userIdMappedEvents = [NSMutableArray array];
        NSString *userId = [BOAUtilities getDeviceId];
        if (userId != nil && [userId length] > 0) {
            for(NSDictionary *event in events) {
                [event setValue:userId forKey: @"userid"];
                [userIdMappedEvents addObject:event];
            }
            return userIdMappedEvents;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)addSessionIdMapping:(NSMutableArray*)events{
    @try {
        NSMutableArray *sessionIdMappedEvents = [NSMutableArray array];
        NSString *sessionId = [BOSharedManager sharedInstance].sessionId;
        if (sessionId != nil && [sessionId length] > 0) {
            for(NSDictionary *event in events) {
                [event setValue:sessionId forKey: BO_SESSION_ID];
                [sessionIdMappedEvents addObject:event];
            }
            return sessionIdMappedEvents;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(BOASystemAndDeveloperEvents*)createEventObject:(NSString*)eventName withEventCategory:(NSNumber*)eventCategory withEventSubcode:(NSNumber*)eventSubcode {
    @try {
        NSMutableArray *events = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        [properties setValue:[BOSharedManager sharedInstance].sessionId forKey:BO_SESSION_ID];
        
        BOAEvent *event = [BOAEvent fromJSONDictionary:@{
            BO_EVENT_NAME_MAPPING: eventName,
            BO_EVENTS_TIME: [BOAUtilities get13DigitNumberObjTimeStamp],
            BO_EVENT_CATEGORY_SUBTYPE:eventSubcode,
            BO_PROPERTIES: properties,
            BO_MESSAGE_ID:[BOAUtilities getMessageIDForEvent:eventName],
            BO_USER_ID: [BOAUtilities getDeviceId]
        }];
        
        [events addObject:event];
        
        BOAMeta *metaInfo = [self prepareMetaData:nil];
        BOAGeo *geoInfo = [self prepareGeoData:nil];
        
        BOASystemAndDeveloperEvents *serverEvents = [BOASystemAndDeveloperEvents fromJSONDictionary:@{
            BO_META: NSNullifyCheck(metaInfo),
            BO_PMETA: NSNull.null,
            BO_GEO: NSNullifyCheck(geoInfo),
            BO_EVENTS: events
        }];
        return serverEvents;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSMutableArray*)prepareRetentionEventsFromLifeTime:(BOAAppLifetimeData*)lifeTimeSessionData {
    @try {
        NSMutableArray *eventsArray = [NSMutableArray array];
        //NSInteger lastSyncTime = [lifeTimeSessionData.lastServerSyncTimeStamp integerValue];
        // NSInteger currentTimeStamp = [BOAUtilities get13DigitIntegerTimeStamp];
        
        //Build logic to sync based on all data after lastSync or Current Session Data being synced
        BOARetentionEvent *retentionEvent = [lifeTimeSessionData.appLifeTimeInfo lastObject].retentionEvent;
        
        //Enable below block, in case life time JSON also store DAU, as per current scenario it is not and will not
        /*
         if(retentionEvent.dau != nil && ([retentionEvent.dau.timeStamp integerValue] > lastSyncTime) && ![retentionEvent.dau.sentToServer boolValue]) {
         BOAEvent *event = [BOAEvent fromJSONDictionary:@{
         BO_EVENT_NAME_MAPPING:@"DAU",
         BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.dau.timeStamp],
         BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_DAU_KEY],
         BO_PROPERTIES: retentionEvent.dau.dauInfo ? retentionEvent.dau.dauInfo : NSNull.null,
         BO_MESSAGE_ID: retentionEvent.dau.mid //[NSString stringWithFormat:@"%d-%ld-%@",BO_RETEN_DAU_KEY, (long)[BOAUtilities get13DigitIntegerTimeStamp],retentionEvent.dau.timeStamp]
         }];
         [eventsArray addObject:event];
         }
         */
        
        if(retentionEvent.wau != nil && ![retentionEvent.wau.sentToServer boolValue]) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.wau.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.wau.wauInfo ? retentionEvent.wau.wauInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_WAU,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.wau.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_WAU_KEY],
                BO_MESSAGE_ID: retentionEvent.wau.mid,
                BO_PROPERTIES: properties
            }];
            [eventsArray addObject:event];
        }
        
        if(retentionEvent.mau != nil && ![retentionEvent.mau.sentToServer boolValue]) {
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.mau.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.mau.mauInfo ? retentionEvent.mau.mauInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_MAU,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.mau.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_MAU_KEY],
                BO_PROPERTIES: retentionEvent.mau.mauInfo ? retentionEvent.mau.mauInfo : NSNull.null,
                BO_MESSAGE_ID: retentionEvent.mau.mid,
                BO_PROPERTIES: properties
            }];
            [eventsArray addObject:event];
        }
        if(self.isPayingUser){
            
            if(retentionEvent.wpu != nil && ![retentionEvent.wpu.sentToServer boolValue]) {
                NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                [properties setValue:retentionEvent.wpu.session_id forKey:BO_SESSION_ID];
                [properties setValue:retentionEvent.wpu.wpuInfo ? retentionEvent.wpu.wpuInfo : NSNull.null forKey:BO_CODIFIED_INFO];
                
                BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                    BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_WPU,
                    BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.wpu.timeStamp],
                    BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_WPU_KEY],
                    BO_MESSAGE_ID: retentionEvent.wpu.mid,
                    BO_PROPERTIES: properties
                }];
                [eventsArray addObject:event];
            }
            
            if(retentionEvent.mpu != nil && ![retentionEvent.mpu.sentToServer boolValue]) {
                
                NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                [properties setValue:retentionEvent.mpu.session_id forKey:BO_SESSION_ID];
                [properties setValue:retentionEvent.mpu.mpuInfo ? retentionEvent.mpu.mpuInfo : NSNull.null forKey:BO_CODIFIED_INFO];
                
                BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                    BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_MPU,
                    BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.mpu.timeStamp],
                    BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_MPU_KEY],
                    BO_MESSAGE_ID: retentionEvent.mpu.mid,
                    BO_PROPERTIES: properties
                }];
                [eventsArray addObject:event];
            }
        }
        
        if(retentionEvent.appInstalled != nil && ![retentionEvent.appInstalled.sentToServer boolValue]) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.appInstalled.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.appInstalled.appInstalledInfo ? retentionEvent.appInstalled.appInstalledInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_APP_INSTALLED,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.appInstalled.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_APP_INSTALL_KEY],
                BO_PROPERTIES: properties,
                BO_MESSAGE_ID: retentionEvent.appInstalled.mid,
                BO_IS_FIRST_LAUNCH: retentionEvent.appInstalled.isFirstLaunch
            }];
            [eventsArray addObject:event];
        }
        
        if(retentionEvent.theNewUser != nil && ![retentionEvent.theNewUser.sentToServer boolValue]) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.theNewUser.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.theNewUser.theNewUserInfo ? retentionEvent.theNewUser.theNewUserInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_NUO,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.theNewUser.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_NUO_KEY],
                BO_MESSAGE_ID: retentionEvent.theNewUser.mid,
                BO_IS_NEW_USER: retentionEvent.theNewUser.isNewUser,
                BO_PROPERTIES: properties
            }];
            [eventsArray addObject:event];
        }
        
        if(retentionEvent.dast != nil && ![retentionEvent.dast.sentToServer boolValue]) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.dast.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.dast.dastInfo ? retentionEvent.dast.dastInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_DAST,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.dast.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_DAST_KEY],
                BO_PROPERTIES: properties,
                BO_MESSAGE_ID: retentionEvent.dast.mid,
                BO_TST: retentionEvent.dast.averageSessionTime
            }];
            [eventsArray addObject:event];
        }
        
        if(retentionEvent.wast != nil && ![retentionEvent.wast.sentToServer boolValue]) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.wast.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.wast.wastInfo ? retentionEvent.wast.wastInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_WAST,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.wast.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_WAST_KEY],
                BO_PROPERTIES: properties,
                BO_MESSAGE_ID: retentionEvent.wast.mid,
                BO_TST: retentionEvent.wast.averageSessionTime
            }];
            [eventsArray addObject:event];
        }
        
        if(retentionEvent.mast != nil && ![retentionEvent.mast.sentToServer boolValue]) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:retentionEvent.mast.session_id forKey:BO_SESSION_ID];
            [properties setValue:retentionEvent.mast.mastInfo ? retentionEvent.mast.mastInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENT_NAME_MAPPING: BO_RETEN_EVENT_NAME_MAST,
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:retentionEvent.mast.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_MAST_KEY],
                BO_PROPERTIES: properties,
                BO_MESSAGE_ID: retentionEvent.mast.mid,
                BO_TST: retentionEvent.mast.averageSessionTime
            }];
            [eventsArray addObject:event];
        }
        
        if ((retentionEvent.customEvents != nil) && ![retentionEvent.customEvents.sentToServer boolValue]) {
            
            BOACustomEvents *customEvent = retentionEvent.customEvents;
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue:customEvent.session_id forKey:BO_SESSION_ID];
            [properties setValue:customEvent.eventInfo ? customEvent.eventInfo : NSNull.null forKey:BO_CODIFIED_INFO];
            
            BOAEvent *event = [BOAEvent fromJSONDictionary:@{
                BO_EVENTS_TIME: [BOAUtilities roundOffTimeStamp:customEvent.timeStamp],
                BO_EVENT_CATEGORY_SUBTYPE:[NSNumber numberWithInt:BO_RETEN_CUS_KEY1],
                BO_PROPERTIES: properties,
                BO_MESSAGE_ID: customEvent.mid,
                BO_SCREEN_NAME: customEvent.visibleClassName ? customEvent.visibleClassName : NSNull.null,
                BO_EVENT_NAME_MAPPING: customEvent.eventName ? customEvent.eventName : NSNull.null
            }];
            [eventsArray addObject:event];
        }
        
        return eventsArray;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSString*)serverFormatEventsJSONFromSessionJSON:(NSString*)sessionJSON{
    return nil;
}

-(NSString*)serverFormatEventsJSONFromSessionDict:(NSDictionary*)eventDict{
    return nil;
}

-(NSString*)serverFormatEventsJSONFromSessionData:(NSData*)sessionData{
    return nil;
}

@end
