//
//  BOFSSApplicationInfo.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOFSSApplicationInfo : NSObject

// Application Information

// Application Version
+ (nullable NSString *)applicationVersion;

// Clipboard Content
+ (nullable NSString *)clipboardContent;

// Application CPU Usage
+ (float)cpuUsage;

@end
