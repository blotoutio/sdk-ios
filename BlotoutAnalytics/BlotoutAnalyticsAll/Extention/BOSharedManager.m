//
//  BOSharedManager.m
//  BlotoutAnalytics
//
//  Created by Blotout on 22/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOSharedManager.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initJobManager];
        [BOAUtilities getDeviceId];
        _sessionId = [NSString stringWithFormat:@"%ld",(long)[BOAUtilities get13DigitIntegerTimeStamp]];
    }
    return self;
}

- (void)initJobManager {
    @try {
        self.jobManager = [[NSOperationQueue alloc] init];
        self.jobManager.qualityOfService = NSQualityOfServiceBackground;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

@end
