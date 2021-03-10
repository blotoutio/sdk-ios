/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The view controller for page three. 
 */

#import "ThreeViewController.h"
#import <BlotoutAnalytics/BlotoutAnalytics.h>

NSString *kBadgeValuePrefKey = @"kBadgeValue";  // badge value key for storing to NSUserDefaults

@interface ThreeViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UITextField *badgeField;

- (void)doneAction:(id)sender;

@end

#pragma mark -

@implementation ThreeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the badge value in our test field and tabbar item.
    NSString *badgeValue = [[NSUserDefaults standardUserDefaults] stringForKey:kBadgeValuePrefKey];
    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    if (badgeValue.length != 0)
    {
        self.badgeField.text = badgeValue;
        self.navigationController.tabBarItem.badgeValue = self.badgeField.text;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [[BlotoutAnalytics sharedInstance] logEvent:@"BOSDK ThreeViewController test Event" withInformation:@{}];
}

- (void)doneAction:(id)sender
{
    // Dismiss the keyboard by resigning our badge edit field as first responder.
    [self.badgeField resignFirstResponder];
    
    // Set the badge value to our tab item (but only if a valid string).
    if (self.badgeField.text.length > 0)
    {
        // A value was entered, because we are inside a navigation controller,
        // we must access its tabBarItem to set the badgeValue.
        self.navigationController.tabBarItem.badgeValue = self.badgeField.text;
    }
    else
    {
        // No value was entered.
        self.navigationController.tabBarItem.badgeValue = nil;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:self.badgeField.text forKey:kBadgeValuePrefKey];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // user is starting to edit, add the done button to the navigation bar
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    /// user is done editing, remove the done button from the navigation bar
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = YES;
    
    // restrict the maximum number of characters to 5
    if (textField.text.length == 5 && string.length > 0)
        result = NO;
    
    return result;
}
- (IBAction)DevSwipeUPTest:(id)sender {
    
    [[BlotoutAnalytics sharedInstance] logEvent:@"swipeUp" withInformation:@{}];
}

- (IBAction)touchClickEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"touchClick" withInformation:@{}];
}

- (IBAction)dragEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"drag" withInformation:@{}];
}

- (IBAction)flickEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"flick" withInformation:@{}];
}

- (IBAction)doubleTap:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"doubleTap" withInformation:@{}];
}

- (IBAction)twoFingerTap:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"twoFingerTap" withInformation:@{}];
}

- (IBAction)pinchEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"pinch" withInformation:@{}];
}

- (IBAction)touchAndHoldEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"touchAndHold" withInformation:@{}];
}

- (IBAction)shakeEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"shake" withInformation:@{}];
}

- (IBAction)screenEdgePanEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"screenEdgePan" withInformation:@{}];
}
// Add one more button for view and other after listing on server
//[[BlotoutAnalytics sharedInstance] logEvent:@"view" withInformation:@{}];

- (IBAction)addToCartEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"Add To Cart" withInformation:@{}];
}

- (IBAction)chargeTransactionEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"chargeTransaction" withInformation:@{}];
}

- (IBAction)listUpdatedEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"listUpdated" withInformation:@{}];
}

- (IBAction)customEvent:(id)sender {
    [[BlotoutAnalytics sharedInstance] logEvent:@"Test Custom Event" withInformation:@{}];
}

@end

