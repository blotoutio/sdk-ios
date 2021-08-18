//
//  UIViewController+ExtensionsViewController.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "UIViewController+Extensions.h"
#import <objc/runtime.h>
#import "BOSharedManager.h"
#import "BOFLogs.h"
#import "BOAUtilities.h"
#import "BOANetworkConstants.h"
#import "BOACaptureModel.h"
#import "BlotoutAnalytics_Internal.h"
#import "BOEventsOperationExecutor.h"

void loadAsUIViewControllerBOFoundationCat(void) {}

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

+ (UIViewController *)getRootViewControllerFromView:(UIView *)view {
  
  UIViewController *root = view.window.rootViewController;
  return [self topViewController:root];
  
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    UIViewController *nextRootViewController = [self nextRootViewController:rootViewController];
    if (nextRootViewController) {
        return [self topViewController:nextRootViewController];
    }

    return rootViewController;
}

+ (UIViewController *)nextRootViewController:(UIViewController *)rootViewController {
    UIViewController *presentedViewController = rootViewController.presentedViewController;
    if (presentedViewController != nil) {
        return presentedViewController;
    }
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *lastViewController = ((UINavigationController *)rootViewController).viewControllers.lastObject;
        return lastViewController;
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        __auto_type *currentTabViewController = ((UITabBarController*)rootViewController).selectedViewController;
        if (currentTabViewController != nil) {
            return currentTabViewController;
        }
    }
    return nil;
}

-(NSString*)getScreenName:(UIViewController *)viewController {
    NSString *name = [[[viewController class] description] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
    if (!name || name.length == 0) {
        name = [viewController title];
        if (name.length == 0) {
            name = @"Unknown";
        }
    }
    return name;
}

- (void)logged_viewWillDisappear:(BOOL)animated {
  @try {
    
    UIViewController *top = [[self class] getRootViewControllerFromView:self.view];
    
    if (!top) {
      return;
    }
    
    [self logged_viewWillDisappear:animated];
    [BOSharedManager sharedInstance].isViewDidAppeared = NO;
    
    if ([BlotoutAnalytics sharedInstance].eventManager == nil) {
      return;
    }
    
    NSString *screen = [self getScreenName:top];
    
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_VISIBILITY_HIDDEN properties:nil eventCode:@(BO_EVENT_VISIBILITY_HIDDEN) screenName:screen withType:BO_SYSTEM];
      [[BlotoutAnalytics sharedInstance].eventManager capture:model];
    }];
    
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}

- (void)logged_viewDidAppear:(BOOL)animated {
  @try {
    
    UIViewController *top = [[self class] getRootViewControllerFromView:self.view];
    
    if (!top) {
      return;
    }
    
    [self logged_viewDidAppear:animated];
    
    if ([BOSharedManager sharedInstance].isViewDidAppeared) {
      return;
    }
    
    [BOSharedManager sharedInstance].isViewDidAppeared = YES;
    
    if ([BlotoutAnalytics sharedInstance].eventManager == nil) {
      return;
    }
    
    NSString *screenName = [self getScreenName:top];
    [BOSharedManager sharedInstance].currentScreenName = screenName;
   
    [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
      BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:BO_SDK_START properties:nil eventCode:@(BO_EVENT_SDK_START) screenName:screenName withType:BO_SYSTEM];
      [[BlotoutAnalytics sharedInstance].eventManager capture:model];
    }];
    
  } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
}
@end
