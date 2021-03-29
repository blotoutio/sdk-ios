//
//  BOCaptureModel.m
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 22/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "BOACaptureModel.h"

@implementation BOACaptureModel

- (instancetype)initWithEvent:(NSString *)event
                   properties:(NSDictionary *)properties eventCode:(NSNumber*)eventCode
{
    if (self = [super init]) {
        _event = event;
        _properties = properties;
        _eventSubCode = eventCode;
    }
    return self;
}

@end
