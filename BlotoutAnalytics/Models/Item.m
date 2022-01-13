//
//  Item.m
//  BlotoutAnalyticsSDK
//
//  Created by Nitin Choudhary on 28/11/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "Item.h"

@implementation Item

-(instancetype)init
{
    self = [super init];
    self.item_sku = @"";
    self.item_name = @"";
    self.item_price = [NSNumber numberWithInt:0];
    self.item_category = @[];
    self.item_currency = @"";
    self.item_quantity = [NSNumber numberWithInt:0];
    
    return self;
}

@end
