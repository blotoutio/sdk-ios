//
//  BOADeviceEvents.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOADeviceEvents : BOAEvents

@property (nonatomic, readwrite) BOOL isEnabled;

- (instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (instancetype)sharedInstance;

-(void)recordDeviceEvents;
-(void)recordNetworkEvents;
-(void)recordStorageEvents;
-(void)recordMemoryEvents;
-(void)recordAdInformation;

//-(void)recordLocationEvents;

@end

NS_ASSUME_NONNULL_END
