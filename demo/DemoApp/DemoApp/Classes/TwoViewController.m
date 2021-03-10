/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The view controller for page two. 
 */

#import "TwoViewController.h"
#import "LandscapeViewController.h"

NSString *kRainbowImageName = @"Rainbow";
NSString *kSunsetImageName = @"Sunset";

@interface TwoViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

#pragma mark -

@implementation TwoViewController

// This is called when its tab is first tapped by the user.

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataArray = @[kRainbowImageName, kSunsetImageName];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"cellIDTwo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LandscapeViewSegue"])
    {
        LandscapeViewController *landscapeViewController = segue.destinationViewController;
        UITableViewCell *cell = sender;
        UIImage *image = nil;
        if ([cell.textLabel.text isEqualToString:kRainbowImageName])
        {
            image = [UIImage imageNamed:kRainbowImageName];
        }
        else if ([cell.textLabel.text isEqualToString:kSunsetImageName])
        {
            image = [UIImage imageNamed:kSunsetImageName];
        }
        landscapeViewController.image = image;
    }
}

@end
