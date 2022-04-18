//
//  TransactionData.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation

class TransactionData: NSObject {
    
    var transaction_id = "" //Required Parameter
    var transaction_currency: String?
    var transaction_total: NSNumber?
    var transaction_discount: NSNumber?
    var transaction_shipping: NSNumber?
    var transaction_tax: NSNumber?
}
