//
//  BOAStoreKitController.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 23/03/22.
//

import Foundation


class BOAStoreKitController {
    private var transactions: [AnyHashable : Any]?
    private var productRequests: [AnyHashable : Any]?
    private var config: BlotoutAnalyticsConfiguration?
    
    
    class func trackTransactions(for configuration: BlotoutAnalyticsConfiguration?) -> Self {
           return BOAStoreKitController(configuration: configuration)
       }
    
    
    convenience init(configuration: BlotoutAnalyticsConfiguration?) {
        self.init()
            config = configuration
            productRequests = [AnyHashable : Any](minimumCapacity: 1)
            transactions = [AnyHashable : Any](minimumCapacity: 1)

            SKPaymentQueue.default().addTransactionObserver(self)
    }
    
//    deinit {
//        SKPaymentQueue.default().removeTransactionObserver(self)
//    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState != .purchased {
                continue
            }

            let request = SKProductsRequest(productIdentifiers: Set<AnyHashable>([transaction.payment.productIdentifier]))
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                transactions.setObject(transaction, forKey: transaction.payment.productIdentifier)
                productRequests.setObject(request, forKey: transaction.payment.productIdentifier)
            }
            request.delegate = self
            request.start()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                let transaction = transactions[product.productIdentifier] as? SKPaymentTransaction
                trackTransaction(transaction, for: product)
                transactions.removeObject(forKey: product.productIdentifier)
                productRequests.removeObject(forKey: product.productIdentifier)
            }
        }
    }
    
    func trackTransaction(_ transaction: SKPaymentTransaction?, for product: SKProduct?) {
        let sdkManifesCtrl = BOASDKManifestController.sharedInstance()
        if !sdkManifesCtrl.isSystemEventEnabled(BO_TRANSACTION_COMPLETED) {
            return
        }

        if transaction?.transactionIdentifier == nil || BlotoutAnalytics.sharedInstance().eventManager == nil {
            return
        }

        let currency = product?.priceLocale[NSLocale.Key.currencyCode] as? String

        BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {

            let model = BOACaptureModel(
                event: "Transaction Completed",
                properties: [
                    "orderId": transaction.transactionIdentifier,
                    "affiliation": "App Store",
                    "currency": currency ?? "",
                    "products" : [{
                                "sku" : transaction.transactionIdentifier,
                                "quantity" : @(transaction.payment.quantity),
                                "productId" : product.productIdentifier ?: "",
                                "price" : product.price ?: 0,
                                "name" : product.localizedTitle ?: "",
                              }]
                ],
                screenName: BOSharedManager.sharedInstance().currentScreenName,
                withType: BO_SYSTEM)
            BlotoutAnalytics.sharedInstance().eventManager.capture(model)
        })
    }
}
