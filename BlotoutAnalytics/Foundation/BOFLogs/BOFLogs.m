//
//  BOFLogs.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFLogs.h"
#import <Foundation/Foundation.h>

static id sBOFLogsSharedInstance = nil;

void BOFLogDebug(NSString *frmt, ...) {
  if (![BOFLogs sharedInstance].isSDKLogEnabled) {
    return;
  }

  @autoreleasepool {
    va_list args;
    va_start(args,frmt);
    
    NSString * msg = [[NSString alloc] initWithFormat:frmt  arguments:args];
    va_end(args);
    NSString *logMessage = [NSString stringWithFormat:@"[File Name : %s] [Method Name: %s] [Line No: %d] %@", __FILE_NAME__, __PRETTY_FUNCTION__ , __LINE__, msg];
    NSLog(@"Info: %@",logMessage);
  }
}

void BOFLogError(NSString *frmt, ...) {
  if (![BOFLogs sharedInstance].isSDKLogEnabled) {
    return;
  }
    
  @autoreleasepool {
    va_list args;
    va_start(args,frmt);
    
    NSString * msg = [[NSString alloc] initWithFormat:frmt  arguments:args];
    va_end(args);
    NSString *logMessage = [NSString stringWithFormat:@"[File Name : %s] [Method Name: %s] [Line No: %d] %@", __FILE_NAME__, __PRETTY_FUNCTION__ , __LINE__, msg];
    NSLog(@"Info: %@",logMessage);
  }
}

void BOFLogInfo(NSString *frmt, ...) {
  if (![BOFLogs sharedInstance].isSDKLogEnabled) {
    return;
  }
  
  @autoreleasepool {
    va_list args;
    va_start(args,frmt);
    
    NSString * msg = [[NSString alloc] initWithFormat:frmt  arguments:args];
    va_end(args);
    NSString *logMessage = [NSString stringWithFormat:@"[Method Name: %s] [Line No: %d] %@",__PRETTY_FUNCTION__ , __LINE__, msg];
    NSLog(@"Info: %@",logMessage);
  }
}

@implementation BOFLogs

+ (nullable instancetype)sharedInstance {
  static dispatch_once_t bofLogsOnceToken = 0;
  dispatch_once(&bofLogsOnceToken, ^{
    sBOFLogsSharedInstance = [[[self class] alloc] init];
  });
  
  return sBOFLogsSharedInstance;
}

@end
