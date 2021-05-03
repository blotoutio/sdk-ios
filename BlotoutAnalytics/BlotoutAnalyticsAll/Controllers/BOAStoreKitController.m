//
//  BOADeviceAndAppFraudController.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAStoreKitController.h"
#import "BlotoutAnalytics_Internal.h"
#import "BOSharedManager.h"
#import "BOANetworkConstants.h"
#import "BOEventsOperationExecutor.h"

@interface BOAStoreKitController ()

@property (nonatomic, readonly) NSMutableDictionary *transactions;
@property (nonatomic, readonly) NSMutableDictionary *productRequests;
@property (nonatomic, readonly) BlotoutAnalyticsConfiguration *config;

@end

@implementation BOAStoreKitController

+ (instancetype)trackTransactionsForConfiguration:(BlotoutAnalyticsConfiguration*)configuration {
  return [[BOAStoreKitController alloc] initWithConfiguration:configuration];
}

- (instancetype)initWithConfiguration:(BlotoutAnalyticsConfiguration*)configuration {
  if (self = [self init]) {
    _config = configuration;
    _productRequests = [NSMutableDictionary dictionaryWithCapacity:1];
    _transactions = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  }
  
  return self;
}

- (void)dealloc {
  [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - SKPaymentQueue Observer
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    if (transaction.transactionState != SKPaymentTransactionStatePurchased) {
      continue;
    }
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:transaction.payment.productIdentifier]];
    @synchronized(self)
    {
      [self.transactions setObject:transaction forKey:transaction.payment.productIdentifier];
      [self.productRequests setObject:request forKey:transaction.payment.productIdentifier];
    }
    request.delegate = self;
    [request start];
  }
}

#pragma mark - SKProductsRequest delegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
  for (SKProduct *product in response.products) {
    @synchronized(self)
    {
      SKPaymentTransaction *transaction = [self.transactions objectForKey:product.productIdentifier];
      [self trackTransaction:transaction forProduct:product];
      [self.transactions removeObjectForKey:product.productIdentifier];
      [self.productRequests removeObjectForKey:product.productIdentifier];
    }
  }
}

#pragma mark - Track
- (void)trackTransaction:(SKPaymentTransaction *)transaction forProduct:(SKProduct *)product {
  if (transaction.transactionIdentifier == nil || [BlotoutAnalytics sharedInstance].eventManager == nil) {
    return;
  }
  
  NSString *currency = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
  [[BOEventsOperationExecutor sharedInstance] dispatchEventsInBackground:^{
    
    BOACaptureModel *model = [[BOACaptureModel alloc] initWithEvent:@"Transaction Completed" properties:@{
      @"orderId" : transaction.transactionIdentifier,
      @"affiliation" : @"App Store",
      @"currency" : currency ?: @"",
      @"products" : @[
          @{
            @"sku" : transaction.transactionIdentifier,
            @"quantity" : @(transaction.payment.quantity),
            @"productId" : product.productIdentifier ?: @"",
            @"price" : product.price ?: @0,
            @"name" : product.localizedTitle ?: @"",
          }
      ]
    } eventCode:@(BO_TRANSACTION_COMPLETED) screenName:[BOSharedManager sharedInstance].currentScreenName withType:BO_SYSTEM];
    [[BlotoutAnalytics sharedInstance].eventManager capture:model];
  }];
}

@end
