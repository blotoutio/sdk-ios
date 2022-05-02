//
//  BOAStorage.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation


//won't need crypto further var crypto: BOACrypto?


protocol BOAStorage: NSObjectProtocol {
    //won't need crypto further  var crypto: BOACrypto? { get set }
    func removeKey(_ key: String)
    func resetAll()
    func setData(data: Data, forKey key: String)
    func data(forKey key: String) -> Data?
    func set(_ dictionary: [String : Any]?, forKey key: String)
    func dictionary(forKey key: String) -> [String : Any]?
    func set(_ array: [Any]?, forKey key: String)
    func array(forKey key: String) -> [Any]?
    func set(_ string: String?, forKey key: String)
    func string(forKey key: String) -> String?
}
