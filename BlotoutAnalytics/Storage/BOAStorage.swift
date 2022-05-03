//
//  BOAStorage.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation

protocol BOAStorage: NSObjectProtocol {
    func removeKey(_ key: String)
    func resetAll()
    
    func setData(_ data: Data, forKey key: String)
    func dataForKey(_ key: String) -> Data?
    
    func setDictionary(_ dictionary: [String : Any], forKey key: String)
    func dictionaryForKey(_ key: String) -> [String : Any]?
    
    func setArray(_ array: [Any]?, forKey key: String)
    func arrayForKey(_ key: String) -> [Any]?
    
    func setString(_ string: String?, forKey key: String)
    func stringForKey(_ key: String) -> String?
}
