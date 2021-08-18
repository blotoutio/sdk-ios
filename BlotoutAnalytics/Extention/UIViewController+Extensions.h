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
- (void)logged_viewDidAppear:(BOOL)animated;
- (void)logged_viewWillDisappear:(BOOL)animated;

@end
