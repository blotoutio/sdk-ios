//
//  BOADeviceEvents.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOADeviceEvents.h"
#import "BOAppSessionData.h"
#import "BOAAppLifetimeData.h"
#import <BlotoutFoundation/BOFSystemServices.h>
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
#import "BOANetworkConstants.h"
#import <AdSupport/ASIdentifierManager.h>
#import "BOSharedManager.h"

static id sBOADeviceEvnetsSharedInstance = nil;
@implementation BOADeviceEvents

-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaDeviceEventsOnceToken = 0;
    dispatch_once(&boaDeviceEventsOnceToken, ^{
        sBOADeviceEvnetsSharedInstance = [[[self class] alloc] init];
    });
    return  sBOADeviceEvnetsSharedInstance;
}

-(void)recordDeviceEvents{
    @try {
        if (self.isEnabled) {
            BOFSystemServices *sharedSSService = [BOFSystemServices sharedServices];
            if (BOAEvents.isSessionModelInitialised) {
                BOAccessoriesAttached *multiTasking = [BOAccessoriesAttached fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"MultiTaskingState"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_STATUS: [NSNumber numberWithBool:sharedSSService.multitaskingEnabled]
                }
                                                       ];
                NSMutableArray *existingMultiTask = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.multitaskingEnabled mutableCopy];
                [existingMultiTask addObject:multiTasking];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setMultitaskingEnabled:existingMultiTask];
                
                NSLog(@"%@", [BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.multitaskingEnabled);
                
                
                BOAccessoriesAttached *proximitySensor = [BOAccessoriesAttached fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"ProximitySensorState"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_STATUS: [NSNumber numberWithBool:sharedSSService.proximitySensorEnabled]
                }
                                                          ];
                NSMutableArray *existingProximitySensors = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.proximitySensorEnabled mutableCopy];
                [existingProximitySensors addObject:proximitySensor];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setProximitySensorEnabled:existingProximitySensors];
                
                
                BOAccessoriesAttached *debuggerAttached = [BOAccessoriesAttached fromJSONDictionary:@{
                    BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"DebuggerAttachedState"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_STATUS: [NSNumber numberWithBool:sharedSSService.debuggerAttached]
                }
                                                           ];
                NSMutableArray *existingDebuggers = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.debuggerAttached mutableCopy];
                [existingDebuggers addObject:debuggerAttached];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setDebuggerAttached:existingDebuggers];
                
                
                BOAccessoriesAttached *pluggedIn = [BOAccessoriesAttached fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"PluggedIn"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_STATUS: [NSNumber numberWithBool:sharedSSService.pluggedIn]
                }
                                                    ];
                NSMutableArray *existingPluggedin = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.pluggedIn mutableCopy];
                [existingPluggedin addObject:pluggedIn];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setPluggedIn:existingPluggedin];
                
                
                BOOL isJailBroken = (sharedSSService.jailbroken != 4783242);
                BOAccessoriesAttached *jailBroken = [BOAccessoriesAttached fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"JailBroken"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_STATUS: [NSNumber numberWithBool:isJailBroken]
                }
                                                     ];
                NSMutableArray *existingJailBroken = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.jailBroken mutableCopy];
                [existingJailBroken addObject:jailBroken];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setJailBroken:existingJailBroken];
                
                
                
                BONumberOfA *activeProcessors = [BONumberOfA fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"ActiveProcessor"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_NUMBER: [NSNumber numberWithInteger:sharedSSService.numberActiveProcessors]
                }
                                                 ];
                NSMutableArray *existingActiveProcessors = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.numberOfActiveProcessors mutableCopy];
                [existingActiveProcessors addObject:activeProcessors];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setNumberOfActiveProcessors:existingActiveProcessors];
                
                
                for (int pID=0; pID < sharedSSService.processorsUsage.count; pID++ ) {
                    NSNumber *usage = [sharedSSService.processorsUsage objectAtIndex:pID];
                    double usagePercentage = [usage doubleValue] * 100;
                    BOProcessorsUsage *processorsUsage = [BOProcessorsUsage fromJSONDictionary:@{
                        BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                        BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"ProcessorPercentage"],
                        BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                        BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                        BO_PROCESSOR_ID: [NSNumber numberWithInt:pID],
                        BO_USAGE_PERCENTAGE: [NSNumber numberWithDouble:usagePercentage]
                    }
                                                          ];
                    NSMutableArray *existingProcessorUsage = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.processorsUsage mutableCopy];
                    [existingProcessorUsage addObject:processorsUsage];
                    [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setProcessorsUsage:existingProcessorUsage];
                }
                
                BOAccessoriesAttached *accessoriesAttached = [BOAccessoriesAttached fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"AccessoriesAttached"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_STATUS: [NSNumber numberWithBool:sharedSSService.accessoriesAttached]
                }
                                                              ];
                NSMutableArray *existingAccessories = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.accessoriesAttached mutableCopy];
                [existingAccessories addObject:accessoriesAttached];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setAccessoriesAttached:existingAccessories];
                
                
                BOAccessoriesAttached *headphoneAttached = [BOAccessoriesAttached fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"HeadphoneAttached"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_STATUS: [NSNumber numberWithBool:sharedSSService.headphonesAttached]
                }
                                                            ];
                NSMutableArray *existingHeadphoneAttached = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.headphoneAttached mutableCopy];
                [existingHeadphoneAttached addObject:headphoneAttached];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setHeadphoneAttached:existingHeadphoneAttached];
                
                
                BONumberOfA *numberOfAttachedAccessories = [BONumberOfA fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"NumberOfAccessories"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_NUMBER: [NSNumber numberWithInteger:sharedSSService.numberAttachedAccessories]
                }
                                                            ];
                NSMutableArray *existingNumberOfAttachedAccessories = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.numberOfAttachedAccessories mutableCopy];
                [existingNumberOfAttachedAccessories addObject:numberOfAttachedAccessories];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setNumberOfAttachedAccessories:existingNumberOfAttachedAccessories];
                
                
                BONameOfAttachedAccessory *nameOfAttachedAccessories = [BONameOfAttachedAccessory fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"NameOfAccessory"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_NAMES: sharedSSService.nameAttachedAccessories ? [NSArray arrayWithObject:sharedSSService.nameAttachedAccessories] : NSNull.null
                }
                                                                        ];
                NSMutableArray *existingNameOfAttachedAccessories = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.nameOfAttachedAccessories mutableCopy];
                [existingNameOfAttachedAccessories addObject:nameOfAttachedAccessories];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setNameOfAttachedAccessories:existingNameOfAttachedAccessories];
                
                
                BOBatteryLevel *batteryLevel = [BOBatteryLevel fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"BatteryLevel"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_PERCENTAGE: [NSNumber numberWithFloat:sharedSSService.batteryLevel]
                }
                                                ];
                NSMutableArray *existingBatteryLevel = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.batteryLevel mutableCopy];
                [existingBatteryLevel addObject:batteryLevel];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setBatteryLevel:existingBatteryLevel];
                
                
                BOAccessoriesAttached *isCharging = [BOAccessoriesAttached fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"BatteryCharging"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_STATUS: [NSNumber numberWithBool:sharedSSService.charging]
                }
                                                     ];
                NSMutableArray *existingIsCharging = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.isCharging mutableCopy];
                [existingIsCharging addObject:isCharging];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setIsCharging:existingIsCharging];
                
                
                BOAccessoriesAttached *fullyCharged = [BOAccessoriesAttached fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"BatteryFullCharged"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_STATUS: [NSNumber numberWithBool:sharedSSService.fullyCharged]
                }
                                                       ];
                NSMutableArray *existingFullyCharged = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.fullyCharged mutableCopy];
                [existingFullyCharged addObject:fullyCharged];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setFullyCharged:existingFullyCharged];
                
                
                BODeviceOrientation *deviceOrientation = [BODeviceOrientation fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"DeviceOrientation"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_ORIENTATION: [NSNumber numberWithInteger:sharedSSService.deviceOrientation]
                }
                                                          ];
                NSMutableArray *existingDeviceOrientation = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.deviceOrientation mutableCopy];
                [existingDeviceOrientation addObject:deviceOrientation];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setDeviceOrientation:existingDeviceOrientation];
                
                
                BOCFUUID *cfUUID = [BOCFUUID fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"CFUUID"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_CF_UUID: sharedSSService.cfuuid ? sharedSSService.cfuuid : NSNull.null
                }
                                    ];
                NSMutableArray *existingCFUUID = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.cfUUID mutableCopy];
                [existingCFUUID addObject:cfUUID];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setCfUUID:existingCFUUID];
                
                
                BOVendorID *vendorID = [BOVendorID fromJSONDictionary:@{
                    BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                    BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"VendorID"],
                    BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                    BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                    BO_VENDOR_ID: [[UIDevice currentDevice].identifierForVendor UUIDString] ? [[UIDevice currentDevice].identifierForVendor UUIDString] : NSNull.null
                }
                                        ];
                NSMutableArray *existingVendorID = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo.vendorID mutableCopy];
                [existingVendorID addObject:vendorID];
                [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.deviceInfo setVendorID:existingVendorID];
            }
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordNetworkEvents{
    @try {
        BOFSystemServices *sharedSSService = [BOFSystemServices sharedServices];
        if (sharedSSService.currentIPAddress && ![sharedSSService.currentIPAddress isEqualToString:@""]) {
            BOIPAddress *currentIPAddress = [BOIPAddress fromJSONDictionary:@{
                BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"CurrentIPAddress"],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                BO_IP_ADDRESS: NSNullifyCheck(sharedSSService.currentIPAddress)
            }
                                             ];
            NSMutableArray *existingCurrentIPAddress = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.currentIPAddress mutableCopy];
            [existingCurrentIPAddress addObject:currentIPAddress];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setCurrentIPAddress:existingCurrentIPAddress];
        }
        
        if (sharedSSService.externalIPAddress && ![sharedSSService.externalIPAddress isEqualToString:@""]) {
            BOIPAddress *externalIPAddress = [BOIPAddress fromJSONDictionary:@{
                BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"ExternalIPAddress"],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                BO_IP_ADDRESS: NSNullifyCheck(sharedSSService.externalIPAddress)
            }
                                              ];
            NSMutableArray *existingExternalIPAddress = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.externalIPAddress mutableCopy];
            [existingExternalIPAddress addObject:externalIPAddress];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setExternalIPAddress:existingExternalIPAddress];
        }
        
        if (sharedSSService.cellIPAddress && ![sharedSSService.cellIPAddress isEqualToString:@""]) {
            BOIPAddress *cellIPAddress = [BOIPAddress fromJSONDictionary:@{
                BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"CellIPAddress"],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                BO_IP_ADDRESS: NSNullifyCheck(sharedSSService.cellIPAddress)
            }
                                          ];
            NSMutableArray *existingCellIPAddress = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.cellIPAddress mutableCopy];
            [existingCellIPAddress addObject:cellIPAddress];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setCellIPAddress:existingCellIPAddress];
        }
        
        if (sharedSSService.cellNetmaskAddress && ![sharedSSService.cellNetmaskAddress isEqualToString:@""]) {
            BONetMask *cellNetMask = [BONetMask fromJSONDictionary:@{
                BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"CellNetMask"],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                BO_NETMASK: NSNullifyCheck(sharedSSService.cellNetmaskAddress)
            }
                                      ];
            NSMutableArray *existingCellNetMask = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.cellNetMask mutableCopy];
            [existingCellNetMask addObject:cellNetMask];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setCellNetMask:existingCellNetMask];
        }
        
        if (sharedSSService.cellBroadcastAddress && ![sharedSSService.cellBroadcastAddress isEqualToString:@""]) {
            BOBroadcastAddress *cellBroadcastAddress = [BOBroadcastAddress fromJSONDictionary:@{
                BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"CellBroadcastAddress"],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                BO_BROADCAST_ADDRESS: NSNullifyCheck(sharedSSService.cellBroadcastAddress)
            }
                                                        ];
            NSMutableArray *existingCellBroadcastAddress = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.cellBroadcastAddress mutableCopy];
            [existingCellBroadcastAddress addObject:cellBroadcastAddress];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setCellBroadcastAddress:existingCellBroadcastAddress];
        }
        
        if (sharedSSService.wiFiIPAddress && ![sharedSSService.wiFiIPAddress isEqualToString:@""]) {
            BOIPAddress *wifiIPAddress = [BOIPAddress fromJSONDictionary:@{
                BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"WifiIPAddress"],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                BO_IP_ADDRESS: NSNullifyCheck(sharedSSService.wiFiIPAddress)
            }
                                          ];
            NSMutableArray *existingWifiIPAddress = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.wifiIPAddress mutableCopy];
            [existingWifiIPAddress addObject:wifiIPAddress];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setWifiIPAddress:existingWifiIPAddress];
        }
        
        if (sharedSSService.wiFiNetmaskAddress && ![sharedSSService.wiFiNetmaskAddress isEqualToString:@""]) {
            BONetMask *wifiNetMask = [BONetMask fromJSONDictionary:@{
                BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"WifiNetMask"],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                BO_NETMASK: NSNullifyCheck(sharedSSService.wiFiNetmaskAddress)
            }
                                      ];
            NSMutableArray *existingWifiNetMask = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.wifiNetMask mutableCopy];
            [existingWifiNetMask addObject:wifiNetMask];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setWifiNetMask:existingWifiNetMask];
        }
        
        if (sharedSSService.wiFiBroadcastAddress && ![sharedSSService.wiFiBroadcastAddress isEqualToString:@""]) {
            BOBroadcastAddress *wifiBroadcastAddress = [BOBroadcastAddress fromJSONDictionary:@{
                BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"WifiBroadcastAddress"],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                BO_BROADCAST_ADDRESS: NSNullifyCheck(sharedSSService.wiFiBroadcastAddress)
            }
                                                        ];
            NSMutableArray *existingWifiBroadcastAddress = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.wifiBroadcastAddress mutableCopy];
            [existingWifiBroadcastAddress addObject:wifiBroadcastAddress];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setWifiBroadcastAddress:existingWifiBroadcastAddress];
        }
        
        if (sharedSSService.wiFiRouterAddress && ![sharedSSService.wiFiRouterAddress isEqualToString:@""]) {
            BOWifiRouterAddress *wifiRouterAddress = [BOWifiRouterAddress fromJSONDictionary:@{
                BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
                BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"WifiRouterAddress"],
                BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
                BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
                BO_ROUTER_ADDRESS: NSNullifyCheck(sharedSSService.wiFiRouterAddress)
            }
                                                      ];
            NSMutableArray *existingWifiRouterAddress = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.wifiRouterAddress mutableCopy];
            [existingWifiRouterAddress addObject:wifiRouterAddress];
            [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setWifiRouterAddress:existingWifiRouterAddress];
        }
        
        
        BOWifiSSID *wifiSSID = [BOWifiSSID fromJSONDictionary:@{
            BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
            BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"WifiSSID"],
            BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
            BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
            BO_SSID: @"NotAllowed" //Write logic for generate based on LanPing library later
        }
                                ];
        NSMutableArray *existingWifiSSID = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.wifiSSID mutableCopy];
        [existingWifiSSID addObject:wifiSSID];
        [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setWifiSSID:existingWifiSSID];
        
        
        BOConnectedTo *connectedToWifi = [BOConnectedTo fromJSONDictionary:@{
            BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
            BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"ConnectedToWifi"],
            BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
            BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
            BO_IS_CONNECTED: [NSNumber numberWithBool:sharedSSService.connectedToWiFi]
        }
                                          ];
        NSMutableArray *existingConnectedToWifi = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.connectedToWifi mutableCopy];
        [existingConnectedToWifi addObject:connectedToWifi];
        [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setConnectedToWifi:existingConnectedToWifi];
        
        
        BOConnectedTo *connectedToCellNetwork = [BOConnectedTo fromJSONDictionary:@{
            BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
            BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"ConnectedToCellNet"],
            BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
            BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp],
            BO_IS_CONNECTED: [NSNumber numberWithBool:sharedSSService.connectedToCellNetwork]
        }
                                                 ];
        NSMutableArray *existingConnectedToCellNetwork = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo.connectedToCellNetwork mutableCopy];
        [existingConnectedToCellNetwork addObject:connectedToCellNetwork];
        [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.networkInfo setConnectedToCellNetwork:existingConnectedToCellNetwork];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordStorageEvents{
    @try {
        BOFSystemServices *sharedSSService = [BOFSystemServices sharedServices];
        BOStorageInfo *storageInfo = [BOStorageInfo fromJSONDictionary:@{
            BO_SENT_TO_SERVER:[NSNumber numberWithBool:NO],
            BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"StorageInfo"],
            BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
            BO_TOTAL_DISK_SPACE: NSNullifyCheck(sharedSSService.diskSpace),
            BO_USED_DISK_SPACE: NSNullifyCheck(sharedSSService.usedDiskSpaceinRaw),
            BO_FREE_DISK_SPACE: NSNullifyCheck(sharedSSService.freeDiskSpaceinRaw),
            BO_SPACE_UNIT: @"GB",
            BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp]
        }
                                      ];
        NSMutableArray *existingStorageInfo = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.storageInfo mutableCopy];
        [existingStorageInfo addObject:storageInfo];
        [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setStorageInfo:existingStorageInfo];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)recordMemoryEvents{
    @try {
        BOFSystemServices *sharedSSService = [BOFSystemServices sharedServices];
        BOMemoryInfo *memoryInfo = [BOMemoryInfo fromJSONDictionary:@{
            BO_MEMORY_WARNING:[NSNumber numberWithBool:NO],
            BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent:@"MemoryRAMInfo"],
            BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
            BO_TOTAL_RAM: [NSNumber numberWithDouble:sharedSSService.totalMemory],
            BO_USED_MEMORY: [NSNumber numberWithDouble:sharedSSService.usedMemoryinRaw],
            BO_WIRED_MEMORY: [NSNumber numberWithDouble:sharedSSService.wiredMemoryinRaw],
            BO_ACTIVE_MEMORY: [NSNumber numberWithDouble:sharedSSService.activeMemoryinRaw],
            BO_IN_ACTIVE_MEMORY: [NSNumber numberWithDouble:sharedSSService.inactiveMemoryinRaw],
            BO_FREE_MEMORY: [NSNumber numberWithDouble:sharedSSService.freeMemoryinRaw],
            BO_PURGEABLE_MEMORY: [NSNumber numberWithDouble:sharedSSService.purgableMemoryinRaw],
            BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
            BO_TIME_STAMP:[BOAUtilities get13DigitNumberObjTimeStamp]
        }];
        
        NSMutableArray *existingMemoryInfo = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.memoryInfo mutableCopy];
        [existingMemoryInfo addObject:memoryInfo];
        [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setMemoryInfo:existingMemoryInfo];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)recordAdInformation {
    @try {
        BOAdInfo *adInfo = [BOAdInfo fromJSONDictionary:@{
            BO_MESSAGE_ID: [BOAUtilities getMessageIDForEvent: BO_EVENT_AD_INFO],
            BO_SESSION_ID: [BOSharedManager sharedInstance].sessionId,
            BO_SENT_TO_SERVER: [NSNumber numberWithBool:NO],
            BO_TIME_STAMP: [BOAUtilities get13DigitNumberObjTimeStamp],
            BO_AD_IDENTIFIER: [self getIDFA],
            BO_AD_DO_NOT_TRACK: [NSNumber numberWithBool:[self getAdTrackingEnabled]]
        }];
        
        NSMutableArray *existingAdInfo = [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions.adInfo mutableCopy];
        [existingAdInfo addObject: adInfo];
        [[BOAppSessionData sharedInstanceFromJSONDictionary:nil].singleDaySessions setAdInfo:existingAdInfo];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(NSString*)getIDFA {
    NSString *idForAdvertiser = nil;
    @try {
        Class identifierManager = NSClassFromString(@"ASIdentifierManager");
        if (identifierManager) {
            SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
            id sharedManager =
            ((id (*)(id, SEL))
             [identifierManager methodForSelector:sharedManagerSelector])(
                                                                          identifierManager, sharedManagerSelector);
            SEL advertisingIdentifierSelector =
            NSSelectorFromString(@"advertisingIdentifier");
            NSUUID *uuid =
            ((NSUUID * (*)(id, SEL))
             [sharedManager methodForSelector:advertisingIdentifierSelector])(
                                                                              sharedManager, advertisingIdentifierSelector);
            idForAdvertiser = [uuid UUIDString];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return idForAdvertiser;
}

-(BOOL)getAdTrackingEnabled {
    @try{
        return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        return NO;
    }
}

@end
