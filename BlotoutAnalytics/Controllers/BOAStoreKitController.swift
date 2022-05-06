//
//  BOAStoreKitController.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 23/03/22.
//

import Foundation
import StoreKit

class BOAStoreKitController:NSObject, SKProductsRequestDelegate,SKPaymentTransactionObserver {
    private var transactions: [AnyHashable : Any]?
    private var productRequests: [AnyHashable : Any]?
    private var config: BlotoutAnalyticsConfiguration?
    
    
    class func trackTransactions(for configuration: BlotoutAnalyticsConfiguration?) -> Self {
        return BOAStoreKitController(configuration: configuration) as! Self
       }
    
    
    convenience init(configuration: BlotoutAnalyticsConfiguration?) {
        self.init()
            config = configuration
            productRequests = [AnyHashable : Any](minimumCapacity: 1)
            transactions = [AnyHashable : Any](minimumCapacity: 1)

        SKPaymentQueue.default().add(self as! SKPaymentTransactionObserver)
    }
    
//    deinit {
//        SKPaymentQueue.default().removeTransactionObserver(self)
//    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState != .purchased {
                continue
            }

            let request = SKProductsRequest(productIdentifiers: Set<String>([transaction.payment.productIdentifier]))
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                //TODO: check types in models
                
                let transactionKey:String = transaction.payment.productIdentifier
                self.transactions?[transactionKey] = transaction
               // transactions[transaction.payment.productIdentifier] = transactionObj
                productRequests?[transaction.payment.productIdentifier] = request
            }
            request.delegate = self
            request.start()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                if let transaction = transactions?[product.productIdentifier] as? SKPaymentTransaction
                {
                    trackTransaction(transaction, for: product)
                transactions?.removeValue(forKey: product.productIdentifier)
                productRequests?.removeValue(forKey: product.productIdentifier)
                }
                //TODO: test this condition
            }
        }
    }
    
    func trackTransaction(_ transaction: SKPaymentTransaction, for product: SKProduct) {
        let sdkManifesCtrl = BOASDKManifestController.sharedInstance
        if !sdkManifesCtrl.isSystemEventEnabled(BO_TRANSACTION_COMPLETED) {
            return
        }

        if transaction.transactionIdentifier == nil || BlotoutAnalytics.sharedInstance.eventManager == nil {
            return
        }
        
        let currency = product.priceLocale.currencyCode

        BOEventsOperationExecutor.sharedInstance.dispatchEvents(inBackground: {

//TODO: need to set default empty values in productDict
            let productDict = [
                "sku" : transaction.transactionIdentifier,
                "quantity" : transaction.payment.quantity,
                "productId" : product.productIdentifier ,
                "price" : product.price ,
                "name" : product.localizedTitle ,
            ] as [String : AnyHashable]
            let model = BOACaptureModel(
                event: "Transaction Completed",
                properties: [
                    "orderId": transaction.transactionIdentifier,
                    "affiliation": "App Store",
                    "currency": currency ?? "",
                    "products" : [productDict]
                ],
                screenName: BOSharedManager.sharedInstance.currentScreenName,
                withType: BO_SYSTEM)
            BlotoutAnalytics.sharedInstance.eventManager.capture(model)
        })
    }
}
