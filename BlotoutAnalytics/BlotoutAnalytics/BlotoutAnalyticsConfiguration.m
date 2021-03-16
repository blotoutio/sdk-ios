//
//  BlotoutAnalyticsConfiguration.m
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 12/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "BlotoutAnalyticsConfiguration.h"

@interface BlotoutAnalyticsConfiguration ()

@property (nonatomic, copy, readwrite) NSString *token;
@property (nonatomic, copy, readwrite) NSString *endPointUrl;

@end

@implementation BlotoutAnalyticsConfiguration

+ (instancetype)configurationWithToken:(NSString *_Nonnull)token withUrl:(NSString *_Nonnull)endPointUrl
{
    return [[BlotoutAnalyticsConfiguration alloc] initWithToken:token withUrl:endPointUrl];
}

- (instancetype)initWithToken:(NSString *_Nonnull)token withUrl:(NSString *_Nonnull)endPointUrl;
{
    if (self = [self init]) {
        self.token = token;
        self.endPointUrl = endPointUrl;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

@end
