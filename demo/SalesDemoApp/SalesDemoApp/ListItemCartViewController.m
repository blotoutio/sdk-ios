//
//  ListItemViewController.m
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "ListItemCartViewController.h"
#import "eBayAPI.h"
#import "ItemViewCell.h"
#import "MXScrollViewController.h"
@import BlotoutAnalyticsSDK;

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define kFontName            @"Helvetica Neue"
#define    kFontSize            16.0


@interface ListItemCartViewController ()

@property (retain,nonatomic) NSArray *itemArray;

@property (weak, nonatomic) IBOutlet UITableView *itemTableView;

@end

@implementation ListItemCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *pImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"windows-shopper.png"]];
    self.navigationItem.titleView = pImageView;
    
    // Do any additional setup after loading the view.
    NSUserDefaults *userDefauts = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [userDefauts valueForKey:@"CartData"];
    NSMutableArray *array =[NSMutableArray array];
    for (NSString *key in [dictionary allKeys]) {
        [array addObject:[dictionary valueForKey:key]];
    }
    [[BlotoutAnalytics sharedInstance] capture:@"List Item Cart View" withInformation:nil];
    self.itemArray = array;
    UIBarButtonItem *btnCartView = [[UIBarButtonItem alloc] initWithTitle:@"Buy" style:UIBarButtonItemStylePlain target:self action:@selector(btnCartPressed:)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = btnCartView;
}

-(void)btnCartPressed:(id)sender{
    
    NSUserDefaults *userDefauts = [NSUserDefaults standardUserDefaults];
    [userDefauts setValue:@{} forKey:@"CartData"];
    
    self.itemArray = nil;
    [self.itemTableView reloadData];
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"B-Commerce" message:@"Thank you for Shooping, All items will be deliver to \"Home Address\"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [alertView addAction:action];
    
    [self presentViewController:alertView animated:YES completion:^{
        //Ashish
        [[BlotoutAnalytics sharedInstance] capture:@"Purchase Complete" withInformation:nil];
    }];
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
        
        NSDictionary* pItemDict  = [responseObject objectAtIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            MXScrollViewController *itemListController = [self.storyboard instantiateViewControllerWithIdentifier:@"MXScrollViewController"];
            itemListController.itemDict = pItemDict;
            itemListController.isCartView = YES;
            [self.navigationController pushViewController:itemListController animated:YES];
            
        });
        
    } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
        
    }];
}

@end
