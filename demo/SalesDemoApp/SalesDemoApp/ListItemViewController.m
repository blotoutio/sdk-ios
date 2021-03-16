//
//  ListItemViewController.m
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "ListItemViewController.h"
#import "eBayAPI.h"
#import "ItemViewCell.h"
#import "MXScrollViewController.h"
#import "ListItemCartViewController.h"
#import <BlotoutAnalytics/BlotoutAnalytics.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define kFontName            @"Helvetica Neue"
#define    kFontSize            16.0


@interface ListItemViewController ()

@property (retain,nonatomic) NSArray *itemArray;

@property (weak, nonatomic) IBOutlet UITableView *itemTableView;

@end

@implementation ListItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *pImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"windows-shopper.png"]];
    self.navigationItem.titleView = pImageView;
    // Do any additional setup after loading the view.
    eBayAPI *api = [[eBayAPI alloc] init];
    [api findItemsAdvancedInfoWithQueryString:self.queryString Withsuccess:^(id  _Nonnull responseObject) {
        
        self.itemArray= responseObject;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.itemTableView reloadData];
        });
        
    } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
        
    }];
    [[BlotoutAnalytics sharedInstance] capture:@"List Item View" withInformation:nil];
    UIBarButtonItem *btnCartView = [[UIBarButtonItem alloc] initWithTitle:@"View Cart" style:UIBarButtonItemStylePlain target:self action:@selector(btnCartPressed:)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = btnCartView;
}

-(void)btnCartPressed:(id)sender{
    
    ListItemCartViewController *cartVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ListItemCartViewController"];
    //Ashish
    [[BlotoutAnalytics sharedInstance] capture:@"View Cart Clicked" withInformation:@{@"time":[NSDate date], @"VC Name":@"ListItemVC"}];
    [self.navigationController pushViewController:cartVC animated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.itemArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSMutableDictionary *dict=[self.itemArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = [dict objectForKey:@"Title"];
    cell.textLabel.font = [UIFont fontWithName:kFontName size:kFontSize];
    cell.accessoryView.backgroundColor = [UIColor blackColor];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.posterImageView.layer.cornerRadius = 5.0;
    cell.mBidCount.text            =    [NSString stringWithFormat:@"Bids: %@",[dict objectForKey:@"BidCount"]];
    cell.currentPrice.text            =    [NSString stringWithFormat:@"Price: $%@",[dict objectForKey:@"CurrentPrice"]];
    
    __block ItemViewCell *blockCell = cell;
    dispatch_async(kBgQueue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"GalleryURL"]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            blockCell.posterImageView.image = [UIImage imageWithData:imgData];
        });
    });
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict=[self.itemArray objectAtIndex:indexPath.row];
    
    eBayAPI *api = [[eBayAPI alloc] init];
    [api getSingleItemInfoWithQueryString:[[dict objectForKey:@"ItemID"] longLongValue] Withsuccess:^(id  _Nonnull responseObject) {
        
        [[BlotoutAnalytics sharedInstance] capture:@"Item Selected" withInformation:@{@"time":[NSDate date], @"Item Name":[dict objectForKey:@"Title"]}];
        
        NSDictionary* pItemDict  = [responseObject objectAtIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            MXScrollViewController *itemListController = [self.storyboard instantiateViewControllerWithIdentifier:@"MXScrollViewController"];
            itemListController.itemDict = pItemDict;
            [self.navigationController pushViewController:itemListController animated:YES];
            
        });
        
    } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
        
    }];
}

@end
