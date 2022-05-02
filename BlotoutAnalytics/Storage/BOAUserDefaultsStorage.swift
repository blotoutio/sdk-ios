//
//  BOAUserDefaultsStorage.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation

class BOAUserDefaultsStorage:NSObject {
    
    var crypto: BOACrypto?
    private(set) var defaults: UserDefaults
    private(set) var namespacePrefix: String?
    
    init(defaults: UserDefaults, namespacePrefix: String, crypto: BOACrypto) {
       
            self.defaults = defaults
            self.namespacePrefix = namespacePrefix
            self.crypto = crypto
        super.init()
    }
    
    func removeKey(_ key: String) {
        defaults.removeObject(forKey: namespacedKey(key) ?? "")
       // defaults.removeValue(forKey: namespacedKey(key))
    }
    
    func resetAll() {
        // Courtesy of http://stackoverflow.com/questions/6358737/nsuserdefaults-reset
        if (namespacePrefix == nil) {
            let domainName = Bundle.main.bundleIdentifier
            if let domainName = domainName {
                defaults.removePersistentDomain(forName: domainName)
                return
            }
        }

        for key in defaults.dictionaryRepresentation().keys {
            guard let key = key as? String else {
                continue
            }
            if (namespacePrefix == nil) || key.hasPrefix(namespacePrefix ?? "") {
                defaults.removeObject(forKey: key)
            }
        }
        defaults.synchronize()
    }
    func set(_ data: Data, forKey key: String) {
        var key = key
        key = namespacedKey(key) ?? ""
        if (crypto == nil) {
            defaults.set(data, forKey: key)
            return
        }

    /* removing encryption
     let encryptedData = crypto?.encrypt(data)
        defaults.set(encryptedData, forKey: key)*/
    }
    
    func data(forKey key: String) -> Data? {
        var key = key
        key = namespacedKey(key) ?? ""
        if (crypto == nil) {
            
            return defaults.value(forKey: key) as? Data
           // return defaults[key] as? Data
        }
        /* removing encryption
        let data = defaults.value(forKey: key) as? Data
       // let data = defaults[key] as? Data
        if data == nil {
            BOFLogDebug(frmt: "WARNING: No data file for key %@", args: key)
            return nil
        }

        return crypto?.decrypt(data!)
         */
    }
    
    func dictionary(forKey key: String) -> [String : Any]? {
        var key = key
        if (crypto == nil) {
            key = namespacedKey(key) ?? ""
            return defaults.dictionary(forKey: key)
        }

        return plist(forKey: key) as? [String : Any]
    }
    
    func set(_ dictionary: [String : Any], forKey key: String) {
        var key = key
        if (crypto == nil) {
            key = namespacedKey(key) ?? ""
            defaults.set(dictionary, forKey: key)
            return
        }

        setPlist(dictionary, forKey: key)
    }
    
    func array(forKey key: String) -> [Any]? {
        var key = key
        if (crypto == nil) {
            key = namespacedKey(key) ?? ""
            return defaults.array(forKey: key)
        }

        return plist(forKey: key) as? [Any]
    }
    
    func set(_ array: [Any], forKey key: String) {
        var key = key
        if (crypto == nil) {
            key = namespacedKey(key) ?? ""
            defaults.set(array, forKey: key)
            return
        }

        setPlist(array, forKey: key)
    }
    
    func string(forKey key: String) -> String? {
        var key = key
        if (crypto == nil) {
            key = namespacedKey(key) ?? ""
            return defaults.string(forKey: key)
        }

        return plist(forKey: key) as? String
    }
    
    func set(_ string: String, forKey key: String) {
        var key = key
        if (crypto == nil) {
            key = namespacedKey(key) ?? ""
            defaults.set(string, forKey: key)
            return
        }

        setPlist(string, forKey: key)
    }
    
    func plist(forKey key: String) -> Any? {
        let data = self.data(forKey: key )
        return data != nil ? BOAUtilities.plist(from: data!) : nil
    }

    func setPlist(_ plist: Any, forKey key: String?) {
        let data = BOAUtilities.data(fromPlist: plist)
        if let data = data {
            set(data, forKey: key ?? "")
        }
    }
    
    func namespacedKey(_ key: String) -> String? {
        if (namespacePrefix != nil) {
            return "\(String(describing: namespacePrefix)).\(key )"
        }
        return key
    }
}
