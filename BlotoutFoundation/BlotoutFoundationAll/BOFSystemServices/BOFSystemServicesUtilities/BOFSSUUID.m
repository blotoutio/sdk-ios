//
//  BOFSSUUID.m
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFSSUUID.h"
#import "BOFSSHardwareInfo.h"
#import "BOFSSProcessorInfo.h"
#import "BOFSSNetworkInfo.h"
#import "BOFSSDiskInfo.h"
#import "BOFSSAccelerometerInfo.h"
#import "BOFSSLocalizationInfo.h"
#import "BOFSSMemoryInfo.h"
#import "BOFSSJailbreakCheck.h"
#import "BOFSSAccessoryInfo.h"
#import "BOFSSBatteryInfo.h"

@implementation BOFSSUUID

// CFUUID
+ (NSString *)cfuuid {
    // Create a new CFUUID (Unique, random ID number) (Always different)
    @try {
        // Create a new instance of CFUUID using CFUUIDCreate using the default allocator
        CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
        
        // Check to make sure it exists
        if (theUUID)
        {
            // Make the new UUID String
            NSString *tempUniqueID = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, theUUID);
            
            // Check to make sure it created it
            if (tempUniqueID == nil || tempUniqueID.length <= 0) {
                // Error, Unable to create
                // Release the UUID Reference
                CFRelease(theUUID);
                // Return nil
                return nil;
            }
            
            // Release the UUID Reference
            CFRelease(theUUID);
            
            // Successful
            return tempUniqueID;
        } else {
            // Error
            // Release the UUID Reference
            CFRelease(theUUID);
            // Return nil
            return nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

+ (nullable NSString *)idforVendor{
    
    NSString *idforVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if(idforVendor == nil)
    {
        idforVendor = @"";
    }
    return idforVendor;
}

@end
