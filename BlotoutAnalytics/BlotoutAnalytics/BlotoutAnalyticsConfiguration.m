//
//  BlotoutAnalyticsConfiguration.m
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 12/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "BlotoutAnalyticsConfiguration.h"

@implementation UIApplication (BOAApplicationProtocol)

- (UIBackgroundTaskIdentifier)boa_beginBackgroundTaskWithName:(nullable NSString *)taskName expirationHandler:(void (^__nullable)(void))handler
{
    return [self beginBackgroundTaskWithName:taskName expirationHandler:handler];
}

- (void)boa_endBackgroundTask:(UIBackgroundTaskIdentifier)identifier
{
    [self endBackgroundTask:identifier];
}

@end



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
        self.flushAt = 20;
        self.flushInterval = 30;
        self.maxQueueSize = 1000;
        Class applicationClass = NSClassFromString(@"UIApplication");
        if (applicationClass) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            _application = [applicationClass performSelector:NSSelectorFromString(@"sharedApplication")];
#pragma clang diagnostic pop
        }
    }
    return self;
}

@end
