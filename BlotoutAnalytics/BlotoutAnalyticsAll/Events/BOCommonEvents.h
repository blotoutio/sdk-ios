//
//  BOCommonEvents.h
//  BlotoutAnalytics
//
//  Created by Blotout on 23/05/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOAEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOCommonEvents : BOAEvents

- (instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (instancetype)sharedInstance;

- (void)recordFunnelReceived;
- (void)recordFunnelTriggered;
- (void)recordSegmentReceived;
- (void)recordSegmentTriggered;

@end

NS_ASSUME_NONNULL_END
