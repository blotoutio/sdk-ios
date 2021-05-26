//
//  BOFSSProcessInfo.m
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFSSProcessInfo.h"

// sysctl
#import <sys/sysctl.h>

@implementation BOFSSProcessInfo

// Process Information

// Process ID
+ (int)processID {
    // Get the Process ID
    @try {
        // Get the PID
        int pid = getpid();
        // Make sure it's correct
        if (pid <= 0) {
            // Incorrect PID
            return -1;
        }
        // Successful
        return pid;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

@end
