//
//  BOCaptureModel.m
//  BlotoutAnalytics
//
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "BOACaptureModel.h"

@implementation BOACaptureModel

- (instancetype)initWithEvent:(NSString *)event
                   properties:(NSDictionary *)properties screenName:(NSString* _Nullable)screenName withType:(NSString*)type {
  if (self = [super init]) {
    _event = event;
    _properties = properties != nil ? properties : @{};
    _screenName = screenName != nil ? screenName : @"";
    _type = type;
  }
  
  return self;
}

@end
