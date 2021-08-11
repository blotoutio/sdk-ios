//
//  BOASystemEvents.h
//  BlotoutAnalytics
//
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOASystemEvents : NSObject
+(void)captureAppLaunchingInfoWithConfiguration:(NSDictionary *)launchOptions;
@end

NS_ASSUME_NONNULL_END
