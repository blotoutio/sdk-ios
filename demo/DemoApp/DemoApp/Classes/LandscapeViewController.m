/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The application view controller used when the device is in landscape orientation. 
 */

#import "LandscapeViewController.h"

@interface LandscapeViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)actionCompleted:(id)sender;

@end

#pragma mark -

@implementation LandscapeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
}

- (IBAction)actionCompleted:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end

