//
//  BOACommunicatonController.m
//  BlotoutAnalytics
//
//  Created by Blotout on 23/11/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOACommunicatonController.h"
#import "BOANotificationConstants.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

static id sBOAsdkCommControllerSharedInstance = nil;

@implementation BOACommunicatonController

-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (nullable instancetype)sharedInstance{
    static dispatch_once_t boaSDKCommControllerOnceToken = 0;
    dispatch_once(&boaSDKCommControllerOnceToken, ^{
        sBOAsdkCommControllerSharedInstance = [[[self class] alloc] init];
    });
    return  sBOAsdkCommControllerSharedInstance;
}

-(void)postMessage:(NSString*)messageName asNotifications:(BOOL)notify{
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:messageName object:nil];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)postMessage:(NSString*)messageStr withObject:(id)extraInfo asNotifications:(BOOL)notify{
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:messageStr object:extraInfo];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)postMessage:(NSString*)messageStr withObject:(id)extraInfo andUserInfo:(NSDictionary*)userInfo asNotifications:(BOOL)notify{
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:messageStr object:extraInfo userInfo:userInfo];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

@end
