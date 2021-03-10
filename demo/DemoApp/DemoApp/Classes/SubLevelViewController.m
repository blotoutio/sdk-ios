/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The view controller for sublevel 2. 
 */

#import "SubLevelViewController.h"
#import "ModalViewController.h"

@interface SubLevelViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) ModalViewController *myModalViewController;

@end

#pragma mark -

@implementation SubLevelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dataArray = @[@"Feature 1", @"Feature 2"];
}

#pragma mark - UITableViewDelegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"modalSegue"])
    {
        ModalViewController *myModalViewController1 = segue.destinationViewController;
        myModalViewController1.owningViewController = self;
        UITableViewCell *cell = sender;
        self.currentSelectionTitle = cell.textLabel.text;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID2 = @"cellID2";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID2];
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (IBAction)unwindToSub:(UIStoryboardSegue *)unwindSegue
{ }

@end
