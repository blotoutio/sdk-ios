//
//  BOFSSUUID.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOFSSUUID : NSObject

// CFUUID - Random Unique Identifier that changes every time
+ (nullable NSString *)cfuuid;

// a UUID that may be used to uniquely identify the device, same across apps from a single vendor.
+ (nullable NSString *)idforVendor;

@end
