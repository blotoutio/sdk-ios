//
//  BOAItem.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation

class BOAItem: NSObject {
    var item_id = ""
    var item_name: String?
    var item_sku: String?
    var item_category: [AnyHashable : Any]?
    var item_price: Int?
    var item_currency: String?
    var item_quantity: Int?
}
