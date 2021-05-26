//
//  BOFSSDiskInfo.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOFSSDiskInfo : NSObject

// Disk Information

// Total Disk Space
+ (nullable NSString *)diskSpace;

// Total Free Disk Space
+ (nullable NSString *)freeDiskSpace:(BOOL)inPercent;

// Total Used Disk Space
+ (nullable NSString *)usedDiskSpace:(BOOL)inPercent;

// Get the total disk space in long format
+ (long long)longDiskSpace;

// Get the total free disk space in long format
+ (long long)longFreeDiskSpace;

@end
