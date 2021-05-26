//
//  BOFSSHardwareInfo.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOFSSHardwareInfo : NSObject

// System Hardware Information

// System Uptime (dd hh mm)
+ (nullable NSString *)systemUptime;

// Model of Device
+ (nullable NSString *)deviceModel;

// Device Name
+ (nullable NSString *)deviceName;

// System Name
+ (nullable NSString *)systemName;

// System Version
+ (nullable NSString *)systemVersion;

// System Device Type (iPhone1,0) (Formatted = iPhone 1)
+ (nullable NSString *)systemDeviceTypeFormatted:(BOOL)formatted;

// Get the Screen Width (X)
+ (NSInteger)screenWidth;

// Get the Screen Height (Y)
+ (NSInteger)screenHeight;

// Get the Screen Brightness
+ (float)screenBrightness;

// Multitasking enabled?
+ (BOOL)multitaskingEnabled;

// Proximity sensor enabled?
+ (BOOL)proximitySensorEnabled;

// Debugger Attached?
+ (BOOL)debuggerAttached;

// Plugged In?
+ (BOOL)pluggedIn;

// Step-Counting Available?
+ (BOOL)stepCountingAvailable;

// Distance Available
+ (BOOL)distanceAvailable;

// Floor Counting Available
+ (BOOL)floorCountingAvailable;

@end
