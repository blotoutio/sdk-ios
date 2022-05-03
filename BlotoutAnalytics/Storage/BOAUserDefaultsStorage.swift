//
//  BOAUserDefaultsStorage.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation

class BOAUserDefaultsStorage:NSObject {
    
    private(set) var defaults: UserDefaults
    private(set) var namespacePrefix: String?
    
    init(defaults: UserDefaults, namespacePrefix: String) {
        
        self.defaults = defaults
        self.namespacePrefix = namespacePrefix
        super.init()
    }
    
    func removeKey(_ key: String) {
        defaults.removeObject(forKey: namespacedKey(key))
    }
    
    func resetAll() {
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
        key = namespacedKey(key)
        defaults.set(data, forKey: key)
    }
    
    func data(forKey key: String) -> Data? {
        var key = key
        key = namespacedKey(key)
        return defaults.value(forKey: key) as? Data
    }
    
    func dictionary(forKey key: String) -> [String : Any]? {
        var key = key
        key = namespacedKey(key)
        return defaults.dictionary(forKey: key)
    }
    
    func set(_ dictionary: [String : Any], forKey key: String) {
        var key = key
        key = namespacedKey(key)
        defaults.set(dictionary, forKey: key)
    }
    
    func array(forKey key: String) -> [Any]? {
        var key = key
        key = namespacedKey(key)
        return defaults.array(forKey: key)
        
    }
    
    func set(_ array: [Any], forKey key: String) {
        var key = key
        key = namespacedKey(key)
        defaults.set(array, forKey: key)
        return
    }
    
    func string(forKey key: String) -> String? {
        var key = key
        key = namespacedKey(key)
        return defaults.string(forKey: key)
    }
    
    func set(_ string: String, forKey key: String) {
        var key = key
        key = namespacedKey(key)
        defaults.set(string, forKey: key)
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
    
    func namespacedKey(_ key: String) -> String{
        if (namespacePrefix != nil) {
            return "\(String(describing: namespacePrefix)).\(key )"
        }
        return key
    }
}
