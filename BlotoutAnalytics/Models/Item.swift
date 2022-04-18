//
//  Item.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation

class Item: NSObject {
    
    var item_id = "" //Required Parameter
    var item_name: String?
    var item_sku: String?
    var item_category: [AnyHashable]?
    var item_price: NSNumber?
    var item_currency: String?
    var item_quantity: NSNumber?
}
