//
//  BOFUserDefaults.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 31/03/22.
//

import Foundation
private var sBOFDefaultMap: [AnyHashable : Any]? = nil
private var sBOFDefaultsSerialQueue: DispatchQueue? = nil

class BOFUserDefaults:NSObject {
    private var productKey: String?
    private var productContainer: [AnyHashable : Any]?
    
    
    init(product key: String?) {
        super.init()
        productKey = key
        sBOFDefaultMap = [AnyHashable : Any]()
        sBOFDefaultsSerialQueue = DispatchQueue(label: BO_SDK_DEFAULT_QUEUE)
    }
    
    class func userDefaults(forProduct product: String) -> Self {
        var defaultsInstance: BOFUserDefaults? = nil
        sBOFDefaultsSerialQueue?.sync(execute: {
            defaultsInstance = sBOFDefaultMap?[product] as? BOFUserDefaults
            if defaultsInstance == nil {
                defaultsInstance = BOFUserDefaults(product: product)
                sBOFDefaultMap?[product] = defaultsInstance
            }
        })
        return defaultsInstance as! Self
    }
    
    
    
    class func root(_ updateBlock: @escaping (_ root: [AnyHashable : Any]) -> Void) {
        let ud = UserDefaults.standard
        var rootImmutable = ud.dictionary(forKey: BO_SDK_ROOT_USER_DEFAULTS_KEY)
        if rootImmutable == nil {
            rootImmutable = [:]
        }
        let rootMutable = rootImmutable
        updateBlock(rootMutable ?? [:])
        ud.set(rootMutable, forKey: BO_SDK_ROOT_USER_DEFAULTS_KEY)
        ud.synchronize()
        
    }
    
    func updateDefault(forProduct updateBlock: @escaping (_ produtContainer: [AnyHashable : Any]) -> Bool) {
        weak var weakSelf = self
        BOFUserDefaults.root({ root in
            var rootObj = root
            //Get the product level defaults
            //Eg:
            // com.blotout.root.sdk
            //      -- Product1
            //          --Product1 defaults
            //      -- Product2
            //          --Product2 defaults
            
            var productContainer: [AnyHashable : Any]? = nil
            if let productKey = weakSelf?.productKey {
                productContainer = root[productKey] as? [AnyHashable : Any]
            }
            if productContainer == nil {
                productContainer = [:]
            }
            let hasChanged = updateBlock(productContainer ?? [:])
            if hasChanged {
                rootObj[weakSelf?.productKey] = productContainer
            }
        })
        
    }
    
    
    
    func setObject(_ obj: Any?, forKey aKey: String) {
        
        if obj == nil {
            return
            //We have batch updates in progress
        }
        if var productContainer = productContainer {
            productContainer[aKey as! AnyHashable] = obj
        } else {
            updateDefault(forProduct: { produtContainer in
                var productContainer = produtContainer
                productContainer[aKey as! AnyHashable] = obj
                return true
            })
        }
    }
    
    
    func removeObjectForKey( aKey: Any) {
        
        if self.productContainer != nil
        {
            self.productContainer?.removeValue(forKey: aKey as! AnyHashable)
        }
        else {
            
            updateDefault { produtContainer in
                var newContainer = produtContainer
                newContainer.removeValue(forKey: aKey as! AnyHashable)
                return true
            }
        }
    }
    func object(forKey key: String) -> Any? {
        var object: Any? = nil
        
        if let productContainer = productContainer {
            object = productContainer[key]
        } else {
            updateDefault(forProduct: { produtContainer in
                object = produtContainer[key]
                return false
            })
        }
        return object
    }
}

