//
//  Item.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation

public class Item: NSObject {
    
    public var item_id = "" //Required Parameter
    public var item_name: String?
    public var item_sku: String?
    public var item_category: [AnyHashable]?
    public var item_price: NSNumber?
    public var item_currency: String?
    public var item_quantity: NSNumber?
}
