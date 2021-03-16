//
//  BONetworkEventService.h
//  BlotoutAnalytics
//
//  Created by Pawan Singh Jat on 19/01/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BONetworkEventService : NSObject

+(void)sendSdkStartEvent:(NSString*)screenName;
+(void)sendPageHideEvent:(NSString*)screenName storeEvents:(BOOL)storeEvent;
@end

NS_ASSUME_NONNULL_END
