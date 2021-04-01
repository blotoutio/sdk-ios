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
                   properties:(NSDictionary *)properties eventCode:(NSNumber*)eventCode screenName:(NSString* _Nullable)screenName withType:(NSString*)type
{
    if (self = [super init]) {
        _event = event;
        _properties = properties != nil ? properties : @{};
        _eventSubCode = eventCode;
        _screenName = screenName != nil ? screenName : @"";
        _type = type;
    }
    return self;
}

@end
