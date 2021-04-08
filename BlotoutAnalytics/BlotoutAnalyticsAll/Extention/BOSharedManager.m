//
//  BOSharedManager.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOSharedManager.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAUtilities.h"
static id sBOSharedManagerSharedInstance = nil;


@implementation BOSharedManager

+(instancetype)sharedInstance {
  static dispatch_once_t BOSharedManagerOnceToken = 0;
  dispatch_once(&BOSharedManagerOnceToken, ^{
    sBOSharedManagerSharedInstance = [[BOSharedManager alloc] init];
  });
  
  return sBOSharedManagerSharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [BOAUtilities getDeviceId];
    _sessionId = [NSString stringWithFormat:@"%ld",(long)[BOAUtilities get13DigitIntegerTimeStamp]];
    _currentScreenName = @"";
    _referrer = @"";
  }
  return self;
}

+(void)refreshSession {
  [BOSharedManager sharedInstance].sessionId = [NSString stringWithFormat:@"%ld",(long)[BOAUtilities get13DigitIntegerTimeStamp]];
}
@end
