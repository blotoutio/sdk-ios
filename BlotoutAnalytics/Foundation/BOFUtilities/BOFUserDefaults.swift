//
//  BOFUserDefaults.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 31/03/22.
//

import Foundation
private var sBOFDefaultMap: [AnyHashable : Any]? = nil
private var sBOFDefaultsSerialQueue: DispatchQueue? = nil

class BOFUserDefaults {
    private var productKey: String?
    private var productContainer: [AnyHashable : Any]?
    
    
    class func initialize() {
           // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
           SwiftTryCatch.try({
               sBOFDefaultMap = [AnyHashable : Any]()
               sBOFDefaultsSerialQueue = DispatchQueue(label: BO_SDK_DEFAULT_QUEUE)
           } catch { 
               BOFLogDebug("%@:%@", BOF_DEBUG, exception)
           })
       }
    
    init(product key: String?) {
        do{
            super.init()
            productKey = key
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }

    class func userDefaults(forProduct product: String) -> Self {
        do{
            var defaultsInstance: BOFUserDefaults? = nil
            sBOFDefaultsSerialQueue.sync(execute: {
                defaultsInstance = sBOFDefaultMap[product] as? BOFUserDefaults
                if defaultsInstance == nil {
                    defaultsInstance = BOFUserDefaults(product: product)
                    sBOFDefaultMap[product] = defaultsInstance
                }
            })
            return defaultsInstance
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
    
    
    class func root(_ updateBlock: @escaping (_ root: [AnyHashable : Any]) -> Void) {
        do{
            var ud = UserDefaults.standard
            var rootImmutable = ud.dictionary(forKey: BO_SDK_ROOT_USER_DEFAULTS_KEY)
            if rootImmutable == nil {
                rootImmutable = [:]
            }
            var rootMutable = rootImmutable
            updateBlock(rootMutable)
            ud.set(rootMutable, forKey: BO_SDK_ROOT_USER_DEFAULTS_KEY)
            ud.synchronize()
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    
    
   
    
    
    func updateDefault(forProduct updateBlock: @escaping (_ produtContainer: [AnyHashable : Any]) -> Bool) {
        do{
            weak var weakSelf = self
            BOFUserDefaults.root({ root in
                
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
                let hasChanged = updateBlock(productContainer)
                if hasChanged {
                    root[weakSelf?.productKey] = productContainer
                }
            })
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
   
        
        func setObject(_ obj: Any, forKey aKey: NSCopying) {
            // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
            SwiftTryCatch.try({
                
                if obj == nil {
                    return
                    //We have batch updates in progress
                }
                if let productContainer = productContainer {
                    productContainer[aKey] = obj
                } else {
                    updateDefault(forProduct: { produtContainer in
                        produtContainer[aKey] = obj
                        return true
                    })
                }
            } catch { 
                BOFLogDebug("%@:%@", BOF_DEBUG, exception)
            })
        }
    
    
    func removeObject(forKey aKey: Any) {
        do{
            if let productContainer = productContainer {
                productContainer.removeValue(forKey: aKey)
            } else {
                updateDefault(forProduct: { produtContainer in
                    produtContainer.removeValue(forKey: aKey)
                    return true
                })
            }
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
    }
    
    func object(forKey key: NSLocale.Key) -> Any? {
        do{
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
        } catch { 
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        })
        return nil
    }
}
