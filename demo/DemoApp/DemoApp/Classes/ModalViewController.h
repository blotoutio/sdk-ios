/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The modal view controller for temporary UI interaction.
 */

@import UIKit;

@class SubLevelViewController;

@interface ModalViewController : UIViewController

@property (nonatomic, strong) SubLevelViewController *owningViewController;

@end
