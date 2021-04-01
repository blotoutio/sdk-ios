//
//  BOADeveloperEvents.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOADeveloperEvents.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAUtilities.h"
#import "BOANetworkConstants.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOServerDataConverter.h"
#import "BOSharedManager.h"
#import <BlotoutFoundation/BOCrypt.h>
#import "BOEncryptionManager.h"
#import "BOASDKManifestController.h"

@implementation BOADeveloperEvents

+(NSDictionary*)captureEvent:(BOACaptureModel*)payload{
    @try {
        return [BOADeveloperEvents createEventObject:payload.event withType:payload.type withScreenName:payload.screenName withEventSubcode:payload.eventSubCode withEventInfo:payload.properties];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(NSDictionary*)capturePersonalEvent:(BOACaptureModel*)payload isPHI:(BOOL)phiEvent {
    @try {
        return [BOADeveloperEvents preparePersonalEvent:payload.event withScreenName:payload.screenName withEventSubcode:@(0) withEventInfo:payload.properties isPHI:phiEvent];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+(NSDictionary*)prepareServerPayload:(NSArray*)events {
    @try {
        NSMutableArray *eventData = [NSMutableArray array];
        NSDictionary *metaInfo = [BOServerDataConverter prepareMetaData];
        
        for (NSDictionary *event  in events) {
            [eventData addObject:[event valueForKey:BO_EVENTS]];
        }
        
        return @{BO_META:metaInfo,BO_EVENTS:eventData};
    } @catch(NSException *exception) {
        BOFLogDebug(@"%@", exception);
    }
}

+(NSDictionary*)createEventObject:(NSString*)eventName withType:(NSString*)type withScreenName:(NSString*)screenName withEventSubcode:(NSNumber*)eventSubcode withEventInfo:(NSDictionary*)eventInfo{
    @try {
        
        if(eventSubcode == nil || [eventSubcode integerValue] == 0) {
            eventSubcode = [BOAUtilities codeForCustomCodifiedEvent:eventName];
        }
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        [properties addEntriesFromDictionary:eventInfo];
        NSString *screenName = (screenName != nil && screenName.length >0) ? screenName : [BOSharedManager sharedInstance].currentScreenName;
        NSMutableDictionary *event = [NSMutableDictionary dictionary];
        [event setValue:eventName forKey:BO_EVENT_NAME_MAPPING];
        [event setValue: [BOAUtilities get13DigitNumberObjTimeStamp] forKey:BO_EVENTS_TIME];
        [event setValue:eventSubcode forKey:BO_EVENT_CATEGORY_SUBTYPE];
        [event setValue:[BOAUtilities getMessageIDForEvent:eventName] forKey:BO_MESSAGE_ID];
        [event setValue:[BOAUtilities getDeviceId] forKey:BO_USER_ID];
        [event setValue:screenName forKey:BO_SCREEN_NAME];
        [event setValue:[BOADeveloperEvents getScreenPayload] forKey:BO_SCREEN];
        [event setValue:type forKey:BO_TYPE];
        [event setValue:[BOSharedManager sharedInstance].sessionId forKey:BO_SESSION_ID];
        
        
        [event setValue:properties forKey:@"additionalData"];
            
        return @{BO_EVENTS:event};
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDictionary*)getEncryptedEvent:(NSString*)publicKey withSecretKey:(NSString*)secretKey withDictionary:(NSDictionary*)event isPHI:(BOOL)phiEvent {
    
    @try {
        NSString *personalEncryptedData = nil;
        NSString *personalEncryptedSecretKey = nil;
        if(event != nil ) {
            NSData * dataToEncryptPII = [NSJSONSerialization dataWithJSONObject:event options:NSJSONWritingFragmentsAllowed error:nil ];
            
            personalEncryptedData = [BOCrypt encryptDataWithoutHash:dataToEncryptPII key:secretKey iv:BO_CRYPTO_IVX];
            
            personalEncryptedSecretKey = [BOEncryptionManager encryptString:secretKey publicKey:publicKey];
            
            NSMutableDictionary *personalPayload = [NSMutableDictionary dictionary];
            [personalPayload setObject:personalEncryptedSecretKey forKey:BO_KEY];
            [personalPayload setObject:BO_CRYPTO_IVX forKey:BO_IV];
            [personalPayload setObject:personalEncryptedData forKey:BO_DATA];
            
            if(personalEncryptedSecretKey != nil && personalEncryptedSecretKey.length > 0 && personalEncryptedData != nil && personalEncryptedData.length > 0) {
                return personalPayload;
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

+(NSDictionary*)preparePersonalEvent:(NSString*)eventName withScreenName:(NSString*)screenName withEventSubcode:(NSNumber*)eventSubcode withEventInfo:(NSDictionary*)eventInfo isPHI:(BOOL)phiEvent{

    @try {

        if(eventSubcode == nil) {
            eventSubcode = [BOAUtilities codeForCustomCodifiedEvent:eventName];
        }
        
        NSString *secretKey = [BOAUtilities getUUIDString];
        secretKey = [secretKey stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSDictionary *encryptedData = nil;
        
        if(phiEvent) {
            encryptedData = [self getEncryptedEvent:[BOASDKManifestController sharedInstance].phiPublickey withSecretKey:secretKey withDictionary:eventInfo isPHI:phiEvent];
            return [BOADeveloperEvents createEventObject:eventName withType:BO_PHI withScreenName:screenName withEventSubcode:eventSubcode withEventInfo:encryptedData];
        } else {
            encryptedData = [self getEncryptedEvent:[BOASDKManifestController sharedInstance].piiPublicKey withSecretKey:secretKey withDictionary:eventInfo isPHI:phiEvent];
            return [BOADeveloperEvents createEventObject:eventName withType:BO_PII withScreenName:screenName withEventSubcode:eventSubcode withEventInfo:encryptedData];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDictionary*)getScreenPayload {
    NSMutableDictionary *screenInfo = [NSMutableDictionary dictionary];
    @try {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        [screenInfo setValue:@(screenSize.width) forKey:@"width"];
        [screenInfo setValue:@(screenSize.height) forKey:@"height"];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    
    return screenInfo;
}
@end
