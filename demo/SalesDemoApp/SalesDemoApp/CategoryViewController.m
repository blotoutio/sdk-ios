//
//  ViewController.m
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "CategoryViewController.h"
#import "eBayAPI.h"
#import "ListItemViewController.h"
#import "ListItemCartViewController.h"
#import <BlotoutAnalytics/BlotoutAnalytics.h>

#define kFontName            @"Helvetica Neue"
#define    kFontSize            16.0


@interface CategoryViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (retain,nonatomic) NSArray *catagoryArray;
@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *pImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"windows-shopper.png"]];
    self.navigationItem.titleView = pImageView;
    [[BlotoutAnalytics sharedInstance] capture:@"CategoryView" withInformation:nil];
    if (self.categoryID <= 0) {
        eBayAPI *api = [[eBayAPI alloc] init];
        [api getCategoryInfoWithsuccess:^(id  _Nonnull responseObject) {
            //Ashish filterning Art as it contain 18+ content and should be avoided
            //TODO: filter all such object while testing & implete at root for everywhere
            NSMutableArray *responseMutable = [(NSArray*)responseObject mutableCopy];
            for (NSDictionary *catObj in responseObject) {
                if ([[[catObj objectForKey:@"CategoryName"] lowercaseString] isEqualToString:@"art"]) {
                    [responseMutable removeObject:catObj];
                }
            }
            self.catagoryArray= responseMutable;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.categoryTableView reloadData];
            });
            
        } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
            
        }];
    } else {
        
        eBayAPI *api = [[eBayAPI alloc] init];
        [api getSubCategoriesInfoWithCategoryID:self.categoryID Withsuccess:^(id  _Nonnull responseObject) {
            
            self.catagoryArray= responseObject;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.categoryTableView reloadData];
            });
            
        } failure:^(NSURLResponse * _Nonnull urlResponse, id  _Nonnull dataOrLocation, NSError * _Nonnull error) {
            
        }];
    }
    
    UIBarButtonItem *btnCartView = [[UIBarButtonItem alloc] initWithTitle:@"View Cart" style:UIBarButtonItemStylePlain target:self action:@selector(btnCartPressed:)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = btnCartView;
}

-(void)btnCartPressed:(id)sender{
    
    ListItemCartViewController *cartVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ListItemCartViewController"];
    //Ashish
    [[BlotoutAnalytics sharedInstance] capture:@"View Cart Clicked" withInformation:@{@"time":[NSDate date], @"VC Name":@"CategoryViewVC"}];
    [self.navigationController pushViewController:cartVC animated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.catagoryArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSMutableDictionary *dict=[self.catagoryArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"CategoryName"];
    cell.textLabel.font = [UIFont fontWithName:kFontName size:kFontSize];
    cell.accessoryView.backgroundColor = [UIColor blackColor];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSDictionary *dict=[self.catagoryArray objectAtIndex:indexPath.row];
    NSString *status=[dict objectForKey:@"LeafCategory"];
    if ([status isEqualToString:@"false"]) {
        CategoryViewController *categoryListController = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryViewController"];
        
        categoryListController.categoryID=[[dict objectForKey:@"CategoryID"]longLongValue];
        categoryListController.title = [dict valueForKey:@"CategoryName"];
        
        [[BlotoutAnalytics sharedInstance] capture:@"Category Selected" withInformation:@{@"time":[NSDate date], @"Item Name":[dict objectForKey:@"CategoryName"]}];
        
        [self.navigationController pushViewController:categoryListController animated:YES];
        
    }
    else {
        
        ListItemViewController *itemListController = [self.storyboard instantiateViewControllerWithIdentifier:@"ListItemViewController"];
        
        itemListController.queryString=[dict objectForKey:@"CategoryName"];
        itemListController.title = [dict valueForKey:@"CategoryName"];
        
        [self.navigationController pushViewController:itemListController animated:YES];
        
    }
}


@end
