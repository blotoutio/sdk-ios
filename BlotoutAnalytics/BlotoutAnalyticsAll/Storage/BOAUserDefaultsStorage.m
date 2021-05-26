//
//  BOAUserDefaultsStorage.m
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAUserDefaultsStorage.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
#import "BOAUtilities.h"

@implementation BOAUserDefaultsStorage

+(NSNumber *)getUserBirthTimeStamp{
    NSNumber *timeStamp = [NSNumber numberWithInt:0];
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        timeStamp = [analyticsRootUD objectForKey:BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY];
        if(timeStamp == 0) {
            timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            [self setUserBirthTimeStamp:timeStamp];
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return timeStamp;
}

+(void)setUserBirthTimeStamp:(NSNumber*)timeStamp{
    @try {
        BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
        [analyticsRootUD setObject:timeStamp forKey:BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

@end
