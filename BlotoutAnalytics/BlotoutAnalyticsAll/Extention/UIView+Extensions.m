//
//  UIApplication+Extensions.m
//  BlotOutSdk
//
//  Created by itru on 4/13/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "UIView+Extensions.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "BOAppSessionData.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

void loadAsAVPlayerBOFoundationCat(void){
    
}

@implementation UIView (Extensions)

+ (void)load {
    static dispatch_once_t once_token2;
    dispatch_once(&once_token2,  ^{
        SEL sendEventSelector = @selector(gestureRecognizerShouldBegin:);
        SEL sendEventLoggerSelector = @selector(loggedgestureRecognizerShouldBegin:);
        Method originalMethod = class_getInstanceMethod(self, sendEventSelector);
        Method extendedMethod = class_getInstanceMethod(self, sendEventLoggerSelector);
        method_exchangeImplementations(originalMethod, extendedMethod);
    });
}

- (BOOL)loggedgestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    @try {
        [self loggedgestureRecognizerShouldBegin:gestureRecognizer];
        
        BOAppSessionData *appSessionData = [BOAppSessionData sharedInstanceFromJSONDictionary:nil];
        
        
        if([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            //BOFLogDebug(@"UILongPressGestureRecognizer");
            NSMutableArray *array =  [appSessionData.singleDaySessions.ubiAutoDetected.appGesture.touchAndHold mutableCopy];
            
            BODoubleTap *doubleTap = [[BODoubleTap alloc] init];
            doubleTap.timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            doubleTap.objectType = @"UILongPressGestureRecognizer";
            UIViewController *viewController = (UIViewController*)[self traverseResponderChainForUIViewController];
            doubleTap.visibleClassName = viewController != nil ? [viewController description] : @"";
            [array addObject:doubleTap];
            
            appSessionData.singleDaySessions.ubiAutoDetected.appGesture.touchAndHold = array;
            
        } else if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            //BOFLogDebug(@"UITapGestureRecognizer");
            NSMutableArray *array =  [appSessionData.singleDaySessions.ubiAutoDetected.appGesture.doubleTap mutableCopy];
            
            BODoubleTap *doubleTap = [[BODoubleTap alloc] init];
            doubleTap.timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            doubleTap.objectType = @"UITapGestureRecognizer";
            UIViewController *viewController = (UIViewController*)[self traverseResponderChainForUIViewController];
            doubleTap.visibleClassName = viewController != nil ? [viewController description] : @"";
            [array addObject:doubleTap];
            
            appSessionData.singleDaySessions.ubiAutoDetected.appGesture.doubleTap = array;
            
        }else if([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
            //BOFLogDebug(@"UIPinchGestureRecognizer");
            NSMutableArray *array =  [appSessionData.singleDaySessions.ubiAutoDetected.appGesture.pinch mutableCopy];
            
            
            BODoubleTap *doubleTap = [[BODoubleTap alloc] init];
            doubleTap.timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            doubleTap.objectType = @"UIPinchGestureRecognizer";
            UIViewController *viewController = (UIViewController*)[self traverseResponderChainForUIViewController];
            doubleTap.visibleClassName = viewController != nil ? [viewController description] : @"";
            [array addObject:doubleTap];
            
            appSessionData.singleDaySessions.ubiAutoDetected.appGesture.pinch = array;
            
        }else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            //BOFLogDebug(@"UIPanGestureRecognizer");
            NSMutableArray *array =  [appSessionData.singleDaySessions.ubiAutoDetected.appGesture.moreThanTwoFingerTap mutableCopy];
            
            BODoubleTap *doubleTap = [[BODoubleTap alloc] init];
            doubleTap.timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            doubleTap.objectType = @"UIPanGestureRecognizer";
            UIViewController *viewController = (UIViewController*)[self traverseResponderChainForUIViewController];
            doubleTap.visibleClassName = viewController != nil ? [viewController description] : @"";
            [array addObject:doubleTap];
            
            appSessionData.singleDaySessions.ubiAutoDetected.appGesture.moreThanTwoFingerTap = array;
            
        }else if([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
            //BOFLogDebug(@"UISwipeGestureRecognizer");
            NSMutableArray *array =  [appSessionData.singleDaySessions.ubiAutoDetected.appGesture.swipe mutableCopy];
            
            BODoubleTap *doubleTap = [[BODoubleTap alloc] init];
            doubleTap.timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            doubleTap.objectType = @"UISwipeGestureRecognizer";
            UIViewController *viewController = (UIViewController*)[self traverseResponderChainForUIViewController];
            doubleTap.visibleClassName = viewController != nil ? [viewController description] : @"";
            [array addObject:doubleTap];
            
            appSessionData.singleDaySessions.ubiAutoDetected.appGesture.swipe = array;
            
        }else if([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
            //BOFLogDebug(@"UIRotationGestureRecognizer");
            NSMutableArray *array =  [appSessionData.singleDaySessions.ubiAutoDetected.appGesture.rotate mutableCopy];
            
            BODoubleTap *doubleTap = [[BODoubleTap alloc] init];
            doubleTap.timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            doubleTap.objectType = @"UIRotationGestureRecognizer";
            UIViewController *viewController = (UIViewController*)[self traverseResponderChainForUIViewController];
            doubleTap.visibleClassName = viewController != nil ? [viewController description] : @"";
            [array addObject:doubleTap];
            
            appSessionData.singleDaySessions.ubiAutoDetected.appGesture.rotate = array;
            
        }else if([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            //BOFLogDebug(@"UIScreenEdgePanGestureRecognizer");
            NSMutableArray *array =  [appSessionData.singleDaySessions.ubiAutoDetected.appGesture.screenEdgePan mutableCopy];
            
            BODoubleTap *doubleTap = [[BODoubleTap alloc] init];
            doubleTap.timeStamp = [BOAUtilities get13DigitNumberObjTimeStamp];
            doubleTap.objectType = @"UIScreenEdgePanGestureRecognizer";
            UIViewController *viewController = (UIViewController*)[self traverseResponderChainForUIViewController];
            doubleTap.visibleClassName = viewController != nil ? [viewController description] : @"";
            [array addObject:doubleTap];
            
            appSessionData.singleDaySessions.ubiAutoDetected.appGesture.screenEdgePan = array;
            
        } else {
            //BOFLogDebug(@"%@",[gestureRecognizer description]);
        }
        
        return YES;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

- (id) traverseResponderChainForUIViewController {
    @try {
        id nextResponder = [self nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return nextResponder;
        } else if ([nextResponder isKindOfClass:[UIView class]]) {
            return [nextResponder traverseResponderChainForUIViewController];
        } else {
            return nil;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@end
