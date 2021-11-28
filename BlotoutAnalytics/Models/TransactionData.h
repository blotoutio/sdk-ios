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

@property (nonatomic, strong, nonnull) NSString *transaction_id;

@property (nonatomic, strong, nullable) NSString *transaction_currency;

@property (nonatomic, assign,nullable)  double *transaction_total;

@property (nonatomic, assign,nullable)  NSInteger *transaction_discount;

@property (nonatomic, assign,nullable)  NSInteger *transaction_shipping;

@property (nonatomic, assign, nullable)  double *transaction_tax;

@end

NS_ASSUME_NONNULL_END
