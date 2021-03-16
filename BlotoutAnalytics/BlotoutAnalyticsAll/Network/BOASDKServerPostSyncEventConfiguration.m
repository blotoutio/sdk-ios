//
//  BOASDKServerPostSyncEventConfiguration.m
//  BlotoutAnalytics
//
//  Created by Blotout on 27/02/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import "BOASDKServerPostSyncEventConfiguration.h"
#import "BOAppSessionData.h"
#import <BlotoutFoundation/BOFSystemServices.h>
#import "BOANetworkConstants.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAConstants.h"
#import "BOADeviceAndAppFraudController.h"
#import "BOAAppSessionEvents.h"
#import "BOCommonEvents.h"
#import "BOANetworkConstants.h"


static id sBOASdkServerPostSyncEventConfig = nil;

@implementation BOASDKServerPostSyncEventConfiguration

+ (instancetype)sharedInstance {
    static dispatch_once_t boaSdkServerPostSyncEventConfigOnceToken = 0;
    dispatch_once(&boaSdkServerPostSyncEventConfigOnceToken, ^{
        sBOASdkServerPostSyncEventConfig = [[[self class] alloc] init];
    });
    return  sBOASdkServerPostSyncEventConfig;
}

-(void)updateSentToServerForSessionEvents:(BOASystemAndDeveloperEvents*)events{
    @try {
        if (self.sessionObject && events) {
            for (BOAEvent *singleEvent in events.events) {
                [self updateConfigForEvent:singleEvent having:singleEvent.evcs andSubCode:singleEvent.evcs withMID:singleEvent.mid inSessionDataObject:self.sessionObject];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}
-(void)updateSentToServerForLifeTimeEvents:(BOASystemAndDeveloperEvents*)events{
    @try {
        if (self.lifetimeDataObject && events) {
            for (BOAEvent *singleEvent in events.events) {
                [self updateConfigForEvent:singleEvent having:singleEvent.evcs andSubCode:singleEvent.evcs withMID:singleEvent.mid inLifetimeDataObject:self.lifetimeDataObject];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateSentToServerForEvents:(BOASystemAndDeveloperEvents*)groupedEvents forSessionData:(BOAppSessionData*)sessionData{
    @try {
        if (sessionData && groupedEvents) {
            for (BOAEvent *singleEvent in groupedEvents.events) {
                [self updateConfigForEvent:singleEvent having:singleEvent.evcs andSubCode:singleEvent.evcs withMID:singleEvent.mid inSessionDataObject:sessionData];
            }
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateSentToServerForEvents:(BOASystemAndDeveloperEvents*)groupedEvents forLifeTimeData:(BOAAppLifetimeData*)lifeTimeData{
    @try {
        if (lifeTimeData && groupedEvents) {
            for (BOAEvent *singleEvent in groupedEvents.events) {
                [self updateConfigForEvent:singleEvent having:singleEvent.evcs andSubCode:singleEvent.evcs withMID:singleEvent.mid inLifetimeDataObject:lifeTimeData];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateSentToServerForPIIPHIEvents:(BOASystemAndDeveloperEvents*)groupedEvents forSessionData:(BOAppSessionData*)sessionData {
    @try {
        if(sessionData != nil && groupedEvents != nil) {
            for (BOAEvent *singleEvent in groupedEvents.piiEvents) {
                NSString *mid = singleEvent.mid;
                for (BOCustomEvent *event in sessionData.singleDaySessions.developerCodified.piiEvents) {
                    if ([event.mid isEqualToString:mid]) {
                        event.sentToServer = [NSNumber numberWithBool: YES];
                    }
                }
            }
            
            for (BOAEvent *singleEvent in groupedEvents.phiEvents) {
                NSString *mid = singleEvent.mid;
                for (BOCustomEvent *event in sessionData.singleDaySessions.developerCodified.phiEvents) {
                    if ([event.mid isEqualToString:mid]) {
                        event.sentToServer = [NSNumber numberWithBool: YES];
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateConfigForEvent:(BOAEvent*)serverEvent having:(NSNumber*)eventCode andSubCode:(NSNumber*)subCode withMID:(NSString*)messageID inSessionDataObject:(BOAppSessionData*)sessionData{
    @try {
        if (([eventCode intValue] >= BO_EVENT_DEVELOPER_CODED_KEY) && ([eventCode intValue] < BO_EVENT_FUNNEL_KEY)) {
            [self updateDeveloperCodifiedEvents:serverEvent forSession:sessionData];
        }else if (([eventCode intValue] >= BO_EVENT_RETENTION_KEY) && ([eventCode intValue] < BO_EVENT_EXCEPTION_KEY)){
            [self updateSessionRetentionEvents:serverEvent forSession:sessionData];
        }else if (([eventCode intValue] >= BO_EVENT_FUNNEL_KEY) && ([eventCode intValue] < BO_EVENT_RETENTION_KEY)){
            [self updateFunnelCommonEvents:serverEvent.mid having: sessionData];
        }else if (([eventCode intValue] >= BO_EVENT_SEGMENT_KEY) && ([eventCode intValue] < 80001)){
            //TODO: 80001 need to make constant for next base events
            [self updateSegmentsCommonEvents:serverEvent.mid having: sessionData];
        }else if([eventCode intValue] >= BO_EVENT_SYSTEM_KEY && [eventCode intValue] < BO_EVENT_DEVELOPER_CODED_KEY) {
            [self updateSystemEvents:serverEvent forSession:sessionData];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}


-(void)updateSystemEvents:(BOAEvent*)serverEvent forSession:(BOAppSessionData*)sessionObject {
    @try {
        
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appLaunched) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appInForeground) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appInBackground) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appActive) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appResignActive) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appBackgroundRefreshAvailable) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appReceiveMemoryWarning) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appSignificantTimeChange) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appOrientationPortrait) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appOrientationLandscape) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appStatusbarFrameChange) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appBackgroundRefreshStatusChange) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appNotificationReceived) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appNotificationViewed) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appNotificationClicked) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BOApp *event in sessionObject.singleDaySessions.appStates.appSessionInfo) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        if([sessionObject.singleDaySessions.appStates.appSessionInfo count] > 0) {
            sessionObject.singleDaySessions.appStates.appSessionInfo = [NSArray array];
        }
        
        for (BOAppNavigation *event in sessionObject.singleDaySessions.ubiAutoDetected.appNavigation) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        if([sessionObject.singleDaySessions.ubiAutoDetected.appNavigation count] > 0) {
            sessionObject.singleDaySessions.ubiAutoDetected.appNavigation = [NSArray array];
        }
        
        for (BOApp *event in sessionObject.singleDaySessions.appStates.sdkStart) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BOApp *event in sessionObject.singleDaySessions.appStates.pageHide) {
            if ([serverEvent.mid isEqualToString: event.mid]) {
                event.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        [self updateDeviceEvents:serverEvent forSession:sessionObject];
        [self updateMemoryEvents:serverEvent forSession:sessionObject];
        [self updatePIIEvents:serverEvent forSession:sessionObject];
        [self updateAdInfo:serverEvent forSession:sessionObject];
        
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateAdInfo:(BOAEvent*)serverEvent forSession:(BOAppSessionData*)sessionData{
    @try {
        if(sessionData.singleDaySessions.adInfo != NULL && sessionData.singleDaySessions.adInfo > 0) {
            for (BOAdInfo *adInformation in sessionData.singleDaySessions.adInfo) {
                if ([serverEvent.mid isEqualToString: adInformation.mid]) {
                    adInformation.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateDeviceEvents:(BOAEvent*)serverEvent forSession:(BOAppSessionData*)sessionData{
    @try {
        
        BODeviceInfo *deviceInfo = sessionData.singleDaySessions.deviceInfo;
        if(deviceInfo.batteryLevel != NULL && deviceInfo.batteryLevel.count > 0) {
            for (BOBatteryLevel *appInfo in deviceInfo.batteryLevel) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.multitaskingEnabled != NULL && deviceInfo.multitaskingEnabled.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.multitaskingEnabled) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.proximitySensorEnabled != NULL && deviceInfo.proximitySensorEnabled.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.proximitySensorEnabled) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.debuggerAttached != NULL && deviceInfo.debuggerAttached.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.pluggedIn != NULL && deviceInfo.pluggedIn.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.jailBroken != NULL && deviceInfo.jailBroken.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.numberOfActiveProcessors != NULL && deviceInfo.numberOfActiveProcessors.count > 0) {
            for (BONumberOfA *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.processorsUsage != NULL && deviceInfo.processorsUsage.count > 0) {
            for (BOProcessorsUsage *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.accessoriesAttached != NULL && deviceInfo.accessoriesAttached.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.headphoneAttached != NULL && deviceInfo.headphoneAttached.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.numberOfAttachedAccessories != NULL && deviceInfo.numberOfAttachedAccessories.count > 0) {
            for (BONumberOfA *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.nameOfAttachedAccessories != NULL && deviceInfo.nameOfAttachedAccessories.count > 0) {
            for (BONameOfAttachedAccessory *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.isCharging != NULL && deviceInfo.isCharging.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(deviceInfo.fullyCharged != NULL && deviceInfo.fullyCharged.count > 0) {
            for (BOAccessoriesAttached *appInfo in deviceInfo.debuggerAttached) {
                if ([serverEvent.mid isEqualToString: appInfo.mid]) {
                    appInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateMemoryEvents:(BOAEvent*)serverEvent forSession:(BOAppSessionData*)sessionData{
    @try {
        
        if(sessionData.singleDaySessions.memoryInfo != NULL && sessionData.singleDaySessions.memoryInfo.count > 0) {
            for (BOMemoryInfo *memoryInfo in sessionData.singleDaySessions.memoryInfo) {
                if ([serverEvent.mid isEqualToString: memoryInfo.mid]) {
                    memoryInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(sessionData.singleDaySessions.storageInfo != NULL && sessionData.singleDaySessions.storageInfo.count > 0) {
            for (BOStorageInfo *storageInfo in sessionData.singleDaySessions.storageInfo) {
                if ([serverEvent.mid isEqualToString: storageInfo.mid]) {
                    storageInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updatePIIEvents:(BOAEvent*)serverEvent forSession:(BOAppSessionData*)sessionData{
    @try {
        
        BONetworkInfo *networkInfoArray = sessionData.singleDaySessions.networkInfo;
        if(networkInfoArray.currentIPAddress != NULL && networkInfoArray.currentIPAddress.count > 0) {
            for (BOIPAddress *networkInfo in networkInfoArray.currentIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.cellBroadcastAddress != NULL && networkInfoArray.cellBroadcastAddress.count > 0) {
            for (BOBroadcastAddress *networkInfo in networkInfoArray.cellBroadcastAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.cellIPAddress != NULL && networkInfoArray.cellIPAddress.count > 0) {
            for (BOIPAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.cellNetMask != NULL && networkInfoArray.cellNetMask.count > 0) {
            for (BONetMask *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.connectedToCellNetwork != NULL && networkInfoArray.connectedToCellNetwork.count > 0) {
            for (BOConnectedTo *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.connectedToWifi != NULL && networkInfoArray.connectedToWifi.count > 0) {
            for (BOConnectedTo *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.externalIPAddress != NULL && networkInfoArray.externalIPAddress.count > 0) {
            for (BOIPAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.wifiBroadcastAddress != NULL && networkInfoArray.wifiBroadcastAddress.count > 0) {
            for (BOBroadcastAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.wifiIPAddress != NULL && networkInfoArray.wifiIPAddress.count > 0) {
            for (BOIPAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.wifiRouterAddress != NULL && networkInfoArray.wifiRouterAddress.count > 0) {
            for (BOWifiRouterAddress *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.wifiSSID != NULL && networkInfoArray.wifiSSID.count > 0) {
            for (BOWifiSSID *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
        
        if(networkInfoArray.wifiNetMask != NULL && networkInfoArray.wifiNetMask.count > 0) {
            for (BONetMask *networkInfo in networkInfoArray.cellIPAddress) {
                if ([serverEvent.mid isEqualToString: networkInfo.mid]) {
                    networkInfo.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateConfigForEvent:(BOAEvent*)serverEvent having:(NSNumber*)eventCode andSubCode:(NSNumber*)subCode withMID:(NSString*)messageID inLifetimeDataObject:(BOAAppLifetimeData*)lifetimeData{
    // BOARetentionEvent
    [self updateRetentionEvents:serverEvent forLifetimeData:lifetimeData];
}

-(void)updateDeveloperCodifiedEvents:(BOAEvent*)serverEvent forSession:(BOAppSessionData*)sessionObject {
    @try {
        // BODeveloperCodified & BORetentionEvent
        //Update Developer Codified and Retention Event Send To Server
        for (BODoubleTap *touchEvent in sessionObject.singleDaySessions.developerCodified.touchClick) {
            if ([serverEvent.mid isEqualToString: touchEvent.mid]) {
                touchEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *dragEvent in sessionObject.singleDaySessions.developerCodified.drag) {
            if ([serverEvent.mid isEqualToString: dragEvent.mid]) {
                dragEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *flickEvent in sessionObject.singleDaySessions.developerCodified.flick) {
            if ([serverEvent.mid isEqualToString: flickEvent.mid]) {
                flickEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *swipeEvent in sessionObject.singleDaySessions.developerCodified.swipe) {
            if ([serverEvent.mid isEqualToString: swipeEvent.mid]) {
                swipeEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *swipeEvent in sessionObject.singleDaySessions.developerCodified.swipe) {
            if ([serverEvent.mid isEqualToString: swipeEvent.mid]) {
                swipeEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *doubleTapEvent in sessionObject.singleDaySessions.developerCodified.doubleTap) {
            if ([serverEvent.mid isEqualToString: doubleTapEvent.mid]) {
                doubleTapEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *moreThanDoubleTapEvent in sessionObject.singleDaySessions.developerCodified.moreThanDoubleTap) {
            if ([serverEvent.mid isEqualToString: moreThanDoubleTapEvent.mid]) {
                moreThanDoubleTapEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *twoFingerTapEvent in sessionObject.singleDaySessions.developerCodified.twoFingerTap) {
            if ([serverEvent.mid isEqualToString: twoFingerTapEvent.mid]) {
                twoFingerTapEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *moreThanTwoFingerTapEvent in sessionObject.singleDaySessions.developerCodified.moreThanTwoFingerTap) {
            if ([serverEvent.mid isEqualToString: moreThanTwoFingerTapEvent.mid]) {
                moreThanTwoFingerTapEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *pinchEvent in sessionObject.singleDaySessions.developerCodified.pinch) {
            if ([serverEvent.mid isEqualToString: pinchEvent.mid]) {
                pinchEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *touchAndHoldEvent in sessionObject.singleDaySessions.developerCodified.touchAndHold) {
            if ([serverEvent.mid isEqualToString: touchAndHoldEvent.mid]) {
                touchAndHoldEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *shakeEvent in sessionObject.singleDaySessions.developerCodified.shake) {
            if ([serverEvent.mid isEqualToString: shakeEvent.mid]) {
                shakeEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BODoubleTap *rotateEvent in sessionObject.singleDaySessions.developerCodified.rotate) {
            if ([serverEvent.mid isEqualToString: rotateEvent.mid]) {
                rotateEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BOScreenEdgePan *screenEdgePanEvent in sessionObject.singleDaySessions.developerCodified.screenEdgePan) {
            if ([serverEvent.mid isEqualToString: screenEdgePanEvent.mid]) {
                screenEdgePanEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BOView *viewEvent in sessionObject.singleDaySessions.developerCodified.view) {
            if ([serverEvent.mid isEqualToString: viewEvent.mid]) {
                viewEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BOAddToCart *addToCartEvent in sessionObject.singleDaySessions.developerCodified.addToCart) {
            if ([serverEvent.mid isEqualToString: addToCartEvent.mid]) {
                addToCartEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BOChargeTransaction *chargeTransactionEvent in sessionObject.singleDaySessions.developerCodified.chargeTransaction) {
            if ([serverEvent.mid isEqualToString: chargeTransactionEvent.mid]) {
                chargeTransactionEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BOListUpdated *listUpdatedEvent in sessionObject.singleDaySessions.developerCodified.listUpdated) {
            if ([serverEvent.mid isEqualToString: listUpdatedEvent.mid]) {
                listUpdatedEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BOTimedEvent *timedEvent in sessionObject.singleDaySessions.developerCodified.timedEvent) {
            if ([serverEvent.mid isEqualToString: timedEvent.mid]) {
                timedEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
        
        for (BOCustomEvent *singleCusEvent in sessionObject.singleDaySessions.developerCodified.customEvents) {
            if ([serverEvent.mid isEqualToString: singleCusEvent.mid]) {
                singleCusEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateSessionRetentionEvents:(BOAEvent*)serverEvent forSession:(BOAppSessionData*)sessionObject{
    @try {
        //Update Retention Event Send To Server
        if ([serverEvent.mid isEqualToString:sessionObject.singleDaySessions.retentionEvent.mid]) {
            sessionObject.singleDaySessions.retentionEvent.sentToServer = [NSNumber numberWithBool: YES];
        }
        
        if ([serverEvent.mid isEqualToString:sessionObject.singleDaySessions.retentionEvent.dau.mid]) {
            sessionObject.singleDaySessions.retentionEvent.dau.sentToServer = [NSNumber numberWithBool: YES];
        }
        
        if ([serverEvent.mid isEqualToString:sessionObject.singleDaySessions.retentionEvent.dpu.mid]) {
            sessionObject.singleDaySessions.retentionEvent.dpu.sentToServer = [NSNumber numberWithBool: YES];
        }
        
        if ([serverEvent.mid isEqualToString:sessionObject.singleDaySessions.retentionEvent.appInstalled.mid]) {
            sessionObject.singleDaySessions.retentionEvent.appInstalled.sentToServer = [NSNumber numberWithBool: YES];
        }
        
        if ([serverEvent.mid isEqualToString:sessionObject.singleDaySessions.retentionEvent.theNewUser.mid]) {
            sessionObject.singleDaySessions.retentionEvent.theNewUser.sentToServer = [NSNumber numberWithBool: YES];
        }
        
        if ([serverEvent.mid isEqualToString:sessionObject.singleDaySessions.retentionEvent.dast.mid]) {
            sessionObject.singleDaySessions.retentionEvent.dast.sentToServer = [NSNumber numberWithBool: YES];
        }
        for (BOCustomEvent *singleRenEvent in sessionObject.singleDaySessions.retentionEvent.customEvents) {
            if ([serverEvent.mid isEqualToString: singleRenEvent.mid]) {
                singleRenEvent.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateRetentionEvents:(BOAEvent*)serverEvent forLifetimeData:(BOAAppLifetimeData*)lifetimeDataObject {
    @try {
        for (BOAAppLifeTimeInfo *appLifeInfo in lifetimeDataObject.appLifeTimeInfo) {
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.customEvents.mid]) {
                appLifeInfo.retentionEvent.customEvents.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.dau.mid]) {
                appLifeInfo.retentionEvent.dau.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.wau.mid]) {
                appLifeInfo.retentionEvent.wau.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.mau.mid]) {
                appLifeInfo.retentionEvent.mau.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.dpu.mid]) {
                appLifeInfo.retentionEvent.dpu.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.wpu.mid]) {
                appLifeInfo.retentionEvent.wpu.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.mpu.mid]) {
                appLifeInfo.retentionEvent.mpu.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.appInstalled.mid]) {
                appLifeInfo.retentionEvent.appInstalled.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.theNewUser.mid]) {
                appLifeInfo.retentionEvent.theNewUser.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.dast.mid]) {
                appLifeInfo.retentionEvent.dast.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.wast.mid]) {
                appLifeInfo.retentionEvent.wast.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.mast.mid]) {
                appLifeInfo.retentionEvent.mast.sentToServer = [NSNumber numberWithBool: YES];
            }
            if ([serverEvent.mid isEqualToString: appLifeInfo.retentionEvent.mast.mid]) {
                appLifeInfo.retentionEvent.mast.sentToServer = [NSNumber numberWithBool: YES];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateFunnelCommonEvents:(NSString*)serverEventMid having:(BOAppSessionData*)sessionData {
    @try {
        if (sessionData) {
            for (BOCommonEvent *event in sessionData.singleDaySessions.commonEvents) {
                if ([serverEventMid isEqualToString: event.mid]) {
                    event.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)updateSegmentsCommonEvents:(NSString*)serverEventMid having:(BOAppSessionData*)sessionData {
    @try {
        if (sessionData) {
            for (BOCommonEvent *event in sessionData.singleDaySessions.commonEvents) {
                if ([serverEventMid isEqualToString: event.mid]) {
                    event.sentToServer = [NSNumber numberWithBool: YES];
                }
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}


@end

