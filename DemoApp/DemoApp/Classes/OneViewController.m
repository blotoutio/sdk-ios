/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The view controller for page one. 
 */

#import "OneViewController.h"
#import "SubLevelViewController.h"
#import <BlotoutAnalytics/BlotoutAnalytics.h>

@interface OneViewController () <UIGestureRecognizerDelegate> {
    UIBarButtonItem *btnLog;
}

@property (nonatomic, strong) NSArray *dataArray;

@end

#pragma mark -

@implementation OneViewController

// This is called when its tab is first tapped by the user.
- (void)viewDidLoad
{
    [super viewDidLoad];
    btnLog = [[UIBarButtonItem alloc] initWithTitle:@"LOG" style:UIBarButtonItemStylePlain target:self action:@selector(btnLogPressed:)];
    _dataArray = @[@"Mac Pro", @"Mac mini", @"iMac", @"MacBook", @"MacBook Pro", @"MacBook Air"];
    //[self registerObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = btnLog;
    
    // This UIViewController is about to re-appear, make sure we remove the current selection in our table view.
    NSIndexPath *tableSelection = self.tableView.indexPathForSelectedRow;
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
    [[BlotoutAnalytics sharedInstance] logEvent:@"oneviewcontroller appeared" withInformation:@{}];
}

-(void)btnLogPressed:(id)sender {
    
    // UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[BOAgent getLogViewController]];
    
    //[self presentViewController:navigationController animated:YES completion:nil];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SubLevelSegue"]) {
        
        SubLevelViewController *mySubLevelViewController = segue.destinationViewController;
        UITableViewCell *cell = sender;
        mySubLevelViewController.title = cell.textLabel.text;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

-(void)registerObserver {
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipe.delegate = self;
    [self.view addGestureRecognizer:swipe];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    return YES;
}


-(void)swipe:(UIGestureRecognizer*)gesture {
    
}

@end
