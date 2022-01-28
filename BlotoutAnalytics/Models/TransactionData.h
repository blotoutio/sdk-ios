//
//  TransactionData.h
//  BlotoutAnalyticsSDK
//
//  Created by Nitin Choudhary on 28/11/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransactionData : NSObject

@property (nonatomic, strong, nonnull)  NSString *transaction_id; //Required Parameter

@property (nonatomic, strong, nullable) NSString *transaction_currency;

@property (nonatomic, strong,nullable)  NSNumber *transaction_total;

@property (nonatomic, strong,nullable)  NSNumber *transaction_discount;

@property (nonatomic, strong,nullable)  NSNumber *transaction_shipping;

@property (nonatomic, strong, nullable) NSNumber *transaction_tax;

@end

NS_ASSUME_NONNULL_END
