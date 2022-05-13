//
//  TransactionData.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation

public class TransactionData: NSObject {
    
    public var transaction_id = "" //Required Parameter
    public var transaction_currency: String?
    public var transaction_total: NSNumber?
    public var transaction_discount: NSNumber?
    public var transaction_shipping: NSNumber?
    public var transaction_tax: NSNumber?
}
