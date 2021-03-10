/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The "Favorites" view controller. 
 */

#import "FavoritesViewController.h"

@interface FavoritesViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

#pragma mark -

@implementation FavoritesViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If we were navigated to through the More screen table, then we have a navigation bar which
    // also means we have a title.  So hide the title label in this case, otherwise, we need it.
    //
    self.titleLabel.hidden = [self.parentViewController isKindOfClass:[UINavigationController class]] ? YES : NO;
}

@end
