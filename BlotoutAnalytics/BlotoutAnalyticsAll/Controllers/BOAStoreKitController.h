//
//  BOADeviceAndAppFraudController.h
//  BlotoutAnalytics
//
//  Created by AnKur dhikari on 30/03/21.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "BlotoutAnalyticsConfiguration.h"

@interface BOAStoreKitController : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

+ (instancetype)trackTransactionsForConfiguration:(BlotoutAnalyticsConfiguration*)configuration;

@end
