//
//  UIViewController+ExtensionsViewController.m
//  BlotoutAnalytics
//
//  Created by Blotout on 30/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "UIViewController+Extensions.h"
#import <objc/runtime.h>
#import "BOSharedManager.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAUtilities.h"
#import "BOANetworkConstants.h"
#import "BOACaptureModel.h"
#import "BlotoutAnalytics_Internal.h"

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
        
        SEL viewWillDisappearSelector = @selector(viewWillDisappear:);
        SEL viewWillDisappearLoggerSelector = @selector(logged_viewWillDisappear:);
        Method originalDisappearMethod = class_getInstanceMethod(self, viewWillDisappearSelector);
        Method extendedDisappearMethod = class_getInstanceMethod(self, viewWillDisappearLoggerSelector);
        method_exchangeImplementations(originalDisappearMethod, extendedDisappearMethod);
    });
}

+ (UIViewController *)getTopmostViewController
{
    UIViewController *root;
    if([BlotoutAnalytics sharedInstance].config.application != nil) {
        root = [BlotoutAnalytics sharedInstance].config.application.delegate.window.rootViewController;
    } else {
        root = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
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

-(NSString*)getScreenName:(UIViewController *)viewController {
    NSString *name = [viewController title];
    if (!name || name.length == 0) {
        name = [[[viewController class] description] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
        if (name.length == 0) {
            name = @"Unknown";
        }
    }
    
    return name;
}

- (void)logged_viewWillDisappear:(BOOL)animated {
    @try {
        
        UIViewController *top = [[self class] getTopmostViewController];
        if (!top) {
            return;
        }
        
        [self logged_viewWillDisappear:animated];
        
        [BOSharedManager sharedInstance].isViewDidAppeared = NO;
        // Send page_hide event
        if([BlotoutAnalytics sharedInstance].eventManager != nil) {
            BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_VISIBILITY_HIDDEN properties:nil eventCode:@(BO_EVENT_VISIBILITY_HIDDEN) screenName:[self getScreenName:top] withType:BO_SYSTEM];
            [[BlotoutAnalytics sharedInstance].eventManager capture:model];
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}
- (void)logged_viewDidAppear:(BOOL)animated {
    @try {
        
        UIViewController *top = [[self class] getTopmostViewController];
        if (!top) {
            return;
        }
        
        [self logged_viewDidAppear:animated];
        if(![BOSharedManager sharedInstance].isViewDidAppeared) {
            [BOSharedManager sharedInstance].isViewDidAppeared = YES;
            // Send sdk_start event
            // Send page_hide event
            if([BlotoutAnalytics sharedInstance].eventManager != nil) {
                BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_SDK_START properties:nil eventCode:@(BO_EVENT_SDK_START) screenName:[self getScreenName:top] withType:BO_SYSTEM];
                [[BlotoutAnalytics sharedInstance].eventManager capture:model];
            }
        }
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}
@end
