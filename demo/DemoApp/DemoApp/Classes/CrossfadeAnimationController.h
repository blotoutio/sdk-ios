/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Animator between the two view controllers by performing a simple cross-fade.
 */

@import UIKit;

@interface CrossfadeAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) NSTimeInterval duration;

// The direction of the animation.
@property (nonatomic, assign) BOOL reverse;

@end
