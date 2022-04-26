//
//  BOCrypt.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 31/03/22.
//

import Foundation
class BOCrypt {
    class func encrypt(_ message: String?, key: String?, iv: String?) -> String? {
        var encryptedData: Data? = nil
        do {
            encryptedData = try message?.data(using: .utf8)?.aes256EncryptedData(usingKey: key?.data(using: .utf8)?.sha256Hash(), iv: iv?.data(using: .utf8)?.sha256Hash(), error: nil)
        } catch {
        }
        let base64EncodedString = String.base64String(from: encryptedData, length: (encryptedData?.count ?? 0))
        return base64EncodedString
    }
    class func encryptData(_ data: Data?, key: String?, iv: String?) -> String? {
        var encryptedData: Data? = nil
        do {
            encryptedData = try data?.aes256EncryptedData(usingKey: key?.data(using: .utf8)?.sha256Hash(), iv: iv?.data(using: .utf8)?.sha256Hash(), error: nil)
        } catch {
        }
        let base64EncodedString = String.base64String(from: encryptedData, length: (encryptedData?.count ?? 0))
        return base64EncodedString
    }
    
    class func encryptAndReturn(_ data: Data?, key: String?, iv: String?) -> Data? {
        var encryptedData: Data? = nil
        do {
            encryptedData = try data?.aes256EncryptedData(usingKey: key?.data(using: .utf8)?.sha256Hash(), iv: iv?.data(using: .utf8)?.sha256Hash(), error: nil)
        } catch {
        }
        return encryptedData
    }
    
    class func encryptDataWithoutHash(_ data: Data?, key: String?, iv: String?) -> String? {
        var encryptedData: Data? = nil
        do {
            encryptedData = try data?.aes256EncryptedData(usingKey: key?.data(using: .utf8), iv: iv?.data(using: .utf8), error: nil)
        } catch {
        }
        let base64EncodedString = String.base64String(from: encryptedData, length: (encryptedData?.count ?? 0))
        return base64EncodedString
    }
    
    class func decrypt(_ base64EncodedString: String?, key: String?, iv: String?) -> String? {
        let encryptedData = Data.base64Data(from: base64EncodedString)
        var decryptedData: Data? = nil
        do {
            decryptedData = try encryptedData?.decryptedAES256Data(usingKey: key?.data(using: .utf8)?.sha256Hash(), iv: iv?.data(using: .utf8)?.sha256Hash())
        } catch {
        }
        if let decryptedData = decryptedData {
            return String(data: decryptedData, encoding: .utf8)
        }
        return nil
    }
    
    class func decryptAndReturn(_ data: Data?, key: String?, iv: String?) -> Data? {
        var decryptedData: Data? = nil
        do {
            decryptedData = try data?.decryptedAES256Data(usingKey: key?.data(using: .utf8)?.sha256Hash(), iv: iv?.data(using: .utf8)?.sha256Hash())
        } catch {
        }
        return decryptedData
    }
}
