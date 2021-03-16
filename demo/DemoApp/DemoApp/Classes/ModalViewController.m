/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The modal view controller for temporary UI interaction. 
 */

#import "ModalViewController.h"
#import "SubLevelViewController.h"
#import <BlotoutAnalytics/BlotoutAnalytics.h>

@interface ModalViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

#pragma mark -

@implementation ModalViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.owningViewController.currentSelectionTitle;
    [[BlotoutAnalytics sharedInstance] capture:@"BOSDK ModalViewController test Event" withInformation:@{}];
}

@end

