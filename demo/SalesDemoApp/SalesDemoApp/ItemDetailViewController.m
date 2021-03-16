//
//  ItemDetailViewController.m
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "ListItemCartViewController.h"
#import <BlotoutAnalytics/BlotoutAnalytics.h>

@interface ItemDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipToLocation;
@property (weak, nonatomic) IBOutlet UILabel *bidTime;

@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UILabel *locationlable;
@property (weak, nonatomic) IBOutlet UIButton *addToCartAction;
@property (weak, nonatomic) IBOutlet UILabel *conditionDisplay;
@end

@implementation ItemDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[BlotoutAnalytics sharedInstance] capture:@"Item Detail View" withInformation:nil];
    if(dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMM yyyy hh:mm:ss"];
    }
    
    if(dateComps == nil)
        dateComps = [[NSDateComponents alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.isCartView) {
        self.addToCartAction.hidden = YES;
    }
    
    self.conditionDisplay.text        = [NSString stringWithFormat:@"Condition :  %@",[self.itemDict valueForKey:@"ConditionDisplayName"]];
    self.locationlable.text        = [NSString stringWithFormat:@"Location :  %@", [self.itemDict valueForKey:@"Location"]];
    self.titleLabel.text            = [self.itemDict valueForKey:@"Title"];
    self.shipToLocation.text            = [NSString stringWithFormat:@"ShipToLocations :  %@", [self.itemDict valueForKey:@"ShipToLocations"]];
    self.bidTime.text        = [NSString stringWithFormat:@"Start Time :  %@",[self.itemDict valueForKey:@"StartTime"]];
    self.endTime.text                = [NSString stringWithFormat:@"End Time :  %@",[self getTimeDetails:[self.itemDict valueForKey:@"EndTime"]]];
    
}

-(NSString*) getTimeDetails:(NSString*)dateString{
    // [NSString stringWithFormat:@"%@",[[dictionary objectForKey:@"created_at"] description]];
    
    NSString *dateStr = dateString;
    NSArray *dateCompArray = [dateStr componentsSeparatedByString:@"T"];
    
    
    NSArray *timeCompArray = [[dateCompArray objectAtIndex:1] componentsSeparatedByString:@":"];
    [dateComps setHour:[[timeCompArray objectAtIndex:0] intValue]];
    [dateComps setMinute:[[timeCompArray objectAtIndex:1] intValue]];
    [dateComps setSecond:[[timeCompArray objectAtIndex:2] intValue]];
    
    NSArray *dateArray = [[dateCompArray objectAtIndex:0] componentsSeparatedByString:@"-"];
    
    [dateComps setYear:[[dateArray objectAtIndex:0] intValue]];
    [dateComps setMonth:[[dateArray objectAtIndex:1] intValue]];
    [dateComps setDay:[[dateArray objectAtIndex:2] intValue]];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *date = [gregorian dateFromComponents:dateComps];
    return [dateFormatter stringFromDate:date];
    
}

- (IBAction)addToCartAction:(id)sender {
    NSUserDefaults *userDefauts = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *cartDict;
    NSDictionary *dictionary =[userDefauts valueForKey:@"CartData"];
    if(dictionary == nil) {
        cartDict  = [NSMutableDictionary dictionary];
        [cartDict setValue:self.itemDict forKey:self.itemID];
    } else {
        cartDict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        [cartDict setValue:self.itemDict forKey:self.itemID];
    }
    
    //Sales App Segment & Campaign Testing
    [[BlotoutAnalytics sharedInstance] capture:@"Add To Cart" withInformation:@{
        @"item" :@"iPhone",
        @"color":@"green"
        //@"itemID":self.itemID,
        //@"itemInfo":self.itemDict
    }];
    
    [[BlotoutAnalytics sharedInstance] capture:@"myCart" withInformation:@{
        @"addedToCart":@"iPhone",
        @"color":@"green"
    }];
    
    [[BlotoutAnalytics sharedInstance] capture:@"InCart" withInformation:@{
        @"product":@"iPhone",
        @"color":@"green"
        //@"itemID":self.itemID,
        //@"itemInfo":self.itemDict
    }];
    
    [userDefauts setValue:cartDict forKey:@"CartData"];
    [userDefauts synchronize];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
