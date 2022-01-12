//
//  BOAItem.h
//  BlotoutAnalyticsSDK
//
//  Created by Nitin Choudhary on 28/11/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOAItem : NSObject

@property (nonatomic, strong, nonnull) NSString *item_id;

@property (nonatomic, strong, nullable) NSString *item_name;

@property (nonatomic, strong, nullable) NSString *item_sku;

@property (nonatomic, strong, nullable) NSDictionary *item_category;

@property (nonatomic, assign, nullable) int *item_price;

@property (nonatomic, strong, nullable) NSString *item_currency;

@property (nonatomic, assign, nullable) int *item_quantity;
@end

NS_ASSUME_NONNULL_END

