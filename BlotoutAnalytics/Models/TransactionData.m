//
//  TransactionData.m
//  BlotoutAnalyticsSDK
//
//  Created by Nitin Choudhary on 28/11/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "TransactionData.h"

@implementation TransactionData

-(instancetype)init
{
    self = [super init];
    self.transaction_tax = [NSNumber numberWithInt:0];
    self.transaction_total = [NSNumber numberWithInt:0];
    self.transaction_currency = @"";
    self.transaction_discount = [NSNumber numberWithInt:0];
    self.transaction_shipping = [NSNumber numberWithInt:0];
    
    return self;
}
@end
