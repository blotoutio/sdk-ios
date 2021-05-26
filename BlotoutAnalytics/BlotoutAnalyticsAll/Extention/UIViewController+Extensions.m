//
//  UIViewController+ExtensionsViewController.m
//  BlotoutAnalytics
//
//  Created by Blotout on 30/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "UIViewController+Extensions.h"
#import <objc/runtime.h>
#import "BOAppSessionData.h"
#import "BOSharedManager.h"
#import "BOAFunnelSyncController.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"
#import "BOAUtilities.h"
void loadAsUIViewControllerBOFoundationCat(void){
    
}

@implementation UIViewController (Extensions)

+ (void)load {
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        SEL viewDidAppearSelector = @selector(viewDidAppear:);
        SEL viewDidAppearLoggerSelector = @selector(logged_viewDidAppear:);
        Method originalMethod = class_getInstanceMethod(self, viewDidAppearSelector);
        Method extendedMethod = class_getInstanceMethod(self, viewDidAppearLoggerSelector);
        method_exchangeImplementations(originalMethod, extendedMethod);
    });
}

+ (UIViewController *)getTopmostViewController
{
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self topmostViewController:root];
}

+ (UIViewController *)topmostViewController:(UIViewController *)rootViewController
{
    UIViewController *presentedViewController = rootViewController.presentedViewController;
    if (presentedViewController != nil) {
        return [self topmostViewController:presentedViewController];
    }
    
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *lastViewController = [[(UINavigationController *)rootViewController viewControllers] lastObject];
        return [self topmostViewController:lastViewController];
    }
    
    return rootViewController;
}
- (void)logged_viewDidAppear:(BOOL)animated {
    @try {
        
        UIViewController *top = [[self class] getTopmostViewController];
        if (!top) {
            return;
        }
        
        [self logged_viewDidAppear:animated];
        
        BOAppSessionData *appSessionData = [BOAppSessionData sharedInstanceFromJSONDictionary:nil];
        BOSharedManager *extentionManager = [BOSharedManager sharedInstance];
        
        BOAppNavigation *navObject = [[BOAppNavigation alloc] init];
        navObject.from = extentionManager.currentNavigation.to != nil ? [NSString stringWithFormat:@"%@",extentionManager.currentNavigation.to] : nil;
        navObject.to = [NSString stringWithFormat:@"%@", [top class]];
        extentionManager.currentNavigation = navObject;
        
        if(extentionManager.currentNavigation != nil && extentionManager.currentNavigation.from != nil && ![extentionManager.currentNavigation.from isEqualToString:extentionManager.currentNavigation.to]) {
            NSMutableArray *appNavigationArray = [appSessionData.singleDaySessions.ubiAutoDetected.appNavigation mutableCopy];
            //if(![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible] &&
            if(extentionManager.currentTime > 0.0) {
                if (extentionManager.currentTimer) {
                    [extentionManager.currentTimer invalidate];
                }
                extentionManager.currentNavigation.timeSpent = [NSNumber numberWithFloat:extentionManager.currentTime];
            }
            
            [appNavigationArray addObject:extentionManager.currentNavigation];
            
            appSessionData.singleDaySessions.ubiAutoDetected.appNavigation = appNavigationArray;
            
            
            //Funnel execution and testing based
            [[BOAFunnelSyncController sharedInstanceFunnelController] recordNavigationEventFrom:navObject.from to:navObject.to withDetails:@{}];
        }
        
        
        //if([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
        //intialize network indicator if any
        if (extentionManager.currentTimer) {
            [extentionManager.currentTimer invalidate];
        }
        extentionManager.currentNavigation.networkIndicatorVisible = [NSNumber numberWithBool:YES];
        extentionManager.currentTimer = [self createTimer];
        extentionManager.currentTime = 0.0;
        //}
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSTimer *)createTimer {
    @try {
        return [NSTimer scheduledTimerWithTimeInterval:0.1
                                                target:self
                                              selector:@selector(timerTicked:)
                                              userInfo:nil
                                               repeats:YES];
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (void)timerTicked:(NSTimer *)timer {
    @try {
        BOSharedManager *extentionManager = [BOSharedManager sharedInstance];
        extentionManager.currentTime += 0.1;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

@end
