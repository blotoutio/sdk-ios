//
//  BOFLogs.m
//  BlotoutFoundation
//
//  Created by Blotout on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFLogs.h"
#import <Foundation/Foundation.h>

static id sBOFLogsSharedInstance = nil;

void BOFLogDebug(NSString *frmt, ...){
    @autoreleasepool {
        if([BOFLogs sharedInstance].isSDKLogEnabled) {
            va_list args;
            va_start(args,frmt);
            
            NSString * msg = [[NSString alloc] initWithFormat:frmt  arguments:args];
            va_end(args);
            NSString *logMessage = [NSString stringWithFormat:@"[File Name : %s] [File Path : %s] [Method Name: %s] [Line No: %d] %@", __FILE_NAME__ ,__FILE__, __PRETTY_FUNCTION__ , __LINE__, msg];
            NSLog(@"Info: %@",logMessage);
        }
    }
}

void BOFLogError(NSString *frmt, ...){
    if([BOFLogs sharedInstance].isSDKLogEnabled) {
        @autoreleasepool {
                va_list args;
                va_start(args,frmt);
                
                NSString * msg = [[NSString alloc] initWithFormat:frmt  arguments:args];
                va_end(args);
                NSString *logMessage = [NSString stringWithFormat:@"[File Name : %s] [File Path : %s] [Method Name: %s] [Line No: %d] %@", __FILE_NAME__ ,__FILE__, __PRETTY_FUNCTION__ , __LINE__, msg];
                NSLog(@"Info: %@",logMessage);
            }
    }
}

void BOFLogInfo(NSString *frmt, ...){
    if([BOFLogs sharedInstance].isSDKLogEnabled) {
        @autoreleasepool {
            va_list args;
            va_start(args,frmt);
            
            NSString * msg = [[NSString alloc] initWithFormat:frmt  arguments:args];
            va_end(args);
            NSString *logMessage = [NSString stringWithFormat:@"[Method Name: %s] [Line No: %d] %@",__PRETTY_FUNCTION__ , __LINE__, msg];
            NSLog(@"Info: %@",logMessage);
        }
    }
}

@implementation BOFLogs

+ (nullable instancetype)sharedInstance{
    
    static dispatch_once_t bofLogsOnceToken = 0;
    dispatch_once(&bofLogsOnceToken, ^{
        sBOFLogsSharedInstance = [[[self class] alloc] init];
    });
    
    return  sBOFLogsSharedInstance;
    
}

@end
