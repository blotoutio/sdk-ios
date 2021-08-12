//
//  UIViewController+ExtensionsViewController.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

@import UIKit;

extern void loadAsUIViewControllerBOFoundationCat(void);

@interface UIViewController (Extensions) {}
+ (void)load;
+ (UIViewController *)getTopmostViewController;
+ (UIViewController *)topmostViewController:(UIViewController *)rootViewController;

- (void)logged_viewDidAppear:(BOOL)animated;
- (void)logged_viewWillDisappear:(BOOL)animated;

@end
