//
//  UIApplication+Extensions.m
//  BlotOutSdk
//
//  Created by itru on 4/13/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "UIApplication+Extensions.h"
#import <objc/runtime.h>
#import "BOAppSessionData.h"
#import "BOSharedManager.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"


void loadAsUIApplicationBOFoundationCat(void){
    
}

@implementation UIApplication (Extensions)

+ (void)load {
    
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        SEL sendEventSelector = @selector(sendEvent:);
        SEL sendEventLoggerSelector = @selector(logged_sendEvent:);
        Method originalMethod = class_getInstanceMethod(self, sendEventSelector);
        Method extendedMethod = class_getInstanceMethod(self, sendEventLoggerSelector);
        method_exchangeImplementations(originalMethod, extendedMethod);
    });
    
    static dispatch_once_t once_token1;
    dispatch_once(&once_token1,  ^{
        SEL sendEventSelector = @selector(sendAction:to:from:forEvent:);
        SEL sendEventLoggerSelector = @selector(logged_sendAction:to:from:forEvent:);
        Method originalMethod = class_getInstanceMethod(self, sendEventSelector);
        Method extendedMethod = class_getInstanceMethod(self, sendEventLoggerSelector);
        method_exchangeImplementations(originalMethod, extendedMethod);
    });
    
}

- (void)logged_sendEvent:(UIEvent*)event {
    @try {
        [self logged_sendEvent:event];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void)logged_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    @try {
        UIResponder *responder = (UIResponder*)sender;
        
        BOSharedManager *extentionManager = [BOSharedManager sharedInstance];
        
        
        if([responder isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)responder;
            if(extentionManager.currentNavigation != nil) {
                extentionManager.currentNavigation.actionObjectTitle = button.titleLabel.text;
                extentionManager.currentNavigation.action = NSStringFromSelector(action);
                extentionManager.currentNavigation.actionTime = [BOAUtilities get13DigitNumberObjTimeStamp];
                extentionManager.currentNavigation.actionObject = [UIButton description];
            }
            
        } else if([responder isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell*)responder;
            if(extentionManager.currentNavigation != nil) {
                extentionManager.currentNavigation.actionObjectTitle = cell.textLabel.text;
                extentionManager.currentNavigation.action = NSStringFromSelector(action);
                extentionManager.currentNavigation.actionTime = [BOAUtilities get13DigitNumberObjTimeStamp];
                extentionManager.currentNavigation.actionObject = [UITableViewCell description];
            }
        } else if([responder isKindOfClass:[UITabBarItem class]]) {
            UITabBarItem *tabBarItem = (UITabBarItem*)responder;
            if(extentionManager.currentNavigation != nil) {
                extentionManager.currentNavigation.actionObjectTitle = tabBarItem.title;
                extentionManager.currentNavigation.action = NSStringFromSelector(action);
                extentionManager.currentNavigation.actionTime = [BOAUtilities get13DigitNumberObjTimeStamp];
                extentionManager.currentNavigation.actionObject = [UITabBarItem description];
            }
        }
        
        [self logged_sendAction:action to:target from:sender forEvent:event];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}



@end
