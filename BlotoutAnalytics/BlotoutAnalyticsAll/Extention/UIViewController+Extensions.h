//
//  UIViewController+ExtensionsViewController.h
//  BlotoutAnalytics
//
//  Created by Blotout on 30/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <UIKit/UIKit.h>

extern void loadAsUIViewControllerBOFoundationCat(void);

@interface UIViewController (Extensions)
+ (void)load;
+ (UIViewController *)getTopmostViewController;
+ (UIViewController *)topmostViewController:(UIViewController *)rootViewController;
- (void)logged_viewDidAppear:(BOOL)animated;
- (NSTimer *)createTimer;
- (void)timerTicked:(NSTimer *)timer;


@end
